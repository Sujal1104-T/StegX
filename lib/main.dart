import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stegx/presentation/screens/home_screen.dart';
import 'package:stegx/presentation/theme/theme.dart';

void main() {
  runApp(const ProviderScope(child: StegXApp()));
}

class StegXApp extends StatelessWidget {
  const StegXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StegX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cyberpunkTheme,
      home: const HomeScreen(),
    );
  }
}
