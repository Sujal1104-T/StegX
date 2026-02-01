
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
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:media_scanner/media_scanner.dart';


// State class
class EncryptionState {
  final Uint8List? selectedImageBytes;
  final bool isProcessing;
  final String? generatedKey;
  final String? error;
  final Uint8List? processedImageBytes;
  final bool hasSavedToHistory;

  EncryptionState({
    this.selectedImageBytes,
    this.isProcessing = false,
    this.generatedKey,
    this.error,
    this.processedImageBytes,
    this.hasSavedToHistory = false,
  });

  EncryptionState copyWith({
    Uint8List? selectedImageBytes,
    bool? isProcessing,
    String? generatedKey,
    String? error,
    Uint8List? processedImageBytes,
    bool? hasSavedToHistory,
  }) {
    return EncryptionState(
      selectedImageBytes: selectedImageBytes ?? this.selectedImageBytes,
      isProcessing: isProcessing ?? this.isProcessing,
      generatedKey: generatedKey ?? this.generatedKey,
      error: error, // Nullable to clear error
      processedImageBytes: processedImageBytes ?? this.processedImageBytes,
      hasSavedToHistory: hasSavedToHistory ?? this.hasSavedToHistory,
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
        state = state.copyWith(selectedImageBytes: bytes, error: null, generatedKey: null, processedImageBytes: null, hasSavedToHistory: false);
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
    
    // CRITICAL: Give Flutter a chance to rebuild UI with loader
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      // Minimum display time for loader (so users see the animation)
      final startTime = DateTime.now();
      
      // 1. Generate Key
      final key = _crypto.generateKey();
      
      // 2. Encrypt Message
      final encryptedMessage = _crypto.encrypt(plainText: secretText.trim(), key: key);

      // 3. Process in Background Isolate (Prevents UI Freeze)
      final stegoBytes = await compute(embedInIsolate, {
        'imageBytes': state.selectedImageBytes!,
        'secretData': encryptedMessage,
        'key': key,
      });

      if (stegoBytes == null) throw Exception("Embedding failed.");

      // Ensure loader shows for at least 3 seconds
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed.inMilliseconds < 3000) {
        await Future.delayed(Duration(milliseconds: 3000 - elapsed.inMilliseconds));
      }

      bool historySaved = false;
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
              imageName: 'encrypted_image.png', // We don't have real filename here
              messageLength: secretText.length,
            );
            _ref.read(historyProvider.notifier).addHistoryItem(historyItem);
            historySaved = true;
          }
        }
      } catch (_) {
        // Ignore history logging errors
      }

      state = state.copyWith(
        isProcessing: false,
        generatedKey: key,
        processedImageBytes: stegoBytes,
        hasSavedToHistory: historySaved,
      );

    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
    }
  }

  Future<String?> saveImage() async {
      if (state.processedImageBytes == null) return null;
      
      try {
           String? path;
           
           if (!kIsWeb && Platform.isAndroid) {
              // Android: Request appropriate permissions based on Android version
              // For Android 13+ (API 33+), we need READ_MEDIA_IMAGES for image picker
              // For saving to Downloads, we don't need WRITE permission with MediaStore
              
              // Request storage/photos permission
              PermissionStatus status;
              
              // Try photos permission first (Android 13+)
              status = await Permission.photos.request();
              
              // If photos permission not available, try storage (Android 12 and below)
              if (status.isDenied || status.isPermanentlyDenied) {
                status = await Permission.storage.request();
              }
              
              // If still denied, show error
              if (status.isDenied || status.isPermanentlyDenied) {
                throw Exception('Storage permission is required to save images. Please grant permission in Settings.');
              }
              
              // Use Downloads directory
              final directory = Directory('/storage/emulated/0/Download');
              if (!await directory.exists()) {
                await directory.create(recursive: true);
              }
              
              final fileName = "STEGX_${DateTime.now().millisecondsSinceEpoch}.png";
              final file = File('${directory.path}/$fileName');
              
              // Write the file
              await file.writeAsBytes(state.processedImageBytes!);
              path = file.path;
              print("File written to: $path");
              
              // CRITICAL: Scan file with MediaStore so it appears in Downloads/Gallery
              try {
                await MediaScanner.loadMedia(path: path);
                print("MediaScanner: File scanned successfully - $path");
              } catch (e) {
                print("MediaScanner failed: $e");
                // File is still saved, just might not be immediately visible
              }
              
           } else {
              // iOS/Web/Desktop: use FileSaver
              path = await FileSaver.instance.saveFile(
                  name: "STEGX_${DateTime.now().millisecondsSinceEpoch}",
                  bytes: state.processedImageBytes!,
                  ext: "png",
                  mimeType: MimeType.png
              );
           }

           // Log to history if NOT already saved (Manual Save)
           if (!state.hasSavedToHistory) {
             try {
               final user = _ref.read(authStateProvider).value;
               if (user != null) {
                 final historyItem = HistoryItem(
                   id: '', 
                   userId: user.uid,
                   type: HistoryType.encrypt,
                   timestamp: DateTime.now(),
                   imageName: path?.split(Platform.pathSeparator).last ?? "encrypted.png",
                   messageLength: 0, 
                   success: true,
                 );
                 
                 await _ref.read(historyProvider.notifier).addHistoryItem(historyItem);
                 state = state.copyWith(hasSavedToHistory: true);
                 print("History Item Added Successfully");
               }
             } catch (e) {
                print("History save failed: $e");
             }
           }

           return path;
      } catch (e) {
          print("Save failed: $e");
          state = state.copyWith(error: "Failed to save: $e");
          return null;
      }
  }
}
