import 'package:flutter/material.dart';
import 'package:job_application_tracker/features/applications/models/job_application.dart';
import 'package:job_application_tracker/services/storage/local_storage_service.dart';

class AddApplicationScreen extends StatefulWidget {
  final JobApplication? application;

  const AddApplicationScreen({super.key, this.application});

  @override
  State<AddApplicationScreen> createState() => _AddApplicationScreenState();
}

class _AddApplicationScreenState extends State<AddApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final LocalStorageService _storageService = LocalStorageService();
  bool _isSaving = false;

  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _jobUrlController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _applicationDate = DateTime.now();
  DateTime? _interviewDate;
  ApplicationStatus _status = ApplicationStatus.applied;

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

  @override
  void initState() {
    super.initState();
    if (widget.application != null) {
      final app = widget.application!;
      _companyController.text = app.companyName;
      _jobTitleController.text = app.jobTitle;
      _locationController.text = app.location;
      _jobUrlController.text = app.jobUrl;
      _salaryController.text = app.salary?.toString() ?? '';
      _contactController.text = app.contactName ?? '';
      _notesController.text = app.notes;
      _applicationDate = app.applicationDate;
      _interviewDate = app.interviewDate;
      _status = app.status;
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _jobTitleController.dispose();
    _locationController.dispose();
    _jobUrlController.dispose();
    _salaryController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isApplicationDate) async {
    final DateTime initialDate = isApplicationDate
        ? _applicationDate
        : (_interviewDate ?? DateTime.now());
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surfaceContainerHighest,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isApplicationDate) {
          _applicationDate = picked;
        } else {
          _interviewDate = picked;
        }
      });
    }
  }

  String _getStatusText(ApplicationStatus status) {
    final text = status.name;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> _saveApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final existingApps = await _storageService.loadApplications();

      double? parsedSalary;
      if (_salaryController.text.trim().isNotEmpty) {
        final numericString = _salaryController.text.replaceAll(
          RegExp(r'[^0-9.]'),
          '',
        );
        parsedSalary = double.tryParse(numericString);
      }

      final newApp = JobApplication(
        id: widget.application?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        companyName: _companyController.text.trim(),
        jobTitle: _jobTitleController.text.trim(),
        location: _locationController.text.trim(),
        applicationDate: _applicationDate,
        status: _status,
        jobUrl: _jobUrlController.text.trim(),
        salary: parsedSalary,
        interviewDate: _interviewDate,
        notes: _notesController.text.trim(),
        contactName: _contactController.text.trim(),
        isFavorite: widget.application?.isFavorite ?? false,
      );

      if (widget.application != null) {
        final index = existingApps.indexWhere((a) => a.id == widget.application!.id);
        if (index != -1) {
          existingApps[index] = newApp;
        } else {
          existingApps.add(newApp);
        }
      } else {
        existingApps.add(newApp);
      }
      await _storageService.saveApplications(existingApps);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save the application. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            validator: (value) {
              if (isRequired && (value == null || value.trim().isEmpty)) {
                return '$label is required.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.application != null ? 'Edit Application' : 'Add Application',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _companyController,
                  label: 'Company Name',
                  hint: 'e.g. Google',
                  isRequired: true,
                ),
                _buildTextField(
                  controller: _jobTitleController,
                  label: 'Job Title',
                  hint: 'e.g. Flutter Developer',
                  isRequired: true,
                ),
                _buildTextField(
                  controller: _locationController,
                  label: 'Location',
                  hint: 'e.g. Remote / Lahore',
                  isRequired: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Application Date',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _selectDate(context, true),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 18,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatDate(_applicationDate),
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<ApplicationStatus>(
                              initialValue: _status,
                              dropdownColor:
                                  colorScheme.surfaceContainerHighest,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              items: ApplicationStatus.values.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(_getStatusText(status)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _status = value;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 48),
                Text(
                  'Optional Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _jobUrlController,
                  label: 'Job URL',
                  hint: 'https://example.com/job',
                  keyboardType: TextInputType.url,
                ),
                _buildTextField(
                  controller: _salaryController,
                  label: 'Salary',
                  hint: 'e.g. 150,000 PKR',
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Interview Date',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context, false),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _interviewDate != null
                                    ? _formatDate(_interviewDate!)
                                    : 'Select Date (Optional)',
                                style: TextStyle(
                                  color: _interviewDate != null
                                      ? colorScheme.onSurface
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const Spacer(),
                              if (_interviewDate != null)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _interviewDate = null;
                                    });
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTextField(
                  controller: _contactController,
                  label: 'Contact Person',
                  hint: 'e.g. Sarah Khan',
                ),
                _buildTextField(
                  controller: _notesController,
                  label: 'Notes',
                  hint: 'Add any useful notes about this application...',
                  maxLines: 4,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveApplication,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Text(
                            widget.application != null ? 'Update Application' : 'Save Application',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 40), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}
