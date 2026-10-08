import 'package:flutter/material.dart';
import 'package:job_application_tracker/features/applications/models/job_application.dart';
import 'package:job_application_tracker/features/applications/screens/add_application_screen.dart';
import 'package:job_application_tracker/features/applications/screens/application_details_screen.dart';
import 'package:job_application_tracker/services/storage/local_storage_service.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  final LocalStorageService _storageService = LocalStorageService();
  List<JobApplication> _applications = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ApplicationStatus? _selectedStatus;
  bool _filterFavorites = false;
  bool _sortNewestFirst = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final apps = await _storageService.loadApplications();
      apps.sort((a, b) => b.applicationDate.compareTo(a.applicationDate));
      if (mounted) {
        setState(() {
          _applications = apps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<JobApplication> get _filteredApplications {
    List<JobApplication> result = List.from(_applications);

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      result = result.where((app) {
        return app.companyName.toLowerCase().contains(query) ||
            app.jobTitle.toLowerCase().contains(query);
      }).toList();
    }

    if (_selectedStatus != null) {
      result = result.where((app) => app.status == _selectedStatus).toList();
    }

    if (_filterFavorites) {
      result = result.where((app) => app.isFavorite).toList();
    }

    result.sort((a, b) {
      if (_sortNewestFirst) {
        return b.applicationDate.compareTo(a.applicationDate);
      } else {
        return a.applicationDate.compareTo(b.applicationDate);
      }
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Applications',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddApplicationScreen(),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Applications',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Keep track of every opportunity in one place.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildSearchField(context),
                        const SizedBox(height: 16),
                        _buildFiltersAndSort(context),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadData,
                      child: _applications.isEmpty
                          ? _buildEmptyState(context)
                          : _filteredApplications.isEmpty
                              ? _buildEmptySearchState(context)
                              : _buildApplicationsList(context, _filteredApplications),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search applications...',
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                },
              )
            : null,
      ),
    );
  }

  String _getStatusText(ApplicationStatus status) {
    final text = status.name;
    return text[0].toUpperCase() + text.substring(1);
  }

  Widget _buildFiltersAndSort(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(null, 'All'),
                const SizedBox(width: 8),
                _buildFavoriteFilterChip(),
                const SizedBox(width: 8),
                ...ApplicationStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildFilterChip(status, _getStatusText(status)),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<bool>(
          initialValue: _sortNewestFirst,
          icon: const Icon(Icons.sort),
          tooltip: 'Sort Applications',
          onSelected: (newestFirst) {
            setState(() {
              _sortNewestFirst = newestFirst;
            });
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: true,
              child: Text('Newest First'),
            ),
            const PopupMenuItem(
              value: false,
              child: Text('Oldest First'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(ApplicationStatus? status, String label) {
    final isSelected = _selectedStatus == status;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
        });
      },
      backgroundColor: colorScheme.surfaceContainerHighest,
      selectedColor: colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
      ),
    );
  }

  Widget _buildFavoriteFilterChip() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return FilterChip(
      label: const Text('Favorites'),
      avatar: Icon(
        _filterFavorites ? Icons.favorite : Icons.favorite_border,
        size: 18,
        color: _filterFavorites ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      selected: _filterFavorites,
      onSelected: (selected) {
        setState(() {
          _filterFavorites = selected;
        });
      },
      backgroundColor: colorScheme.surfaceContainerHighest,
      selectedColor: colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: colorScheme.primary,
      showCheckmark: false,
      labelStyle: TextStyle(
        color: _filterFavorites ? colorScheme.primary : colorScheme.onSurfaceVariant,
        fontWeight: _filterFavorites ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: _filterFavorites ? colorScheme.primary : colorScheme.outlineVariant,
      ),
    );
  }

  Widget _buildEmptySearchState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_filterFavorites && _searchQuery.trim().isEmpty && _selectedStatus == null) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border, size: 64, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                'No favorite applications',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Mark applications as favorites to find them quickly here.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'No matching applications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your search or filters.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedStatus = null;
                  _filterFavorites = false;
                  _sortNewestFirst = true;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                Icons.business_center_outlined,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No applications yet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Start tracking your job search by adding your first application.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddApplicationScreen(),
                  ),
                );
                if (result == true) {
                  _loadData();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Application'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationsList(BuildContext context, List<JobApplication> apps) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 80),
      itemCount: apps.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final app = apps[index];
        return _ApplicationListCard(
          application: app,
          onUpdate: _loadData,
        );
      },
    );
  }
}

class _ApplicationListCard extends StatelessWidget {
  final JobApplication application;
  final VoidCallback onUpdate;

  const _ApplicationListCard({
    required this.application,
    required this.onUpdate,
  });

  Color _getStatusColor(BuildContext context, ApplicationStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (status) {
      case ApplicationStatus.applied:
        return colorScheme.secondary;
      case ApplicationStatus.screening:
        return colorScheme.tertiary;
      case ApplicationStatus.interview:
        return colorScheme.primary;
      case ApplicationStatus.offer:
        return isDark ? const Color(0xFF4CAF50) : Colors.green;
      case ApplicationStatus.rejected:
        return isDark ? const Color(0xFFD32F2F) : Colors.red;
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
    final statusColor = _getStatusColor(context, application.status);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ApplicationDetailsScreen(application: application),
          ),
        );
        onUpdate();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? colorScheme.outlineVariant
                : colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  application.companyName.isNotEmpty
                      ? application.companyName[0].toUpperCase()
                      : '?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.jobTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      application.companyName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? statusColor.withValues(alpha: 0.2)
                      : statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _getStatusText(application.status),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark ? colorScheme.onSurface : statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  application.isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: application.isFavorite ? colorScheme.primary : colorScheme.onSurfaceVariant,
                onPressed: () async {
                  final storageService = LocalStorageService();
                  final updatedApp = application.copyWith(isFavorite: !application.isFavorite);
                  final apps = await storageService.loadApplications();
                  final index = apps.indexWhere((a) => a.id == updatedApp.id);
                  if (index != -1) {
                    apps[index] = updatedApp;
                    await storageService.saveApplications(apps);
                    onUpdate();
                  }
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: colorScheme.onSurfaceVariant,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddApplicationScreen(application: application),
                    ),
                  );
                  if (result == true) {
                    onUpdate();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  application.location.isNotEmpty
                      ? application.location
                      : 'Not specified',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${application.applicationDate.month}/${application.applicationDate.day}/${application.applicationDate.year}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
