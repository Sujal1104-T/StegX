import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stegx/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final authNotifier = ref.read(authProvider.notifier);
      final isSignUp = ref.read(authProvider).isSignUp;
      
      if (isSignUp) {
        authNotifier.signUpWithEmail(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        authNotifier.signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Listen to auth state changes and navigate when authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(authStateProvider, (previous, next) {
        next.whenData((user) {
          if (user != null && mounted) {
            // User is authenticated, navigate to home
            Navigator.pushReplacementNamed(context, '/home');
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final isSignUp = authState.isSignUp;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.scaffoldBackgroundColor,
              theme.primaryColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Icon(
                      Icons.lock_outline,
                      size: 80,
                      color: theme.primaryColor,
                    ).animate()
                        .scale(duration: 600.ms, curve: Curves.elasticOut)
                        .shimmer(delay: 600.ms, duration: 1500.ms),
                    
                    const SizedBox(height: 20),
                    
                    // Title
                    Text(
                      isSignUp ? 'CREATE_ACCOUNT' : 'ACCESS_SYSTEM',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        color: theme.primaryColor,
                      ),
                    ).animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 40),
                    
                    // Email field
                    _buildTextField(
                      controller: _emailController,
                      label: 'EMAIL_ADDRESS',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Invalid email format';
                        }
                        return null;
                      },
                    ).animate()
                        .fadeIn(delay: 400.ms)
                        .slideX(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 20),
                    
                    // Password field
                    _buildTextField(
                      controller: _passwordController,
                      label: 'PASSWORD',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: theme.primaryColor.withValues(alpha: 0.7),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (isSignUp && value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ).animate()
                        .fadeIn(delay: 500.ms)
                        .slideX(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 10),
                    
                    // Forgot password (only for sign in)
                    if (!isSignUp)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            _showForgotPasswordDialog();
                          },
                          child: Text(
                            'FORGOT_PASSWORD?',
                            style: GoogleFonts.robotoMono(
                              fontSize: 11,
                              color: theme.primaryColor.withValues(alpha: 0.8),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ).animate()
                          .fadeIn(delay: 600.ms),
                    
                    const SizedBox(height: 30),
                    
                    // Error message
                    if (authState.error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.error),
                          color: theme.colorScheme.error.withValues(alpha: 0.1),
                        ),
                        child: Text(
                          authState.error!,
                          style: GoogleFonts.robotoMono(
                            color: theme.colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ).animate()
                          .shake(),
                    
                    // Submit button
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _handleSubmit,
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                isSignUp ? 'REGISTER_NOW' : 'AUTHENTICATE',
                                style: const TextStyle(letterSpacing: 2),
                              ),
                      ),
                    ).animate()
                        .fadeIn(delay: 700.ms)
                        .slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 30),
                    
                    // Toggle sign up/sign in
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isSignUp ? 'Already have an account?' : 'Don\'t have an account?',
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            color: theme.primaryColor.withValues(alpha: 0.7),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(authProvider.notifier).toggleMode();
                          },
                          child: Text(
                            isSignUp ? 'SIGN_IN' : 'SIGN_UP',
                            style: GoogleFonts.robotoMono(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ).animate()
                        .fadeIn(delay: 1000.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.robotoMono(color: theme.primaryColor),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.primaryColor.withValues(alpha: 0.7)),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: theme.primaryColor.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.primaryColor.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'RESET_PASSWORD',
          style: GoogleFonts.orbitron(
            color: theme.primaryColor,
            letterSpacing: 2,
          ),
        ),
        content: TextField(
          controller: emailController,
          style: GoogleFonts.robotoMono(color: theme.primaryColor),
          decoration: InputDecoration(
            labelText: 'EMAIL_ADDRESS',
            prefixIcon: Icon(Icons.email_outlined, color: theme.primaryColor.withValues(alpha: 0.7)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                ref.read(authProvider.notifier).resetPassword(emailController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Password reset email sent!',
                      style: GoogleFonts.robotoMono(),
                    ),
                    backgroundColor: theme.primaryColor,
                  ),
                );
              }
            },
            child: const Text('SEND'),
          ),
        ],
      ),
    );
  }
}
