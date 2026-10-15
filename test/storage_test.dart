import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_application_tracker/services/storage/local_storage_service.dart';
import 'package:job_application_tracker/features/applications/models/job_application.dart';

void main() {
  group('LocalStorageService Comprehensive Persistence Tests', () {
    late LocalStorageService storage;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage = LocalStorageService();
    });

    test('Initial load returns empty list when no data is stored', () async {
      final apps = await storage.loadApplications();
      expect(apps, isEmpty);
    });

    test('Saving and reloading applications preserves all fields', () async {
      final now = DateTime.now();
      final app1 = JobApplication(
        id: 'app_1',
        companyName: 'Acme Corp',
        jobTitle: 'Senior Flutter Developer',
        location: 'Remote, US',
        applicationDate: now,
        status: ApplicationStatus.interview,
        jobUrl: 'https://acme.com/jobs/1',
        salary: 135000.0,
        interviewDate: now.add(const Duration(days: 3)),
        notes: 'Round 1 technical screen completed',
        contactName: 'Jane Smith',
        isFavorite: true,
      );

      await storage.saveApplications([app1]);

      final loaded = await storage.loadApplications();
      expect(loaded.length, 1);
      final item = loaded.first;
      expect(item.id, 'app_1');
      expect(item.companyName, 'Acme Corp');
      expect(item.jobTitle, 'Senior Flutter Developer');
      expect(item.location, 'Remote, US');
      expect(item.status, ApplicationStatus.interview);
      expect(item.jobUrl, 'https://acme.com/jobs/1');
      expect(item.salary, 135000.0);
      expect(item.notes, 'Round 1 technical screen completed');
      expect(item.contactName, 'Jane Smith');
      expect(item.isFavorite, isTrue);
      expect(item.interviewDate, isNotNull);
    });

    test(
      'Adding and editing applications updates persistent storage',
      () async {
        final app1 = JobApplication(
          id: '1',
          companyName: 'Company A',
          jobTitle: 'Engineer',
          location: 'NY',
          applicationDate: DateTime.now(),
          status: ApplicationStatus.applied,
          jobUrl: '',
        );
        await storage.saveApplications([app1]);

        // Edit app1
        final updatedApp1 = app1.copyWith(
          jobTitle: 'Lead Engineer',
          status: ApplicationStatus.offer,
          isFavorite: true,
        );
        final app2 = JobApplication(
          id: '2',
          companyName: 'Company B',
          jobTitle: 'Designer',
          location: 'SF',
          applicationDate: DateTime.now(),
          status: ApplicationStatus.applied,
          jobUrl: '',
        );

        await storage.saveApplications([updatedApp1, app2]);

        final loaded = await storage.loadApplications();
        expect(loaded.length, 2);
        expect(loaded[0].jobTitle, 'Lead Engineer');
        expect(loaded[0].status, ApplicationStatus.offer);
        expect(loaded[0].isFavorite, isTrue);
        expect(loaded[1].companyName, 'Company B');
      },
    );

    test('Deleting an application persists the updated list', () async {
      final app1 = JobApplication(
        id: 'del_1',
        companyName: 'To Keep',
        jobTitle: 'Dev',
        location: 'Remote',
        applicationDate: DateTime.now(),
        status: ApplicationStatus.applied,
        jobUrl: '',
      );
      final app2 = JobApplication(
        id: 'del_2',
        companyName: 'To Delete',
        jobTitle: 'Manager',
        location: 'Remote',
        applicationDate: DateTime.now(),
        status: ApplicationStatus.applied,
        jobUrl: '',
      );

      await storage.saveApplications([app1, app2]);
      expect((await storage.loadApplications()).length, 2);

      await storage.deleteApplication('del_2');

      final loaded = await storage.loadApplications();
      expect(loaded.length, 1);
      expect(loaded.first.id, 'del_1');
      expect(loaded.first.companyName, 'To Keep');
    });

    test('Migrates seamlessly from legacy key job_applications_data', () async {
      final legacyApp = {
        'id': 'legacy_99',
        'companyName': 'Legacy Corp',
        'jobTitle': 'Architect',
        'location': 'Austin, TX',
        'applicationDate': DateTime.now().toIso8601String(),
        'status': 'screening',
        'jobUrl': 'https://legacy.com',
        'salary': 150000,
        'notes': 'Migrated test',
        'contactName': 'Bob',
        'isFavorite': true,
      };

      SharedPreferences.setMockInitialValues({
        'job_applications_data': jsonEncode([legacyApp]),
      });

      final loaded = await storage.loadApplications();
      expect(loaded.length, 1);
      expect(loaded.first.id, 'legacy_99');
      expect(loaded.first.companyName, 'Legacy Corp');
      expect(loaded.first.status, ApplicationStatus.screening);
      expect(loaded.first.isFavorite, isTrue);
    });

    test('Migrates seamlessly from legacy key job_applications_v2', () async {
      final legacyApp = {
        'id': 'v2_42',
        'companyName': 'V2 Enterprise',
        'jobTitle': 'Specialist',
        'location': 'Seattle',
        'applicationDate': DateTime.now().toIso8601String(),
        'status': 'offer',
        'jobUrl': '',
        'salary': '125000',
        'isFavorite': 1,
      };

      SharedPreferences.setMockInitialValues({
        'job_applications_v2': jsonEncode([legacyApp]),
      });

      final loaded = await storage.loadApplications();
      expect(loaded.length, 1);
      expect(loaded.first.id, 'v2_42');
      expect(loaded.first.companyName, 'V2 Enterprise');
      expect(loaded.first.salary, 125000.0);
      expect(loaded.first.isFavorite, isTrue);
    });

    test(
      'Handles resilient parsing of corrupted and varied field types',
      () async {
        final mixedData = [
          {
            'id': 'mixed_1',
            'companyName': 'Robust Corp',
            'jobTitle': 'QA',
            'salary': '\$110,000.50', // String formatted currency
            'status': 'UNKNOWN_STATUS', // Unknown status
            'isFavorite': 'true', // String boolean
          },
          {
            // Completely minimal entry
            'companyName': 'Minimal Inc',
          },
        ];

        SharedPreferences.setMockInitialValues({
          'job_applications': jsonEncode(mixedData),
        });

        final loaded = await storage.loadApplications();
        expect(loaded.length, 2);
        expect(loaded[0].id, 'mixed_1');
        expect(loaded[0].salary, 110000.50);
        expect(loaded[0].status, ApplicationStatus.applied);
        expect(loaded[0].isFavorite, isTrue);
        expect(loaded[1].companyName, 'Minimal Inc');
        expect(loaded[1].id, isNotEmpty);
      },
    );

    test('Theme mode persistence works properly', () async {
      expect(await storage.loadThemeMode(), isNull);
      await storage.saveThemeMode('dark');
      expect(await storage.loadThemeMode(), 'dark');
      await storage.saveThemeMode('light');
      expect(await storage.loadThemeMode(), 'light');
    });

    test('deleteAllApplications wipes all data keys', () async {
      await storage.saveApplications([
        JobApplication(
          id: 'test_wipe',
          companyName: 'Wipe',
          jobTitle: 'Dev',
          location: 'Any',
          applicationDate: DateTime.now(),
          status: ApplicationStatus.applied,
          jobUrl: '',
        ),
      ]);
      expect((await storage.loadApplications()).length, 1);

      await storage.deleteAllApplications();
      expect((await storage.loadApplications()), isEmpty);
    });

    test(
      'Regression: empty primary list [] does not resurrect stale legacy keys',
      () async {
        // Setup: primary key is explicitly an empty list, but legacy key has stale data
        final staleLegacyApp = {
          'id': 'stale_1',
          'companyName': 'Old Stale Corp',
          'jobTitle': 'Stale Job',
          'location': 'Nowhere',
          'applicationDate': DateTime.now().toIso8601String(),
          'status': 'applied',
          'jobUrl': '',
        };

        SharedPreferences.setMockInitialValues({
          'job_applications': jsonEncode([]),
          'job_applications_data': jsonEncode([staleLegacyApp]),
        });

        final loaded = await storage.loadApplications();
        // Must NOT restore staleLegacyApp because primary key was explicitly empty
        expect(loaded, isEmpty);
      },
    );

    test(
      'Regression: deleting the last remaining application leaves storage cleanly empty',
      () async {
        final app = JobApplication(
          id: 'sole_app',
          companyName: 'Sole Company',
          jobTitle: 'Sole Role',
          location: 'Remote',
          applicationDate: DateTime.now(),
          status: ApplicationStatus.applied,
          jobUrl: '',
        );

        await storage.saveApplications([app]);
        expect((await storage.loadApplications()).length, 1);

        await storage.deleteApplication('sole_app');
        final loaded = await storage.loadApplications();
        expect(loaded, isEmpty);
      },
    );
  });
}
