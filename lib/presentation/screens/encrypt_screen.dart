
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stegx/presentation/providers/encryption_provider.dart';
import 'package:stegx/presentation/widgets/cyberpunk_loader.dart';
import 'package:stegx/presentation/widgets/dashed_rect_painter.dart';

class EncryptScreen extends ConsumerStatefulWidget {
  const EncryptScreen({super.key});

  @override
  ConsumerState<EncryptScreen> createState() => _EncryptScreenState();
}

class _EncryptScreenState extends ConsumerState<EncryptScreen> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(encryptionProvider);
    final theme = Theme.of(context);
    final isProcessing = state.isProcessing;
    
    // Debug: Check if processing state changes
    print('🔍 Encrypt Screen - isProcessing: $isProcessing');


    return Scaffold(
      appBar: AppBar(
        title: Text('ENCRYPT_MODE', style: GoogleFonts.orbitron(letterSpacing: 2)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Preview Area
                GestureDetector(
                  onTap: state.processedImageBytes != null 
                      ? null // Lock picker if done
                      : () => ref.read(encryptionProvider.notifier).pickImage(),
                  child: Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border.all(
                        color: state.selectedImageBytes != null ? theme.primaryColor : theme.disabledColor,
                        width: 2,
                        style: BorderStyle.none, // Can't do dashed easily without custom painter, using solid for now
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Dashed Border Simulator
                        Positioned.fill(
                          child: CustomPaint(
                            painter: DashedRectPainter(
                              color: state.selectedImageBytes != null ? theme.primaryColor : theme.disabledColor,
                              strokeWidth: 2,
                              gap: 10,
                            ),
                          ),
                        ),
                        if (state.selectedImageBytes != null)
                          Image.memory(
                             state.selectedImageBytes!, 
                             fit: BoxFit.cover,
                             width: double.infinity,
                             height: double.infinity,
                          ).animate().fadeIn(),
                        
                        if (state.selectedImageBytes == null)
                           Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(Icons.add_photo_alternate_outlined, size: 48, color: theme.disabledColor),
                               const SizedBox(height: 10),
                               Text("SELECT TARGET IMAGE", style: theme.textTheme.labelLarge?.copyWith(color: theme.disabledColor)),
                             ],
                           ),
                      ],
                    ),
                  ),
                ),
      
                const SizedBox(height: 30),
      
                // Text Input
                if (state.generatedKey == null && !isProcessing)
                  TextField(
                    controller: _textController,
                    maxLines: 5,
                    style: GoogleFonts.robotoMono(color: theme.primaryColor),
                    decoration: InputDecoration(
                      labelText: 'SECRET_PAYLOAD',
                      hintText: 'Enter text to hide...',
                      alignLabelWithHint: true,
                    ),
                  ).animate().slideY(begin: 0.2, duration: 400.ms),
      
                // SUCCESS STATE: Show Key and Save
                if (state.generatedKey != null) ...[
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       border: Border.all(color: theme.primaryColor),
                       color: theme.primaryColor.withValues(alpha: 0.05),
                     ),
                     child: Column(
                       children: [
                         Icon(Icons.check_circle_outline, color: theme.primaryColor, size: 48)
                             .animate().scale(curve: Curves.elasticOut),
                         const SizedBox(height: 10),
                         Text('ENCRYPTION SUCCESSFUL', style: theme.textTheme.displayMedium?.copyWith(fontSize: 18)),
                         const Divider(height: 30, color: Colors.white24),
                         Text('ACCESS_KEY (SAVE THIS):', style: theme.textTheme.labelSmall),
                         const SizedBox(height: 5),
                         SelectableText(
                           state.generatedKey!,
                           style: GoogleFonts.robotoMono(
                             fontSize: 32, // Larger font for short key
                             letterSpacing: 4, // Spaced out for readability
                             color: theme.colorScheme.secondary, 
                             fontWeight: FontWeight.bold
                           ),
                           textAlign: TextAlign.center,
                         ),
                         const SizedBox(height: 10),
                         TextButton.icon(
                           onPressed: () {
                             Clipboard.setData(ClipboardData(text: state.generatedKey!));
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text('Key copied to clipboard!')),
                             );
                           },
                           icon: const Icon(Icons.copy),
                           label: const Text('COPY KEY'),
                         ),
                       ],
                     ),
                   ).animate().fadeIn(),
                ],
      
                // Error Display
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      'ERROR: ${state.error}',
                      style: GoogleFonts.robotoMono(color: theme.colorScheme.error),
                    ),
                  ),
      
                const SizedBox(height: 30),
      
                // Action Button
                if (state.generatedKey == null)
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isProcessing ? null : () {
                        ref.read(encryptionProvider.notifier).encryptAndEmbed(_textController.text);
                      },
                      child: Text(isProcessing ? 'PROCESSING...' : 'INITIATE_ENCRYPTION'),
                    ),
                  )
                else
                   SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.secondary),
                      onPressed: () async {
                         final path = await ref.read(encryptionProvider.notifier).saveImage();
                         if (path != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                 content: Text('Image saved to $path'),
                                 backgroundColor: theme.primaryColor,
                               )
                            );
                         }
                      },
                      child: const Text('SAVE_ENCRYPTED_IMAGE'),
                    ),
                  ),
              ],
            ),
          ),
          
          // Full Screen Loader - Simplified for visibility
          if (isProcessing) ...[
            const Positioned.fill(
              child: CyberpunkLoader(statusText: 'ENCRYPTING'),
            ),
          ],
        ],
      ),
    );
  }
}

// End of file
