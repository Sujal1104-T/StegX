import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stegx/presentation/screens/encrypt_screen.dart';
import 'package:stegx/presentation/screens/decrypt_screen.dart';
import 'package:stegx/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: theme.primaryColor),
            tooltip: 'Sign Out',
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Grid Effect
          Positioned.fill(
             child: CustomPaint(
               painter: GridPainter(),
             ).animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 3.seconds, color: theme.primaryColor.withValues(alpha: 0.1)),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  'STEG_X',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 48,
                    shadows: [
                      Shadow(color: theme.primaryColor, blurRadius: 20),
                      Shadow(color: theme.colorScheme.secondary, blurRadius: 40, offset: const Offset(2,2)),
                    ],
                  ),
                ).animate()
                 .fadeIn(duration: 800.ms)
                 .slideY(begin: -0.5, end: 0)
                 .then(delay: 500.ms)
                 .shake(hz: 4, curve: Curves.easeInOutCubic, duration: 1.seconds), // Glitch feel

                const SizedBox(height: 10),
                Text(
                  'SECURE // ENCRYPT // HIDE',
                  style: theme.textTheme.bodyMedium?.copyWith(letterSpacing: 4),
                ).animate().fadeIn(delay: 1000.ms),

                const SizedBox(height: 60),

                // Actions
                _buildCyberButton(
                  context,
                  label: 'ENCRYPT',
                  icon: Icons.lock_outline,
                  color: theme.primaryColor,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EncryptScreen())),
                ).animate().slideX(begin: -1, delay: 1200.ms, curve: Curves.easeOutExpo),

                const SizedBox(height: 24),

                _buildCyberButton(
                  context,
                  label: 'DECRYPT',
                  icon: Icons.lock_open,
                  color: theme.colorScheme.secondary,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DecryptScreen())),
                ).animate().slideX(begin: 1, delay: 1400.ms, curve: Curves.easeOutExpo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCyberButton(BuildContext context, {
    required String label, 
    required IconData icon, 
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.zero,
      child: Container(
        width: 250,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          color: color.withValues(alpha: 0.1),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                label,
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 2,
                ),
              ),
            ),
            Container(
              width: 50,
              height: 60,
              color: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FF41).withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const double step = 40;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
