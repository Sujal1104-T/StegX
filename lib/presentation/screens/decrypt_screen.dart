import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stegx/presentation/providers/decryption_provider.dart';
import 'package:stegx/presentation/widgets/cyberpunk_loader.dart';

class DecryptScreen extends ConsumerStatefulWidget {
  const DecryptScreen({super.key});

  @override
  ConsumerState<DecryptScreen> createState() => _DecryptScreenState();
}

class _DecryptScreenState extends ConsumerState<DecryptScreen> {
  final _keyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(decryptionProvider);
    final theme = Theme.of(context);
    final isProcessing = state.isProcessing;

    return Scaffold(
      appBar: AppBar(
        title: Text('DECRYPT_MODE', style: GoogleFonts.orbitron(letterSpacing: 2)),
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
                 // Image Preview Area (Similar to Encrypt but simplified)
                GestureDetector(
                  onTap: isProcessing ? null : () => ref.read(decryptionProvider.notifier).pickImage(),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border.all(color: state.selectedImageBytes != null ? theme.colorScheme.secondary : theme.disabledColor),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (state.selectedImageBytes != null)
                          Image.memory(state.selectedImageBytes!, fit: BoxFit.cover, width: double.infinity, height: double.infinity).animate().fadeIn(),
                        
                        if (state.selectedImageBytes == null)
                           Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(Icons.lock_person_outlined, size: 48, color: theme.disabledColor),
                               const SizedBox(height: 10),
                               Text("SELECT ENCRYPTED IMAGE", style: theme.textTheme.labelLarge?.copyWith(color: theme.disabledColor)),
                             ],
                           ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Key Input
                TextField(
                  controller: _keyController,
                  style: GoogleFonts.robotoMono(color: theme.colorScheme.secondary),
                  obscureText: false, // Keys are base64 strings usually, maybe visible is better for UX
                  decoration: InputDecoration(
                    labelText: 'ACCESS_KEY',
                    hintText: 'Enter the access key (e.g. X7k9P2)',
                    prefixIcon: Icon(Icons.vpn_key, color: theme.colorScheme.secondary),
                    focusedBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.zero,
                       borderSide: BorderSide(color: theme.colorScheme.secondary, width: 2),
                    ),
                  ),
                ).animate().slideY(begin: 0.2, duration: 400.ms),

                const SizedBox(height: 30),

                // Attempts Warning
                if (state.attempts > 0)
                   Text(
                     'WARNING: ${5 - state.attempts} attempts remaining.',
                     style: GoogleFonts.robotoMono(color: theme.colorScheme.error),
                     textAlign: TextAlign.center,
                   ).animate().shimmer(duration: 1.seconds),

                const SizedBox(height: 10),

                // Buttons
                 if (state.decryptedText == null)
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.secondary),
                      onPressed: isProcessing ? null : () {
                        ref.read(decryptionProvider.notifier).decrypt(_keyController.text);
                      },
                      child: Text(isProcessing ? 'DECRYPTING...' : 'UNLOCK_DATA'),
                    ),
                  ),

                 const SizedBox(height: 40),

                 // RESULT
                 if (state.decryptedText != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        border: Border.all(color: theme.primaryColor),
                      ),
                      child: Column(
                        children: [
                          Text('DECRYPTION SUCCESSFUL', style: theme.textTheme.labelLarge?.copyWith(color: theme.primaryColor)),
                          const Divider(),
                          SelectableText(
                            state.decryptedText!,
                            style: GoogleFonts.robotoMono(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                               Clipboard.setData(ClipboardData(text: state.decryptedText!));
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
                            },
                          )
                        ],
                      ),
                    ).animate().scaleY(begin: 0, end: 1, duration: 600.ms, curve: Curves.easeOutBack, alignment: Alignment.topCenter),
                 ],

                 // Error
                 if (state.error != null)
                   Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        state.error!,
                        style: GoogleFonts.robotoMono(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ).animate().shake(),
                   ),
              ],
            ),
          ),
          
          // Loading Overlay
          if (isProcessing)
            Positioned.fill(
              child: CyberpunkLoader(statusText: 'DECRYPTING...'),
            ),
        ],
      ),
    );
  }
}
