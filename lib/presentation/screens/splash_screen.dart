import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.scaffoldBackgroundColor,
              theme.primaryColor.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated grid background
            Positioned.fill(
              child: CustomPaint(
                painter: GridPainter(color: theme.primaryColor.withValues(alpha: 0.1)),
              ).animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(duration: 2000.ms)
                  .then()
                  .shimmer(duration: 2000.ms, color: theme.primaryColor.withValues(alpha: 0.2)),
            ),
            
            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon with glitch effect
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.primaryColor,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: 60,
                      color: theme.primaryColor,
                    ),
                  ).animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut)
                      .then()
                      .shimmer(duration: 1500.ms, color: theme.primaryColor)
                      .shake(hz: 2, duration: 200.ms, delay: 1500.ms),
                  
                  const SizedBox(height: 40),
                  
                  // App name with typing effect
                  Text(
                    'STEG_X',
                    style: GoogleFonts.orbitron(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                      color: theme.primaryColor,
                      shadows: [
                        Shadow(
                          color: theme.primaryColor.withValues(alpha: 0.8),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ).animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: 10),
                  
                  // Tagline
                  Text(
                    'STEGANOGRAPHY ENCRYPTION',
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      letterSpacing: 4,
                      color: theme.primaryColor.withValues(alpha: 0.7),
                    ),
                  ).animate()
                      .fadeIn(delay: 800.ms, duration: 600.ms),
                  
                  const SizedBox(height: 60),
                  
                  // Loading indicator
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                      .fadeIn(delay: 1200.ms)
                      .shimmer(duration: 1500.ms, color: theme.primaryColor.withValues(alpha: 0.5)),
                ],
              ),
            ),
            
            // Version info at bottom
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Text(
                'v1.0.0 | SECURE • ENCRYPTED • INVISIBLE',
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoMono(
                  fontSize: 10,
                  color: theme.primaryColor.withValues(alpha: 0.5),
                  letterSpacing: 2,
                ),
              ).animate()
                  .fadeIn(delay: 1500.ms, duration: 600.ms),
            ),
          ],
        ),
      ),
    );
  }
}

// Grid painter for cyberpunk background
class GridPainter extends CustomPainter {
  final Color color;

  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
