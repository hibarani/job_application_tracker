enum ApplicationStatus { applied, screening, interview, offer, rejected }

extension ApplicationStatusX on ApplicationStatus {
  String get displayName {
    switch (this) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.screening:
        return 'Screening';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.offer:
        return 'Offer';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }
}

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
    ApplicationStatus parsedStatus = ApplicationStatus.applied;
    final dynamic rawStatus = json['status'];
    if (rawStatus is String) {
      try {
        parsedStatus = ApplicationStatus.values.firstWhere(
          (e) => e.name.toLowerCase() == rawStatus.toLowerCase(),
          orElse: () => ApplicationStatus.applied,
        );
      } catch (_) {
        parsedStatus = ApplicationStatus.applied;
      }
    }

    DateTime parsedAppDate = DateTime.now();
    final dynamic rawAppDate = json['applicationDate'];
    if (rawAppDate is String && rawAppDate.isNotEmpty) {
      parsedAppDate = DateTime.tryParse(rawAppDate) ?? DateTime.now();
    } else if (rawAppDate is DateTime) {
      parsedAppDate = rawAppDate;
    }

    DateTime? parsedInterviewDate;
    final dynamic rawInterviewDate = json['interviewDate'];
    if (rawInterviewDate is String && rawInterviewDate.isNotEmpty) {
      parsedInterviewDate = DateTime.tryParse(rawInterviewDate);
    } else if (rawInterviewDate is DateTime) {
      parsedInterviewDate = rawInterviewDate;
    }

    double? parsedSalary;
    final dynamic rawSalary = json['salary'];
    if (rawSalary is num) {
      parsedSalary = rawSalary.toDouble();
    } else if (rawSalary is String && rawSalary.trim().isNotEmpty) {
      final sanitized = rawSalary.replaceAll(RegExp(r'[^0-9.]'), '');
      parsedSalary = double.tryParse(sanitized);
    }

    bool parsedIsFavorite = false;
    final dynamic rawFav = json['isFavorite'];
    if (rawFav is bool) {
      parsedIsFavorite = rawFav;
    } else if (rawFav == 1 || rawFav == 'true') {
      parsedIsFavorite = true;
    }

    final dynamic rawId = json['id'];
    final String parsedId = rawId != null && rawId.toString().isNotEmpty
        ? rawId.toString()
        : DateTime.now().millisecondsSinceEpoch.toString();

    return JobApplication(
      id: parsedId,
      companyName: json['companyName']?.toString() ?? '',
      jobTitle: json['jobTitle']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      applicationDate: parsedAppDate,
      status: parsedStatus,
      jobUrl: json['jobUrl']?.toString() ?? '',
      salary: parsedSalary,
      interviewDate: parsedInterviewDate,
      notes: json['notes']?.toString() ?? '',
      contactName: json['contactName']?.toString(),
      isFavorite: parsedIsFavorite,
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
