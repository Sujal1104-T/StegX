import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stegx/data/models/history_model.dart';
import 'package:stegx/presentation/providers/history_provider.dart';
import 'package:stegx/presentation/widgets/drawer_menu.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filterType = ref.watch(historyFilterProvider);
    final historyAsync = ref.watch(historyStreamProvider(filterType));

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
          'HISTORY',
          style: GoogleFonts.orbitron(
            color: theme.primaryColor,
            letterSpacing: 4,
          ),
        ),
        actions: [
          // Filter button
          PopupMenuButton<HistoryType?>(
            icon: Icon(Icons.filter_list, color: theme.primaryColor),
            onSelected: (value) {
              ref.read(historyFilterProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: null,
                child: Text('All', style: GoogleFonts.robotoMono()),
              ),
              PopupMenuItem(
                value: HistoryType.encrypt,
                child: Text('Encrypt Only', style: GoogleFonts.robotoMono()),
              ),
              PopupMenuItem(
                value: HistoryType.decrypt,
                child: Text('Decrypt Only', style: GoogleFonts.robotoMono()),
              ),
            ],
          ),
          // Clear all button
          IconButton(
            icon: Icon(Icons.delete_sweep, color: theme.colorScheme.error),
            tooltip: 'Clear All History',
            onPressed: () => _showClearConfirmation(context, ref),
          ),
        ],
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return _buildEmptyState(theme);
          }
          return _buildHistoryList(context, ref, theme, history);
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: theme.primaryColor),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'Error loading history',
                style: GoogleFonts.robotoMono(color: theme.colorScheme.error),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: GoogleFonts.robotoMono(
                  fontSize: 12,
                  color: theme.primaryColor.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: theme.primaryColor.withValues(alpha: 0.3),
          ).animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            'NO HISTORY YET',
            style: GoogleFonts.orbitron(
              fontSize: 20,
              color: theme.primaryColor.withValues(alpha: 0.5),
              letterSpacing: 4,
            ),
          ).animate()
              .fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          Text(
            'Your encryption and decryption\nhistory will appear here',
            textAlign: TextAlign.center,
            style: GoogleFonts.robotoMono(
              fontSize: 12,
              color: theme.primaryColor.withValues(alpha: 0.4),
            ),
          ).animate()
              .fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    List<HistoryItem> history,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return _buildHistoryCard(context, ref, theme, item, index);
      },
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    HistoryItem item,
    int index,
  ) {
    final isEncrypt = item.type == HistoryType.encrypt;
    final color = isEncrypt ? theme.primaryColor : theme.colorScheme.secondary;
    final icon = isEncrypt ? Icons.lock_outline : Icons.lock_open;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error.withValues(alpha: 0.2),
        child: Icon(Icons.delete, color: theme.colorScheme.error),
      ),
      onDismissed: (direction) {
        ref.read(historyProvider.notifier).deleteHistoryItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'History item deleted',
              style: GoogleFonts.robotoMono(),
            ),
            backgroundColor: theme.primaryColor,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
          color: color.withValues(alpha: 0.05),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
                color: color.withValues(alpha: 0.1),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEncrypt ? 'ENCRYPTED' : 'DECRYPTED',
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.imageName,
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      color: theme.primaryColor.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: theme.primaryColor.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy • HH:mm').format(item.timestamp),
                        style: GoogleFonts.robotoMono(
                          fontSize: 10,
                          color: theme.primaryColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (item.messageLength != null)
                  Text(
                    '${item.messageLength} chars',
                    style: GoogleFonts.robotoMono(
                      fontSize: 11,
                      color: theme.primaryColor.withValues(alpha: 0.7),
                    ),
                  ),
                if (item.success != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.success!
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.2),
                      border: Border.all(
                        color: item.success! ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Text(
                      item.success! ? 'SUCCESS' : 'FAILED',
                      style: GoogleFonts.robotoMono(
                        fontSize: 10,
                        color: item.success! ? Colors.green : Colors.red,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ).animate()
          .fadeIn(delay: (index * 50).ms)
          .slideX(begin: 0.2, end: 0),
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'CLEAR ALL HISTORY?',
          style: GoogleFonts.orbitron(
            color: theme.colorScheme.error,
            letterSpacing: 2,
          ),
        ),
        content: Text(
          'This action cannot be undone. All your encryption and decryption history will be permanently deleted.',
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
              ref.read(historyProvider.notifier).clearAllHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'All history cleared',
                    style: GoogleFonts.robotoMono(),
                  ),
                  backgroundColor: theme.primaryColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('CLEAR ALL'),
          ),
        ],
      ),
    );
  }
}
