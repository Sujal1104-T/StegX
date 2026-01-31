import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stegx/presentation/providers/settings_provider.dart';
import 'package:stegx/presentation/providers/auth_provider.dart';
import 'package:stegx/presentation/widgets/drawer_menu.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final user = ref.watch(authStateProvider).value;

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
          'SETTINGS',
          style: GoogleFonts.orbitron(
            color: theme.primaryColor,
            letterSpacing: 4,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          _buildSection(
            theme,
            title: 'ACCOUNT',
            children: [
              _buildInfoTile(
                theme,
                icon: Icons.email_outlined,
                label: 'Email',
                value: user?.email ?? 'Not available',
              ),
              _buildActionTile(
                theme,
                icon: Icons.lock_reset,
                label: 'Change Password',
                onTap: () => _showChangePasswordDialog(context, ref),
              ),
            ],
          ).animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          // Preferences Section
          _buildSection(
            theme,
            title: 'PREFERENCES',
            children: [
              _buildSwitchTile(
                theme,
                icon: Icons.history,
                label: 'Auto-Save History',
                subtitle: 'Automatically save encryption/decryption history',
                value: settings.autoSaveHistory,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).updateAutoSaveHistory(value);
                },
              ),
              _buildSwitchTile(
                theme,
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                subtitle: 'Show app notifications',
                value: settings.showNotifications,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).updateShowNotifications(value);
                },
              ),
            ],
          ).animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          // About Section
          _buildSection(
            theme,
            title: 'ABOUT',
            children: [
              _buildInfoTile(
                theme,
                icon: Icons.info_outline,
                label: 'Version',
                value: '1.0.0',
              ),
              _buildActionTile(
                theme,
                icon: Icons.article_outlined,
                label: 'Licenses',
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'StegX',
                  applicationVersion: '1.0.0',
                ),
              ),
            ],
          ).animate()
              .fadeIn(delay: 600.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          // Danger Zone
          _buildSection(
            theme,
            title: 'DANGER ZONE',
            children: [
              _buildActionTile(
                theme,
                icon: Icons.delete_forever,
                label: 'Delete Account',
                color: theme.colorScheme.error,
                onTap: () => _showDeleteAccountDialog(context, ref),
              ),
            ],
          ).animate()
              .fadeIn(delay: 800.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.orbitron(
              fontSize: 12,
              letterSpacing: 3,
              color: theme.primaryColor.withValues(alpha: 0.6),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.primaryColor.withValues(alpha: 0.3),
            ),
            color: theme.primaryColor.withValues(alpha: 0.05),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: theme.primaryColor.withValues(alpha: 0.7)),
      title: Text(
        label,
        style: GoogleFonts.robotoMono(
          color: theme.primaryColor.withValues(alpha: 0.8),
        ),
      ),
      trailing: Text(
        value,
        style: GoogleFonts.robotoMono(
          fontSize: 12,
          color: theme.primaryColor.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final tileColor = color ?? theme.primaryColor.withValues(alpha: 0.7);
    
    return ListTile(
      leading: Icon(icon, color: tileColor),
      title: Text(
        label,
        style: GoogleFonts.robotoMono(color: tileColor),
      ),
      trailing: Icon(Icons.chevron_right, color: tileColor),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: theme.primaryColor.withValues(alpha: 0.7)),
      title: Text(
        label,
        style: GoogleFonts.robotoMono(
          color: theme.primaryColor.withValues(alpha: 0.8),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.robotoMono(
          fontSize: 11,
          color: theme.primaryColor.withValues(alpha: 0.5),
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: theme.primaryColor,
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'CHANGE PASSWORD',
          style: GoogleFonts.orbitron(
            color: theme.primaryColor,
            letterSpacing: 2,
          ),
        ),
        content: Text(
          'Password reset email will be sent to your registered email address.',
          style: GoogleFonts.robotoMono(
            color: theme.primaryColor.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              final user = ref.read(authStateProvider).value;
              if (user?.email != null) {
                ref.read(authProvider.notifier).resetPassword(user!.email!);
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
            child: const Text('SEND EMAIL'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'DELETE ACCOUNT?',
          style: GoogleFonts.orbitron(
            color: theme.colorScheme.error,
            letterSpacing: 2,
          ),
        ),
        content: Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: GoogleFonts.robotoMono(
            color: theme.primaryColor.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement account deletion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Account deletion not yet implemented',
                    style: GoogleFonts.robotoMono(),
                  ),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}
