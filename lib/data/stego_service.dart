import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:stegx/core/utils/portable_random.dart';

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
    final lengthBytes = Uint8List(4)..buffer.asByteData().setInt32(0, secretBytes.length, Endian.big);
    final payload = Uint8List.fromList([...lengthBytes, ...secretBytes]);

    // 2. Validate Capacity
    final totalPixels = image.width * image.height;
    // We use 3 bits per pixel (R, G, B channels).
    if (payload.length * 8 > totalPixels * 3) {
      throw Exception('Image too small to hold this message.');
    }

    // 3. Initialize PRNG with Stable Key Hash
    final seed = _getStableSeed(key); 
    final random = PortableRandom(seed);

    // 4. Embed Data
    // We generate random pixel indices on the fly to avoid storing a massive list.
    // To ensure we don't overwrite or collide too often, we track used indices.
    // OPTIMIZATION: For scalability with large images, avoid infinite loops when nearing capacity.
    
    final neededBits = payload.length * 8;
    int bitIndex = 0;
    
    // We use a Set to track used pixels. 
    // Warning: As neededPixels approaches totalPixels, this becomes slow (Coupon Collector).
    // Limit capacity usage to 50% for performance safety, or accept slowdown.
    // Ideally we would use a format-preserving encryption for non-colliding permutation.
    // For this implementation, we accept the Set overhead but add a timeout/safety.
    
    final usedIndices = <int>{};
    int safetyCounter = 0;
    final maxIterations = neededBits * 100; // Allow some collisions but not infinite

    while (bitIndex < neededBits) {
       int pIndex;
       
       // Try to find a unique pixel
       do {
         pIndex = random.nextInt(totalPixels);
         safetyCounter++;
         if (safetyCounter > maxIterations) {
           throw Exception("Embedding failed: High density collision timeout. Try a larger image.");
         }
       } while (usedIndices.contains(pIndex));
       
       usedIndices.add(pIndex);

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
    
    // 3. Initialize PRNG with Stable Key Hash
    final seed = _getStableSeed(key); 
    final random = PortableRandom(seed);

    // Extraction Logic matched to Embedding
    List<int> allBits = [];
    int currentPayloadLength = 32; // Initially just header
    bool lengthDecoded = false;
    
    final usedIndices = <int>{};
    int bitsRead = 0;
    
    // Safety
    int safetyCounter = 0;
    final maxIterations = totalPixels * 10; 

    while (bitsRead < currentPayloadLength) {
       int pIndex;
       do {
         pIndex = random.nextInt(totalPixels);
         safetyCounter++;
          if (safetyCounter > maxIterations) {
           throw Exception("Extraction failed: Loop detection.");
         }
       } while (usedIndices.contains(pIndex));
       usedIndices.add(pIndex);
       
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
             // Sanity check: length shouldn't be absurdly large (e.g. > 50MB)
             if (lToRead < 0 || lToRead > 50000000) { 
              throw Exception('Invalid data length detected ($lToRead). Wrong key?');
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
    // Turn first 4 bytes into a 32-bit integer that behaves consistently
    int seed = (digest[0] << 24) | (digest[1] << 16) | (digest[2] << 8) | digest[3];
    return seed & 0xFFFFFFFF; // Ensure unsigned 32-bit behavior mostly
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
