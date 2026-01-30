import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:crypto/crypto.dart'; // Add crypto import
import 'dart:convert'; // Add convert for utf8

class StegoService {
  /// Embeds [secretData] into the [image] using a randomized LSB algorithm seeded by [key].
  /// Returns the modified image as bytes.
  Future<Uint8List?> embedData({
    required img.Image image,
    required String secretData,
    required String key,
  }) async {
    // 1. Prepare Data: [32-bit Length Header] + [Secret Bytes]
    final secretBytes = Uint8List.fromList(secretData.codeUnits);
    final lengthBytes = Uint8List(4)..buffer.asByteData().setInt32(0, secretBytes.length);
    final payload = Uint8List.fromList([...lengthBytes, ...secretBytes]);

    // 2. Validate Capacity
    final totalPixels = image.width * image.height;
    // We use 3 bits per pixel (R, G, B channels).
    // Capacity = totalPixels * 3 bits.
    // Payload size in bits = payload.length * 8.
    if (payload.length * 8 > totalPixels * 3) {
      throw Exception('Image too small to hold this message.');
    }

    // 3. Initialize PRNG with Stable Key Hash
    // key.hashCode is not stable across runs/platforms. Use SHA-256.
    final seed = _getStableSeed(key); 
    final random = Random(seed);

    // 4. Generate Shuffled Pixel Indices
    // We create a list of indices and shuffle them deterministically based on the key.
    // To handle large images efficiently, we only generate as many unique random indices as we need.
    // For very large images, a full shuffle is expensive. We use a set to track used indices.
    final neededBits = payload.length * 8;
    // Each pixel can hide 3 bits.
    final neededPixels = (neededBits / 3).ceil();
    
    final pixelIndices = <int>{};
    while (pixelIndices.length < neededPixels) {
      pixelIndices.add(random.nextInt(totalPixels));
    }
    final shuffledIndices = pixelIndices.toList();


    // 5. Embed Data
    int bitIndex = 0;
    
    for (int pIndex in shuffledIndices) {
       // Convert linear index to (x, y)
       final x = pIndex % image.width;
       final y = pIndex ~/ image.width;
       
       img.Pixel pixel = image.getPixel(x, y);
       
       // Embed into Red
       if (bitIndex < neededBits) {
         int bit = (payload[bitIndex ~/ 8] >> (7 - (bitIndex % 8))) & 1;
         pixel.r = (pixel.r.toInt() & ~1) | bit;
         bitIndex++;
       }
       
       // Embed into Green
       if (bitIndex < neededBits) {
         int bit = (payload[bitIndex ~/ 8] >> (7 - (bitIndex % 8))) & 1;
         pixel.g = (pixel.g.toInt() & ~1) | bit;
         bitIndex++;
       }
       
       // Embed into Blue
       if (bitIndex < neededBits) {
         int bit = (payload[bitIndex ~/ 8] >> (7 - (bitIndex % 8))) & 1;
         pixel.b = (pixel.b.toInt() & ~1) | bit;
         bitIndex++;
       }
       
       image.setPixel(x, y, pixel);
       
       if (bitIndex >= neededBits) break;
    }

    // 6. Encode Image to PNG (Lossless is Critical)
    return Uint8List.fromList(img.encodePng(image));
  }

  /// Extracts secret data from the [imageBytes] using the [key].
  Future<String> extractData({
    required Uint8List imageBytes,
    required String key,
  }) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) throw Exception('Failed to decode image.');

    final totalPixels = image.width * image.height;
    
    // We need to read the first 32 bits (4 bytes) to know the length of the message.
    // However, the bits are scattered based on the PRNG seed.
    // We don't know the exact needed pixels *initially* because needed pixels depends on length.
    // BUT, the PRNG sequence is deterministic. So the *first* K pixels picked by the RNG
    // will ALWAYS be the same for the same key.
    
    // 3. Initialize PRNG with Stable Key Hash
    final seed = _getStableSeed(key); 
    final random = Random(seed);

    // We can't just generate "needed" indices because we don't know the length yet.
    // But we know the header is 4 bytes = 32 bits.
    // 32 bits / 3 bits/pixel ~= 11 pixels.
    // So we can generate indices in batches or just use the same logic as encryption.
    // To properly reconstruct, we essentially simulate the "infinite" stream of random indices
    // and pull 32 bits first.
    
    // To avoid complex re-generation logic, we can stick to a simpler strategy:
    // Generate a secure permutation of [0...TotalPixels] is too expensive for large images.
    // Using a Set as in encryption is valid.
    // The sequence of `random.nextInt(totalPixels)` calls is deterministic.
    
    // Step 1: Read Header (Length)
    int length = 0;
    List<int> headerBits = [];
    Set<int> usedIndices = {};
    
    // We need 32 bits.
    while (headerBits.length < 32) {
       int pIndex;
       do {
         pIndex = random.nextInt(totalPixels);
       } while (usedIndices.contains(pIndex));
       usedIndices.add(pIndex);

       final x = pIndex % image.width;
       final y = pIndex ~/ image.width;
       final pixel = image.getPixel(x, y);

       headerBits.add(pixel.r.toInt() & 1);
       if (headerBits.length < 32) headerBits.add(pixel.g.toInt() & 1);
       if (headerBits.length < 32) headerBits.add(pixel.b.toInt() & 1);
    }

    // Convert bits to int length
    for (int i = 0; i < 32; i++) {
      length |= (headerBits[i] << (31 - i)); // Reading big-endian
       // Oops, in encryption: 
       // byte = payload[index]
       // bit = byte >> (7 - bitPos) & 1.  (MSB first)
       // So yes, we reconstruct similarly.
    }
    
    // Step 2: Read Body
    if (length < 0 || length > 1000000) { // Safety check
      throw Exception('Invalid data length ($length). Wrong key?');
    }

    // final totalBits = length * 8; // unused
    // List<int> bodyBits = []; // unused
    
    // We continue the SAME random sequence.
    // We already consumed pixels for the header.
    // However, we may have extracted "extra" bits from the last pixel of the header
    // if 32 is not divisible by 3 (it's not, 32 = 3*10 + 2).
    // The logic in Encrypt was:
    // for pIndex in shuffled...
    //   fill R, then G, then B.
    // So for the Pixel #11 (index 10), we used R and G for the last 2 bits of header.
    // The B channel of Pixel #11 *should* contain the first bit of the Body.
    // My previous logic `headerBits.length < 32` stopped *exactly* when we had 32 bits.
    // But did I consume the random index generation correctly?
    // In encryption, I generated ALL indices first. 
    // Here, I am generating them on the fly. This needs to match EXACTLY.
    
    // Let's refine the extraction to be robust loop-based.
    
    // Reset and redo simply to match the generation logic perfectly.
    // In Encrypt: 
    // 1. Calculate TOTAL needed bits (32 + length*8).
    // 2. Determine needed pixels.
    // 3. Generate list of pixel indices.
    
    // Issue: In Decrypt, we DON'T know "TOTAL needed bits" initially.
    // Solution: We must separate Header extraction from Body extraction?
    // No, because the random sequence `pixelIndices` depends on `random.nextInt` being called X times.
    // If we stop and restart, we might lose state or we need to be careful.
    // Wait, `Set` insertion order matters? No, the `while` loop order matters.
    
    // Strategy:
    // 1. Read first 32 bits. To do this, we just need to pull pixels until we have 32 bits.
    //    We keep track of the `random` state and `usedIndices`.
    // 2. Decode length.
    // 3. Continue pulling pixels until we have `32 + length * 8` bits.
    
    // Current state check:
    // `random` is at state after generating N pixels for Header.
    // `usedIndices` has N pixels.
    // We might have "unused" channels in the last pixel if we stopped early.
    // But `headerBits.length < 32` stops strictly. 
    // If the last pixel contributed 2 bits (R, G), we didn't read B.
    // If we just continue, the next read should be... the B channel of that SAME pixel?
    // In Encrypt: `for (int pIndex in shuffledIndices)`... loops pixels.
    // Inside: embed R, embed G, embed B.
    // If we finish header at bit 32 (R,G of pixel 10), bit 33 (start of body) goes to B of pixel 10.
    
    // So, we need to persist the current pixel and current channel index?
    // Actually, it's easier to just read *all* 3 channels of every pixel we pull, buffer the bits,
    // and then process the stream.
    
    // CORRECTED LOOP:
    List<int> allBits = [];
    int currentPayloadLength = 32; // Initially just header
    bool lengthDecoded = false;
    
    // Re-init for clean slate logic
    final random2 = Random(seed);
    final usedIndices2 = <int>{};
    
    int bitsRead = 0;
    
    while (bitsRead < currentPayloadLength) {
       int pIndex;
       do {
         pIndex = random2.nextInt(totalPixels);
       } while (usedIndices2.contains(pIndex));
       usedIndices2.add(pIndex);
       
       final x = pIndex % image.width;
       final y = pIndex ~/ image.width;
       final pixel = image.getPixel(x, y);

       // Helper to check header update
       void checkHeader() {
          if (!lengthDecoded && allBits.length == 32) {
            int lToRead = 0;
            for (int i = 0; i < 32; i++) {
               lToRead |= (allBits[i] << (31 - i));
            }
             if (lToRead < 0 || lToRead > 5000000) { // Safety sanity check
              throw Exception('Invalid length detected: $lToRead. Incorrect key?');
            }
            currentPayloadLength = 32 + lToRead * 8;
            lengthDecoded = true;
          }
       }
       
       if (bitsRead < currentPayloadLength) { 
         allBits.add(pixel.r.toInt() & 1); 
         bitsRead++; 
         checkHeader();
       }
       if (bitsRead < currentPayloadLength) { 
         allBits.add(pixel.g.toInt() & 1); 
         bitsRead++; 
         checkHeader();
       }
       if (bitsRead < currentPayloadLength) { 
         allBits.add(pixel.b.toInt() & 1); 
         bitsRead++; 
         checkHeader();
       }
    }
    
    // Reconstruct bytes
    // Skip first 32 bits
    final bodyBitsSlice = allBits.sublist(32);
    final byteCount = bodyBitsSlice.length ~/ 8;
    final bytes = Uint8List(byteCount);
    
    for (int i = 0; i < byteCount; i++) {
      int byteVal = 0;
      for (int b = 0; b < 8; b++) {
        byteVal |= (bodyBitsSlice[i * 8 + b] << (7 - b));
      }
      bytes[i] = byteVal;
    }
    return String.fromCharCodes(bytes);
  }

  int _getStableSeed(String key) {
    final bytes = utf8.encode(key);
    final digest = sha256.convert(bytes).bytes;
    // Turn first 4 bytes into a 32-bit integer
    return (digest[0] << 24) | (digest[1] << 16) | (digest[2] << 8) | digest[3];
  }
}

// Top-level functions for Isolate usage (compute)
Future<Uint8List?> embedInIsolate(Map<String, dynamic> params) async {
  final imageBytes = params['imageBytes'] as Uint8List;
  final secretData = params['secretData'] as String;
  final key = params['key'] as String;

  final image = img.decodeImage(imageBytes);
  if (image == null) throw Exception("Could not decode image in isolate.");

  final service = StegoService();
  return service.embedData(image: image, secretData: secretData, key: key);
}

Future<String> extractInIsolate(Map<String, dynamic> params) async {
  final imageBytes = params['imageBytes'] as Uint8List;
  final key = params['key'] as String;

  final service = StegoService();
  return service.extractData(imageBytes: imageBytes, key: key);
}
