import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stegx/presentation/providers/auth_provider.dart';

class DrawerMenu extends ConsumerWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Header with user info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor.withValues(alpha: 0.2),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: theme.primaryColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.primaryColor,
                      width: 2,
                    ),
                    color: theme.primaryColor.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    size: 40,
                    color: theme.primaryColor,
                  ),
                ).animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .shimmer(delay: 300.ms, duration: 1500.ms),
                
                const SizedBox(height: 16),
                
                // User email
                Text(
                  user?.email ?? 'User',
                  style: GoogleFonts.robotoMono(
                    fontSize: 14,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ).animate()
                    .fadeIn(delay: 200.ms),
                
                const SizedBox(height: 4),
                
                Text(
                  'AUTHENTICATED',
                  style: GoogleFonts.robotoMono(
                    fontSize: 10,
                    color: theme.primaryColor.withValues(alpha: 0.6),
                    letterSpacing: 2,
                  ),
                ).animate()
                    .fadeIn(delay: 300.ms),
              ],
            ),
          ),
          
          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.home_outlined,
                  label: 'HOME',
                  route: '/home',
                  delay: 400,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.history,
                  label: 'HISTORY',
                  route: '/history',
                  delay: 500,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  label: 'SETTINGS',
                  route: '/settings',
                  delay: 600,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.help_outline,
                  label: 'HELP',
                  route: '/help',
                  delay: 700,
                ),
              ],
            ),
          ),
          
          // Sign out button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                icon: Icon(Icons.logout, color: theme.colorScheme.error),
                label: Text(
                  'SIGN OUT',
                  style: GoogleFonts.orbitron(
                    letterSpacing: 2,
                    color: theme.colorScheme.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.colorScheme.error),
                ),
              ),
            ),
          ).animate()
              .fadeIn(delay: 800.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required int delay,
  }) {
    final theme = Theme.of(context);
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isActive = currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: isActive
            ? Border.all(color: theme.primaryColor, width: 2)
            : null,
        color: isActive
            ? theme.primaryColor.withValues(alpha: 0.1)
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? theme.primaryColor : theme.primaryColor.withValues(alpha: 0.7),
        ),
        title: Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 14,
            letterSpacing: 2,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? theme.primaryColor : theme.primaryColor.withValues(alpha: 0.7),
          ),
        ),
        onTap: () {
          Navigator.pop(context); // Close drawer
          if (!isActive) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
      ),
    ).animate()
        .fadeIn(delay: delay.ms)
        .slideX(begin: -0.2, end: 0);
  }
}
