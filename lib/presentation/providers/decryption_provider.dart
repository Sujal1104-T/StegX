import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // for compute
import 'package:image_picker/image_picker.dart';
import 'package:stegx/data/crypto_service.dart';
import 'package:stegx/data/stego_service.dart';

class DecryptionState {
  final Uint8List? selectedImageBytes;
  final bool isProcessing;
  final String? decryptedText;
  final String? error;
  final int attempts;

  DecryptionState({
    this.selectedImageBytes,
    this.isProcessing = false,
    this.decryptedText,
    this.error,
    this.attempts = 0,
  });

  DecryptionState copyWith({
    Uint8List? selectedImageBytes,
    bool? isProcessing,
    String? decryptedText,
    String? error,
    int? attempts,
  }) {
    return DecryptionState(
      selectedImageBytes: selectedImageBytes ?? this.selectedImageBytes,
      isProcessing: isProcessing ?? this.isProcessing,
      decryptedText: decryptedText, // Null passes through to clear
      error: error, // Null passes through to clear
      attempts: attempts ?? this.attempts,
    );
  }
}

final decryptionProvider = StateNotifierProvider.autoDispose<DecryptionNotifier, DecryptionState>((ref) {
  return DecryptionNotifier();
});

class DecryptionNotifier extends StateNotifier<DecryptionState> {
  DecryptionNotifier() : super(DecryptionState());

  final _picker = ImagePicker();
  final _crypto = CryptoService();
  final _stego = StegoService();

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        state = state.copyWith(selectedImageBytes: bytes, error: null, decryptedText: null);
      }
    } catch (e) {
      state = state.copyWith(error: "Failed to pick image: $e");
    }
  }

  Future<void> decrypt(String key) async {
    if (state.selectedImageBytes == null) {
      state = state.copyWith(error: "Select an image first.");
      return;
    }
    if (key.isEmpty) {
      state = state.copyWith(error: "Enter the access key.");
      return;
    }
    if (state.attempts >= 5) {
       state = state.copyWith(error: "Too many failed attempts. Restart app.");
       return;
    }

    state = state.copyWith(isProcessing: true, error: null, decryptedText: null);

    try {
      // 1. Read Image Bytes
      final imageBytes = state.selectedImageBytes!;
      final trimmedKey = key.trim(); // CRITICAL: remove whitespace

      // 2. Extract Encrypted String in Background Isolate
      final extractedData = await compute(extractInIsolate, {
        'imageBytes': imageBytes,
        'key': trimmedKey,
      });

      // 3. Decrypt String
      final plainText = _crypto.decrypt(encryptedData: extractedData, key: trimmedKey);

      state = state.copyWith(isProcessing: false, decryptedText: plainText, attempts: 0);

    } catch (e) {
      // Security measure: Increment attempts
      // In a real app we might delay response to prevent timing attacks
      await Future.delayed(const Duration(seconds: 1)); 
      state = state.copyWith(
        isProcessing: false, 
        error: "Decryption Failed: Invalid Key ($key) or Corrupted Data.",
        attempts: state.attempts + 1
      );
    }
  }
  
  void reset() {
    state = DecryptionState();
  }
}
