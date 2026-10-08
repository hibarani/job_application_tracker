import 'package:flutter/material.dart';
import 'package:job_application_tracker/app/app.dart';
import 'package:job_application_tracker/services/storage/local_storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appState = context.findAncestorStateOfType<AppState>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 32),
              
              // Appearance Section
              Text(
                'Appearance',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              _buildAppearanceCard(context, appState),
              const SizedBox(height: 32),
              
              // Data Section
              Text(
                'Data',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              _buildDataCard(context),
              const SizedBox(height: 32),

              // About Section
              Text(
                'About',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              _buildAboutCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppearanceCard(BuildContext context, AppState appState) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.brightness_6),
            title: Text('Theme Mode'),
            subtitle: Text('Select your preferred app appearance.'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // If the screen is very small, we could adjust the UI, 
                // but SegmentedButton usually handles resizing ok.
                return SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(value: ThemeMode.system, label: Text('System')),
                      ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                      ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                    ],
                    selected: <ThemeMode>{
                      (appState.themeMode as ThemeMode?) ??
                          (Theme.of(context).brightness == Brightness.light
                              ? ThemeMode.light
                              : ThemeMode.dark)
                    },
                    onSelectionChanged: (Set<ThemeMode> newSelection) async {
                      final mode = newSelection.first;
                      appState.setThemeMode(mode);
                      final storage = LocalStorageService();
                      if (mode == ThemeMode.light) {
                        await storage.saveThemeMode('light');
                      } else if (mode == ThemeMode.dark) {
                        await storage.saveThemeMode('dark');
                      } else {
                        await storage.saveThemeMode('system');
                      }
                    },
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        leading: Icon(Icons.delete_forever, color: colorScheme.error),
        title: Text('Reset Local Data', style: TextStyle(color: colorScheme.error)),
        subtitle: const Text('Permanently remove all saved job applications.'),
        onTap: () => _showResetConfirmation(context),
      ),
    );
  }

  Future<void> _showResetConfirmation(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset all application data?'),
          content: const Text(
            'This will permanently remove all saved job applications, favorites, and related local data. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final storage = LocalStorageService();
      await storage.deleteAllApplications();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All local data has been successfully reset.')),
        );
      }
    }
  }

  Widget _buildAboutCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: const Text('About Job Application Tracker'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.work, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Job Application Tracker')),
                  ],
                ),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('A simple, beautiful tool to help you organize and track your job search progress.'),
                    SizedBox(height: 16),
                    Text('Built with Flutter & Dart.', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('No backend, no tracking. All data lives on your local device.'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
