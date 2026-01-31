import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // for compute
import 'package:image_picker/image_picker.dart';
import 'package:stegx/data/crypto_service.dart';
import 'package:stegx/data/stego_service.dart';
import 'package:stegx/data/models/history_model.dart';
import 'package:stegx/presentation/providers/history_provider.dart';
import 'package:stegx/presentation/providers/auth_provider.dart';
import 'package:stegx/presentation/providers/settings_provider.dart';

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
  return DecryptionNotifier(ref);
});

class DecryptionNotifier extends StateNotifier<DecryptionState> {
  final Ref _ref;
  
  DecryptionNotifier(this._ref) : super(DecryptionState());

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
      // Minimum display time for loader (so users see the animation)
      final startTime = DateTime.now();
      
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

      // Ensure loader shows for at least 3 seconds (so users definitely see it)
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed.inMilliseconds < 3000) {
        await Future.delayed(Duration(milliseconds: 3000 - elapsed.inMilliseconds));
      }

      state = state.copyWith(isProcessing: false, decryptedText: plainText, attempts: 0);

      // Log successful decryption to history
      _logDecryptionHistory(success: true);

    } catch (e) {
      // Security measure: Increment attempts
      // In a real app we might delay response to prevent timing attacks
      await Future.delayed(const Duration(seconds: 1)); 
      state = state.copyWith(
        isProcessing: false, 
        error: "Decryption Failed: Invalid Key ($key) or Corrupted Data.",
        attempts: state.attempts + 1
      );

      // Log failed decryption to history
      _logDecryptionHistory(success: false);
    }
  }

  void _logDecryptionHistory({required bool success}) {
    try {
      final settings = _ref.read(settingsProvider);
      if (settings.autoSaveHistory) {
        final user = _ref.read(authStateProvider).value;
        if (user != null) {
          final historyItem = HistoryItem(
            id: '',
            userId: user.uid,
            type: HistoryType.decrypt,
            timestamp: DateTime.now(),
            imageName: 'decrypted_image.png',
            success: success,
          );
          _ref.read(historyProvider.notifier).addHistoryItem(historyItem);
        }
      }
    } catch (_) {
      // Ignore history logging errors
    }
  }
  
  void reset() {
    state = DecryptionState();
  }
}
