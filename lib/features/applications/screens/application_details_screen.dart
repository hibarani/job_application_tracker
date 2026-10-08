import 'package:flutter/material.dart';
import 'package:job_application_tracker/features/applications/models/job_application.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicationDetailsScreen extends StatelessWidget {
  final JobApplication application;

  const ApplicationDetailsScreen({super.key, required this.application});

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

  Future<void> _launchUrl(String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Ignore if URL is invalid
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF10152B);
    const surfaceColor = Color(0xFF3B3475);
    const borderColor = Color(0xFF4A4380);
    const coralAccent = Color(0xFFFF8A65);
    const violetAccent = Color(0xFF8175D6);
    const primaryText = Color(0xFFF7F3EA);
    const secondaryText = Color(0xFFB8B5CC);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Application Details', style: TextStyle(color: primaryText, fontWeight: FontWeight.w600)),
        backgroundColor: bgColor,
        iconTheme: const IconThemeData(color: primaryText),
        elevation: 0,
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
                      application.jobTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      application.companyName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: coralAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: secondaryText, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            application.location.isNotEmpty ? application.location : 'Location not specified',
                            style: const TextStyle(color: secondaryText),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(application.status).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getStatusColor(application.status).withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        _getStatusText(application.status),
                        style: TextStyle(
                          color: _getStatusColor(application.status),
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
                primaryText: primaryText,
                secondaryText: secondaryText,
                children: [
                  _buildInfoRow(Icons.calendar_today_outlined, 'Application Date', _formatDate(application.applicationDate), primaryText, secondaryText),
                  if (application.interviewDate != null) ...[
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.event_available_outlined, 'Interview Date', _formatDate(application.interviewDate!), primaryText, secondaryText),
                  ]
                ],
              ),
              const SizedBox(height: 24),

              // Job Information
              if (application.jobUrl.isNotEmpty || application.salary != null) ...[
                _buildSectionCard(
                  title: 'Job Information',
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  children: [
                    if (application.salary != null)
                      _buildInfoRow(Icons.attach_money_outlined, 'Salary', application.salary!.toString(), primaryText, secondaryText),
                    if (application.jobUrl.isNotEmpty && application.salary != null)
                      const SizedBox(height: 16),
                    if (application.jobUrl.isNotEmpty)
                      InkWell(
                        onTap: () => _launchUrl(application.jobUrl),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.link, color: violetAccent, size: 20),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Open Job Posting',
                                  style: TextStyle(color: violetAccent, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Icon(Icons.open_in_new, color: violetAccent, size: 16),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Contact Information
              if (application.contactName != null && application.contactName!.isNotEmpty) ...[
                _buildSectionCard(
                  title: 'Contact Information',
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  children: [
                    _buildInfoRow(Icons.person_outline, 'Contact Person', application.contactName!, primaryText, secondaryText),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Notes
              if (application.notes.isNotEmpty) ...[
                _buildSectionCard(
                  title: 'Notes',
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  children: [
                    Text(
                      application.notes,
                      style: const TextStyle(color: primaryText, height: 1.5),
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
    required Color primaryText,
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

  Widget _buildInfoRow(IconData icon, String label, String value, Color primaryText, Color secondaryText) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: secondaryText, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: secondaryText, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(color: primaryText, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
