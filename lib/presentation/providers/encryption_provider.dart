
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:stegx/data/crypto_service.dart';
import 'package:stegx/data/stego_service.dart';
import 'package:stegx/data/models/history_model.dart';
import 'package:stegx/presentation/providers/history_provider.dart';
import 'package:stegx/presentation/providers/auth_provider.dart';
import 'package:stegx/presentation/providers/settings_provider.dart';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart'; // for compute

// State class
class EncryptionState {
  final Uint8List? selectedImageBytes;
  final bool isProcessing;
  final String? generatedKey;
  final String? error;
  final Uint8List? processedImageBytes;

  EncryptionState({
    this.selectedImageBytes,
    this.isProcessing = false,
    this.generatedKey,
    this.error,
    this.processedImageBytes,
  });

  EncryptionState copyWith({
    Uint8List? selectedImageBytes,
    bool? isProcessing,
    String? generatedKey,
    String? error,
    Uint8List? processedImageBytes,
  }) {
    return EncryptionState(
      selectedImageBytes: selectedImageBytes ?? this.selectedImageBytes,
      isProcessing: isProcessing ?? this.isProcessing,
      generatedKey: generatedKey ?? this.generatedKey,
      error: error, // Nullable to clear error
      processedImageBytes: processedImageBytes ?? this.processedImageBytes,
    );
  }
}

// Provider
final encryptionProvider = StateNotifierProvider.autoDispose<EncryptionNotifier, EncryptionState>((ref) {
  return EncryptionNotifier(ref);
});

class EncryptionNotifier extends StateNotifier<EncryptionState> {
  final Ref _ref;
  
  EncryptionNotifier(this._ref) : super(EncryptionState());

  final _picker = ImagePicker();
  final _crypto = CryptoService();
  final _stego = StegoService();

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        state = state.copyWith(selectedImageBytes: bytes, error: null, generatedKey: null, processedImageBytes: null);
      }
    } catch (e) {
      state = state.copyWith(error: "Failed to pick image: $e");
    }
  }

  Future<void> encryptAndEmbed(String secretText) async {
    if (state.selectedImageBytes == null) {
        state = state.copyWith(error: "Please select an image first.");
        return;
    }
    if (secretText.isEmpty) {
        state = state.copyWith(error: "Please enter a secret message.");
        return;
    }

    state = state.copyWith(isProcessing: true, error: null);

    try {
      // 1. Generate Key
      final key = _crypto.generateKey();

      // 2. Encrypt Message
      // Use compute if the text is huge, but usually fine here.
      final encryptedMessage = _crypto.encrypt(plainText: secretText.trim(), key: key);

      // 3. Process in Background Isolate (Prevents UI Freeze)
      // We pass the RAW bytes, decoding happens in isolate.
      final stegoBytes = await compute(embedInIsolate, {
        'imageBytes': state.selectedImageBytes!,
        'secretData': encryptedMessage,
        'key': key,
      });

      if (stegoBytes == null) throw Exception("Embedding failed.");

      state = state.copyWith(
        isProcessing: false,
        generatedKey: key,
        processedImageBytes: stegoBytes,
      );

      // Log to history if auto-save is enabled
      try {
        final settings = _ref.read(settingsProvider);
        if (settings.autoSaveHistory) {
          final user = _ref.read(authStateProvider).value;
          if (user != null) {
            final historyItem = HistoryItem(
              id: '',
              userId: user.uid,
              type: HistoryType.encrypt,
              timestamp: DateTime.now(),
              imageName: 'encrypted_image.png',
              messageLength: secretText.length,
            );
            _ref.read(historyProvider.notifier).addHistoryItem(historyItem);
          }
        }
      } catch (_) {
        // Ignore history logging errors
      }

    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
    }
  }

  Future<String?> saveImage() async {
      if (state.processedImageBytes == null) return null;
      try {
           // final filename = "STEGX_${DateTime.now().millisecondsSinceEpoch}.png";
           // On Android/iOS this usually saves to Download or Photos depending on setup.
           // file_saver saves to platform specific locations.
           String path = await FileSaver.instance.saveFile(
               name: "STEGX_${DateTime.now().millisecondsSinceEpoch}",
               bytes: state.processedImageBytes!,
               ext: "png",
               mimeType: MimeType.png
           );
           return path;
      } catch (e) {
          state = state.copyWith(error: "Failed to save: $e");
          return null;
      }
  }
}
