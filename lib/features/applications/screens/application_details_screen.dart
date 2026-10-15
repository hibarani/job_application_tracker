import 'package:flutter/material.dart';
import 'package:job_application_tracker/app/theme/app_theme.dart';
import 'package:job_application_tracker/features/applications/models/job_application.dart';
import 'package:job_application_tracker/features/applications/screens/add_application_screen.dart';
import 'package:job_application_tracker/services/storage/local_storage_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicationDetailsScreen extends StatefulWidget {
  final JobApplication application;

  const ApplicationDetailsScreen({super.key, required this.application});

  @override
  State<ApplicationDetailsScreen> createState() =>
      _ApplicationDetailsScreenState();
}

class _ApplicationDetailsScreenState extends State<ApplicationDetailsScreen> {
  late JobApplication _currentApplication;

  @override
  void initState() {
    super.initState();
    _currentApplication = widget.application;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatSalary(double salary) {
    final clean = salary % 1 == 0
        ? salary.toInt().toString()
        : salary.toStringAsFixed(2);
    final parts = clean.split('.');
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formattedInt = parts[0].replaceAllMapped(
      reg,
      (Match m) => '${m[1]},',
    );
    return parts.length > 1 ? '\$$formattedInt.${parts[1]}' : '\$$formattedInt';
  }

  Future<void> _launchUrl(String urlString) async {
    try {
      String formatted = urlString.trim();
      if (!formatted.startsWith('http://') &&
          !formatted.startsWith('https://')) {
        formatted = 'https://$formatted';
      }
      final uri = Uri.parse(formatted);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the job link.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Invalid job URL: $urlString')));
      }
    }
  }

  Future<void> _editApplication() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddApplicationScreen(application: _currentApplication),
      ),
    );

    if (result == true && mounted) {
      try {
        final storageService = LocalStorageService();
        final apps = await storageService.loadApplications();
        final updated = apps.firstWhere(
          (a) => a.id == _currentApplication.id,
          orElse: () => _currentApplication,
        );
        if (mounted) {
          setState(() {
            _currentApplication = updated;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to refresh application: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final storageService = LocalStorageService();
      final updatedApp = _currentApplication.copyWith(
        isFavorite: !_currentApplication.isFavorite,
      );
      final apps = await storageService.loadApplications();
      final index = apps.indexWhere((a) => a.id == updatedApp.id);
      if (index != -1) {
        apps[index] = updatedApp;
        await storageService.saveApplications(apps);
        if (mounted) {
          setState(() {
            _currentApplication = updatedApp;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteApplication() async {
    final colorScheme = Theme.of(context).colorScheme;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Application?'),
        content: Text(
          'Are you sure you want to delete "${_currentApplication.jobTitle}" at "${_currentApplication.companyName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final storageService = LocalStorageService();
        await storageService.deleteApplication(_currentApplication.id);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete application: $e'),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final surfaceColor = colorScheme.surfaceContainerHighest;
    final borderColor = isDark
        ? colorScheme.outlineVariant
        : colorScheme.outlineVariant.withValues(alpha: 0.5);
    final primaryAccent = colorScheme.primary;
    final secondaryAccent = colorScheme.secondary;
    final primaryText = colorScheme.onSurface;
    final secondaryText = colorScheme.onSurfaceVariant;
    final statusColor = AppTheme.getStatusColor(
      context,
      _currentApplication.status,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Application Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Application',
            onPressed: _editApplication,
          ),
          IconButton(
            icon: Icon(
              _currentApplication.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: _currentApplication.isFavorite ? primaryAccent : null,
            ),
            tooltip: _currentApplication.isFavorite
                ? 'Remove from favorites'
                : 'Mark as favorite',
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            tooltip: 'Delete Application',
            onPressed: _deleteApplication,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentApplication.jobTitle,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentApplication.companyName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: primaryAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: secondaryText,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _currentApplication.location.isNotEmpty
                                ? _currentApplication.location
                                : 'Location not specified',
                            style: TextStyle(color: secondaryText),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? statusColor.withValues(alpha: 0.2)
                            : statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(
                            alpha: isDark ? 0.5 : 0.3,
                          ),
                        ),
                      ),
                      child: Text(
                        _currentApplication.status.displayName,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Application Information
              _buildSectionCard(
                title: 'Application Information',
                surfaceColor: surfaceColor,
                borderColor: borderColor,
                secondaryText: secondaryText,
                children: [
                  _buildInfoRow(
                    Icons.calendar_today_outlined,
                    'Application Date',
                    _formatDate(_currentApplication.applicationDate),
                    primaryText,
                    secondaryText,
                  ),
                  if (_currentApplication.interviewDate != null) ...[
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.event_available_outlined,
                      'Interview Date',
                      _formatDate(_currentApplication.interviewDate!),
                      primaryText,
                      secondaryText,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Job Information
              if (_currentApplication.jobUrl.isNotEmpty ||
                  _currentApplication.salary != null) ...[
                _buildSectionCard(
                  title: 'Job Information',
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  secondaryText: secondaryText,
                  children: [
                    if (_currentApplication.salary != null)
                      _buildInfoRow(
                        Icons.attach_money_outlined,
                        'Salary',
                        _formatSalary(_currentApplication.salary!),
                        primaryText,
                        secondaryText,
                      ),
                    if (_currentApplication.jobUrl.isNotEmpty &&
                        _currentApplication.salary != null)
                      const SizedBox(height: 16),
                    if (_currentApplication.jobUrl.isNotEmpty)
                      InkWell(
                        onTap: () => _launchUrl(_currentApplication.jobUrl),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.link,
                                color: secondaryAccent,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Open Job Posting',
                                  style: TextStyle(
                                    color: secondaryAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.open_in_new,
                                color: secondaryAccent,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Contact Information
              if (_currentApplication.contactName != null &&
                  _currentApplication.contactName!.isNotEmpty) ...[
                _buildSectionCard(
                  title: 'Contact Information',
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  secondaryText: secondaryText,
                  children: [
                    _buildInfoRow(
                      Icons.person_outline,
                      'Contact Person',
                      _currentApplication.contactName!,
                      primaryText,
                      secondaryText,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Notes
              if (_currentApplication.notes.isNotEmpty) ...[
                _buildSectionCard(
                  title: 'Notes',
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  secondaryText: secondaryText,
                  children: [
                    Text(
                      _currentApplication.notes,
                      style: TextStyle(color: primaryText, height: 1.5),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Color surfaceColor,
    required Color borderColor,
    required Color secondaryText,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: secondaryText,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color primaryText,
    Color secondaryText,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: secondaryText, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: secondaryText, fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
