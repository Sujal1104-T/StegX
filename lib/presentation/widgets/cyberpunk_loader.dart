import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CyberpunkLoader extends StatefulWidget {
  final String statusText;

  const CyberpunkLoader({super.key, required this.statusText});

  @override
  State<CyberpunkLoader> createState() => _CyberpunkLoaderState();
}

class _CyberpunkLoaderState extends State<CyberpunkLoader> with TickerProviderStateMixin {
  late AnimationController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final secondary = theme.colorScheme.secondary;

    return Container(
      color: Colors.black.withValues(alpha: 0.92), // Darker background
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Digital Rain Background (Matrix effect)
          const Positioned.fill(child: _DigitalRain()),

          // 2. Central HUD and Loader
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Hexagonal Scanner
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating Hexagon Rings
                      CustomPaint(
                        painter: _HexagonPainter(color: primary.withValues(alpha: 0.3)),
                        size: const Size(160, 160),
                      ).animate(onPlay: (c) => c.repeat()).rotate(duration: 8.seconds),

                      CustomPaint(
                        painter: _HexagonPainter(color: secondary.withValues(alpha: 0.5)),
                        size: const Size(120, 120),
                      ).animate(onPlay: (c) => c.repeat()).rotate(duration: 5.seconds, begin: 1, end: 0),

                      // Pulsing Core
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primary.withValues(alpha: 0.1),
                          boxShadow: [
                            BoxShadow(color: primary, blurRadius: 30, spreadRadius: 0)
                          ],
                          border: Border.all(color: primary, width: 2),
                        ),
                        child: Icon(Icons.security, color: primary, size: 30),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                       .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 1000.ms),

                      // Scanning Line
                      AnimatedBuilder(
                        animation: _scannerController,
                        builder: (context, child) {
                          return Positioned(
                            top: 80 * (1 - cos(_scannerController.value * pi)) - 2, // Sine wave motion
                            child: Container(
                              width: 160,
                              height: 4,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    secondary,
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(color: secondary, blurRadius: 10, spreadRadius: 2)
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Glitchy Text
                Text(
                  widget.statusText,
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    color: Colors.white,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(color: primary, blurRadius: 10),
                      Shadow(color: secondary, blurRadius: 20, offset: const Offset(-2, 2)),
                    ],
                  ),
                ).animate(onPlay: (c) => c.repeat())
                 .shimmer(duration: 2000.ms, color: secondary)
                 .shake(hz: 3, offset: const Offset(2, 0), duration: 3000.ms, curve: Curves.easeInOut), // Subtle glitch shake

                 const SizedBox(height: 10),
                 
                 // Decoding... subtext
                 Text(
                   'ACCESSING_SECURE_CHANNEL...',
                   style: GoogleFonts.shareTechMono(
                     fontSize: 14,
                     color: primary.withOpacity(0.7),
                     letterSpacing: 2,
                   ),
                 ).animate().fadeIn(duration: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Digital Rain Effect Widget
class _DigitalRain extends StatefulWidget {
  const _DigitalRain();

  @override
  State<_DigitalRain> createState() => _DigitalRainState();
}

class _DigitalRainState extends State<_DigitalRain> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_StreamDroplet> _droplets = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    
    // Initialize droplets
    for (int i = 0; i < 40; i++) {
      _droplets.add(_StreamDroplet(
        x: _random.nextDouble(), 
        y: _random.nextDouble(), 
        speed: 0.005 + _random.nextDouble() * 0.015,
        length: 5 + _random.nextInt(15),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _DigitalRainPainter(_droplets, Theme.of(context).primaryColor),
        );
      },
    );
  }
}

class _StreamDroplet {
  double x;
  double y;
  double speed;
  int length;
  _StreamDroplet({required this.x, required this.y, required this.speed, required this.length});
}

class _DigitalRainPainter extends CustomPainter {
  final List<_StreamDroplet> droplets;
  final Color color;
  final Random _random = Random();

  _DigitalRainPainter(this.droplets, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var droplet in droplets) {
      // Move droplet
      droplet.y += droplet.speed;
      if (droplet.y > 1.0) {
        droplet.y = -0.5; // Reset to top
        droplet.x = _random.nextDouble();
      }

      // Draw trail
      for (int i = 0; i < droplet.length; i++) {
        final double opacity = (1.0 - (i / droplet.length)) * 0.5;
        paint.color = color.withOpacity(opacity);
        
        // Random binary/chars
        final charIndex = _random.nextInt(2); // 0 or 1
        final textSpan = TextSpan(
          text: charIndex.toString(),
          style: TextStyle(
            color: color.withOpacity(opacity),
            fontSize: 14,
            fontFamily: 'Courier',
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final double yPos = (droplet.y * size.height) - (i * 16);
        if (yPos > 0 && yPos < size.height) {
          textPainter.paint(canvas, Offset(droplet.x * size.width, yPos));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Hexagon Outline Painter
class _HexagonPainter extends CustomPainter {
  final Color color;
  _HexagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final Path path = Path();
    final double width = size.width;
    final double height = size.height;
    final double radius = width / 2;
    
    // Draw Hexagon
    for (int i = 0; i < 6; i++) {
      double angle = (60 * i + 30) * pi / 180; // +30 to rotate point up
      double x = width / 2 + radius * cos(angle);
      double y = height / 2 + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    
    // Draw internal details
    canvas.drawCircle(Offset(width/2, height/2), radius * 0.6, paint..strokeWidth=1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
