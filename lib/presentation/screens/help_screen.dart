import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stegx/presentation/widgets/drawer_menu.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const DrawerMenu(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: theme.primaryColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'HELP & TUTORIAL',
          style: GoogleFonts.orbitron(
            color: theme.primaryColor,
            letterSpacing: 4,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // How to Encrypt
          _buildHowToCard(
            theme,
            title: 'HOW TO ENCRYPT',
            icon: Icons.lock_outline,
            color: theme.primaryColor,
            steps: [
              '1. Navigate to the Encrypt screen from home',
              '2. Select an image from your device',
              '3. Enter your secret message',
              '4. Tap "ENCRYPT" to hide the message',
              '5. Save the encrypted image',
            ],
            delay: 200,
          ),

          const SizedBox(height: 16),

          // How to Decrypt
          _buildHowToCard(
            theme,
            title: 'HOW TO DECRYPT',
            icon: Icons.lock_open,
            color: theme.colorScheme.secondary,
            steps: [
              '1. Navigate to the Decrypt screen from home',
              '2. Select an encrypted image',
              '3. Tap "DECRYPT" to reveal the message',
              '4. View the hidden message',
              '5. Copy or share as needed',
            ],
            delay: 400,
          ),

          const SizedBox(height: 16),

          // FAQ Section
          _buildFAQSection(theme, delay: 600),

          const SizedBox(height: 16),

          // Tips & Best Practices
          _buildTipsCard(theme, delay: 800),

          const SizedBox(height: 16),

          // Contact/Support
          _buildContactCard(theme, delay: 1000),
        ],
      ),
    );
  }

  Widget _buildHowToCard(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required Color color,
    required List<String> steps,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        color: color.withValues(alpha: 0.05),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                  color: color.withValues(alpha: 0.1),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...steps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_right,
                      color: color.withValues(alpha: 0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        step,
                        style: GoogleFonts.robotoMono(
                          fontSize: 13,
                          color: theme.primaryColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate()
        .fadeIn(delay: delay.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildFAQSection(ThemeData theme, {required int delay}) {
    final faqs = [
      {
        'question': 'What is steganography?',
        'answer':
            'Steganography is the practice of hiding secret messages within ordinary files, like images. Unlike encryption, which scrambles data, steganography conceals the existence of the message itself.',
      },
      {
        'question': 'Is my data secure?',
        'answer':
            'Yes! Your messages are embedded directly into images on your device. We use LSB (Least Significant Bit) encoding to hide data. The app requires authentication, and your history is stored securely in Firebase.',
      },
      {
        'question': 'What image formats are supported?',
        'answer':
            'StegX supports PNG and JPEG images. PNG is recommended for better quality preservation after encoding.',
      },
      {
        'question': 'How much text can I hide?',
        'answer':
            'The amount depends on image size. Larger images can store more data. As a rule of thumb, a 1920x1080 image can store several thousand characters.',
      },
      {
        'question': 'Can I share encrypted images?',
        'answer':
            'Yes! Encrypted images look like normal images and can be shared via any platform. The recipient needs StegX to decrypt them.',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.3),
          width: 2,
        ),
        color: theme.primaryColor.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FREQUENTLY ASKED QUESTIONS',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          ...faqs.map((faq) => _buildFAQItem(
                theme,
                question: faq['question']!,
                answer: faq['answer']!,
              )),
        ],
      ),
    ).animate()
        .fadeIn(delay: delay.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildFAQItem(
    ThemeData theme, {
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        question,
        style: GoogleFonts.robotoMono(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: theme.primaryColor.withValues(alpha: 0.9),
        ),
      ),
      iconColor: theme.primaryColor,
      collapsedIconColor: theme.primaryColor.withValues(alpha: 0.6),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16, right: 16),
          child: Text(
            answer,
            style: GoogleFonts.robotoMono(
              fontSize: 12,
              color: theme.primaryColor.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipsCard(ThemeData theme, {required int delay}) {
    final tips = [
      'Use PNG images for best quality preservation',
      'Larger images can store more data',
      'Keep your encrypted images safe - they contain your secrets!',
      'Enable auto-save history to track your encryptions',
      'Test decryption before sharing to ensure message integrity',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.5),
          width: 2,
        ),
        color: Colors.amber.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber, size: 28),
              const SizedBox(width: 12),
              Text(
                'TIPS & BEST PRACTICES',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.amber.withValues(alpha: 0.7),
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip,
                        style: GoogleFonts.robotoMono(
                          fontSize: 12,
                          color: theme.primaryColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate()
        .fadeIn(delay: delay.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildContactCard(ThemeData theme, {required int delay}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.5),
          width: 2,
        ),
        color: theme.colorScheme.secondary.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.support_agent,
                color: theme.colorScheme.secondary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'NEED MORE HELP?',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'If you have questions or need support, feel free to reach out:',
            style: GoogleFonts.robotoMono(
              fontSize: 12,
              color: theme.primaryColor.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: theme.colorScheme.secondary.withValues(alpha: 0.7),
                size: 18,
              ),
              const SizedBox(width: 12),
              Text(
                'support@stegx.app',
                style: GoogleFonts.robotoMono(
                  fontSize: 12,
                  color: theme.primaryColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
        .fadeIn(delay: delay.ms)
        .slideY(begin: 0.2, end: 0);
  }
}
