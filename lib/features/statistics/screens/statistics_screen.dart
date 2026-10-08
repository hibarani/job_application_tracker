import 'package:flutter/material.dart';
import 'package:job_application_tracker/features/applications/models/job_application.dart';
import 'package:job_application_tracker/services/storage/local_storage_service.dart';

class StatisticsScreen extends StatefulWidget {
  final bool isActive;
  const StatisticsScreen({super.key, this.isActive = false});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final LocalStorageService _storageService = LocalStorageService();
  List<JobApplication> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(StatisticsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    try {
      final apps = await _storageService.loadApplications();
      if (mounted) {
        setState(() {
          _applications = apps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Map<ApplicationStatus, int> get _statusCounts {
    final counts = <ApplicationStatus, int>{
      for (var status in ApplicationStatus.values) status: 0
    };
    for (var app in _applications) {
      counts[app.status] = (counts[app.status] ?? 0) + 1;
    }
    return counts;
  }

  int get _favoritesCount => _applications.where((app) => app.isFavorite).length;

  int get _activeCount => _applications.where((app) => app.status != ApplicationStatus.rejected).length;

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return const Color(0xFF03DAC6);
      case ApplicationStatus.screening:
        return const Color(0xFFFFB74D);
      case ApplicationStatus.interview:
        return const Color(0xFF8175D6);
      case ApplicationStatus.offer:
        return const Color(0xFF4CAF50);
      case ApplicationStatus.rejected:
        return const Color(0xFFD32F2F);
    }
  }

  String _getStatusText(ApplicationStatus status) {
    final text = status.name;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: _applications.isEmpty
                  ? _buildEmptyState(context)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overview',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your job search progress at a glance.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildSummaryCards(context),
                          const SizedBox(height: 32),
                          _buildInsights(context),
                          const SizedBox(height: 32),
                          _buildStatusDistribution(context),
                        ],
                      ),
                    ),
            ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final crossAxisCount = isWide ? 4 : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              context,
              'Total',
              _applications.length.toString(),
              Icons.work_outline,
              Theme.of(context).colorScheme.primary,
            ),
            _buildStatCard(
              context,
              'Favorites',
              _favoritesCount.toString(),
              Icons.favorite,
              const Color(0xFFFF8A65), // Coral/orange
            ),
            _buildStatCard(
              context,
              'Interviews',
              _statusCounts[ApplicationStatus.interview].toString(),
              Icons.event_available,
              _getStatusColor(ApplicationStatus.interview),
            ),
            _buildStatCard(
              context,
              'Offers',
              _statusCounts[ApplicationStatus.offer].toString(),
              Icons.star,
              _getStatusColor(ApplicationStatus.offer),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final mostCommonEntry = _statusCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
    final mostCommonStatusText = mostCommonEntry.value > 0 ? _getStatusText(mostCommonEntry.key) : 'None';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.2),
            colorScheme.tertiary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Insights',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightRow(context, Icons.rocket_launch, 'You have $_activeCount active applications.'),
          const SizedBox(height: 8),
          _buildInsightRow(context, Icons.trending_up, 'Your most common status is $mostCommonStatusText.'),
        ],
      ),
    );
  }

  Widget _buildInsightRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDistribution(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final total = _applications.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Distribution',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          // Simple visual bar chart
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: ApplicationStatus.values.map((status) {
                final count = _statusCounts[status] ?? 0;
                if (count == 0) return const SizedBox.shrink();
                final flex = (count / total * 100).round();
                return Expanded(
                  flex: flex > 0 ? flex : 1,
                  child: Container(
                    height: 16,
                    color: _getStatusColor(status),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          // Legend
          ...ApplicationStatus.values.map((status) {
            final count = _statusCounts[status] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getStatusText(status),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    count.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.analytics_outlined,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No statistics yet',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your first job application to start tracking your progress.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
