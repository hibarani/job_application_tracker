import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_application_tracker/features/applications/models/job_application.dart';

class LocalStorageService {
  static const String _applicationsKey = 'job_applications';

  Future<List<JobApplication>> loadApplications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_applicationsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => JobApplication.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If parsing fails, return an empty list to avoid crashing
      return [];
    }
  }

  Future<void> saveApplications(List<JobApplication> applications) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = applications
        .map((app) => app.toJson())
        .toList();

    final String jsonString = jsonEncode(jsonList);
    await prefs.setString(_applicationsKey, jsonString);
  }

  Future<void> deleteAllApplications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_applicationsKey);
  }
}
