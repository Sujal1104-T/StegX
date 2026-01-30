import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class CryptoService {
  final _secureRandom = Random.secure();

  // Generates a user-friendly short key (8 characters).
  // Internally this will be hashed to 32 bytes for actual encryption.
  String generateKey({int length = 8}) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789'; // Base58-like to avoid ambiguous chars
    return List.generate(length, (index) => chars[_secureRandom.nextInt(chars.length)]).join();
  }

  // Hashes the key using SHA-256 for secure verification/storage.
  String hashKey(String key) {
    final bytes = utf8.encode(key);
    return sha256.convert(bytes).toString();
  }

  // Encrypts the [plainText] using the [key] with AES-GCM.
  // Returns a base64 string combining IV and CipherText.
  String encrypt({required String plainText, required String key}) {
    // Decode the base64 key or pad/truncate to 32 bytes (256 bits) if needed.
    // Ideally the key provided is already 32 bytes from generateKey().
    final keyBytes = _processKey(key);
    final encrypter = Encrypter(AES(Key(keyBytes), mode: AESMode.gcm));

    final iv = IV.fromSecureRandom(16); // GCM standard IV size is 12 bytes, but library defaults 16
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // Return format: IV (base64) : CipherText (base64)
    return '${iv.base64}:${encrypted.base64}';
  }

  // Decrypts the [encryptedData] using the [key].
  // Expected format: IV (base64) : CipherText (base64)
  String decrypt({required String encryptedData, required String key}) {
    try {
      final parts = encryptedData.split(':');
      if (parts.length != 2) throw Exception('Invalid encrypted data format');

      final iv = IV.fromBase64(parts[0]);
      final cipherText = Encrypted.fromBase64(parts[1]);
      
      final keyBytes = _processKey(key);
      final encrypter = Encrypter(AES(Key(keyBytes), mode: AESMode.gcm));

      return encrypter.decrypt(cipherText, iv: iv);
    } catch (e) {
      throw Exception('Decryption failed: Invalid key or corrupted data.');
    }
  }

  Uint8List _processKey(String key) {
    // If the key is the short user-friendly version, we MUST hash it.
    // If it's already a 32-byte base64 string, we try to use it directly, 
    // but robustly falling back to hashing ensures any string works.
    
    try {
      // Check if it's a legacy base64 32-byte key
      final decoded = base64Url.decode(key);
      if (decoded.length == 32) return decoded;
    } catch (_) {
      // Not base64, so it's likely a short key or raw password
    }
    
    // Default: Hash the key string to get 32 bytes
    return Uint8List.fromList(sha256.convert(utf8.encode(key)).bytes);
  }
}
