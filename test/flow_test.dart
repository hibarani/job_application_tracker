import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_application_tracker/services/storage/local_storage_service.dart';
import 'package:job_application_tracker/features/applications/models/job_application.dart';

void main() {
  test('Full add, persist, and restore cycle simulation', () async {
    SharedPreferences.setMockInitialValues({});
    
    final storageService = LocalStorageService();
    
    // Initial load
    final apps = await storageService.loadApplications();
    expect(apps, isEmpty);
    
    // Add application
    apps.add(JobApplication(
      id: 'flow_1',
      companyName: 'Flow Test Corp',
      jobTitle: 'Software Engineer',
      location: 'Remote',
      applicationDate: DateTime.now(),
      status: ApplicationStatus.applied,
      jobUrl: 'https://example.com',
    ));
    await storageService.saveApplications(apps);
    
    // Simulate complete app close and reopen by instantiating a fresh service instance
    final freshStorageService = LocalStorageService();
    final restoredApps = await freshStorageService.loadApplications();
    expect(restoredApps.length, 1);
    expect(restoredApps.first.id, 'flow_1');
    expect(restoredApps.first.companyName, 'Flow Test Corp');
  });
}
