import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stegx/firebase_options.dart';
import 'package:stegx/presentation/screens/splash_screen.dart';
import 'package:stegx/presentation/screens/login_screen.dart';
import 'package:stegx/presentation/screens/home_screen.dart';
import 'package:stegx/presentation/screens/encrypt_screen.dart';
import 'package:stegx/presentation/screens/decrypt_screen.dart';
import 'package:stegx/presentation/providers/auth_provider.dart';
import 'package:stegx/presentation/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: StegXApp()));
}

class StegXApp extends ConsumerWidget {
  const StegXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'StegX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cyberpunkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const AuthGuard(child: HomeScreen()),
        '/encrypt': (context) => const AuthGuard(child: EncryptScreen()),
        '/decrypt': (context) => const AuthGuard(child: DecryptScreen()),
      },
    );
  }
}

// Auth guard to protect routes
class AuthGuard extends ConsumerWidget {
  final Widget child;
  
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          // Not authenticated, redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return child;
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

