enum ApplicationStatus { applied, screening, interview, offer, rejected }

class JobApplication {
  final String id;
  final String companyName;
  final String jobTitle;
  final String location;
  final DateTime applicationDate;
  final ApplicationStatus status;
  final String jobUrl;
  final double? salary;
  final DateTime? interviewDate;
  final String notes;
  final String? contactName;
  final bool isFavorite;

  const JobApplication({
    required this.id,
    required this.companyName,
    required this.jobTitle,
    required this.location,
    required this.applicationDate,
    required this.status,
    required this.jobUrl,
    this.salary,
    this.interviewDate,
    this.notes = '',
    this.contactName,
    this.isFavorite = false,
  });

  JobApplication copyWith({
    String? id,
    String? companyName,
    String? jobTitle,
    String? location,
    DateTime? applicationDate,
    ApplicationStatus? status,
    String? jobUrl,
    double? salary,
    DateTime? interviewDate,
    String? notes,
    String? contactName,
    bool? isFavorite,
  }) {
    return JobApplication(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      jobTitle: jobTitle ?? this.jobTitle,
      location: location ?? this.location,
      applicationDate: applicationDate ?? this.applicationDate,
      status: status ?? this.status,
      jobUrl: jobUrl ?? this.jobUrl,
      salary: salary ?? this.salary,
      interviewDate: interviewDate ?? this.interviewDate,
      notes: notes ?? this.notes,
      contactName: contactName ?? this.contactName,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'jobTitle': jobTitle,
      'location': location,
      'applicationDate': applicationDate.toIso8601String(),
      'status': status.name,
      'jobUrl': jobUrl,
      'salary': salary,
      'interviewDate': interviewDate?.toIso8601String(),
      'notes': notes,
      'contactName': contactName,
      'isFavorite': isFavorite,
    };
  }

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    ApplicationStatus parsedStatus;
    try {
      parsedStatus = ApplicationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ApplicationStatus.applied,
      );
    } catch (_) {
      parsedStatus = ApplicationStatus.applied;
    }

    return JobApplication(
      id: json['id'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      jobTitle: json['jobTitle'] as String? ?? '',
      location: json['location'] as String? ?? '',
      applicationDate: json['applicationDate'] != null 
          ? DateTime.parse(json['applicationDate'] as String) 
          : DateTime.now(),
      status: parsedStatus,
      jobUrl: json['jobUrl'] as String? ?? '',
      salary: (json['salary'] as num?)?.toDouble(),
      interviewDate: json['interviewDate'] != null
          ? DateTime.parse(json['interviewDate'] as String)
          : null,
      notes: json['notes'] as String? ?? '',
      contactName: json['contactName'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobApplication &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
