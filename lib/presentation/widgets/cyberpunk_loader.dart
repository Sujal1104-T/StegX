import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CyberpunkLoader extends StatelessWidget {
  final String statusText;

  const CyberpunkLoader({super.key, required this.statusText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final secondary = theme.colorScheme.secondary;

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Scanning Circle
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer rotating ring
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primary.withValues(alpha: 0.3),
                        width: 4,
                      ),
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.transparent,
                        width: 4,
                      ),
                    ),
                    child: CircularProgressIndicator(
                      color: primary,
                      strokeWidth: 4,
                    ),
                  ).animate(onPlay: (c) => c.repeat()).rotate(duration: 2.seconds),

                  // Inner pulsing core
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: secondary.withValues(alpha: 0.2),
                      boxShadow: [
                        BoxShadow(color: secondary, blurRadius: 20, spreadRadius: -5)
                      ]
                    ),
                    child: Icon(Icons.lock_clock, color: secondary, size: 40),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                   .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.1, 1.1), duration: 800.ms),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Glitch Text
            Text(
              statusText,
              style: GoogleFonts.orbitron(
                fontSize: 20,
                color: Colors.white,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ).animate(onPlay: (c) => c.repeat())
             .shimmer(duration: 1500.ms, color: secondary)
             .shake(hz: 2, curve: Curves.easeInOut, duration: 2000.ms),
             
            const SizedBox(height: 10),
            
            // Binary Stream Simulation
            SizedBox(
              height: 20,
              child: _BinaryStream(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BinaryStream extends StatefulWidget {
  @override
  State<_BinaryStream> createState() => _BinaryStreamState();
}

class _BinaryStreamState extends State<_BinaryStream> with SingleTickerProviderStateMixin {
  String binary = "";
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100))
      ..addListener(() {
        setState(() {
          binary = List.generate(20, (index) => Random().nextBool() ? "1" : "0").join("");
        });
      })
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      binary,
      style: GoogleFonts.shareTechMono(color: Colors.greenAccent, fontSize: 12),
    );
  }
}
