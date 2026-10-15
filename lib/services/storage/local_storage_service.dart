import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_application_tracker/features/applications/models/job_application.dart';
import 'package:job_application_tracker/services/storage/web_storage.dart';

class LocalStorageService {
  static const String _primaryKey = 'job_applications';
  static const String _applicationsDataKey = 'job_applications_data';
  static const String _v2ApplicationsKey = 'job_applications_v2';
  static const String _themeModeKey = 'theme_mode';

  /// Loads all saved job applications from persistent local storage.
  /// Seamlessly synchronizes SharedPreferences and browser window.localStorage.
  /// Checks primary and legacy keys, ensuring no existing data is ever lost.
  Future<List<JobApplication>> loadApplications() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.reload();
    } catch (e) {
      debugPrint('SharedPreferences reload notice: $e');
    }

    final candidateKeys = [
      _primaryKey,
      _applicationsDataKey,
      _v2ApplicationsKey,
    ];

    List<dynamic>? rawList;
    bool needsMigration = false;

    // 1. First, check SharedPreferences candidate keys
    for (final key in candidateKeys) {
      if (!prefs.containsKey(key)) continue;

      try {
        final Object? rawVal = prefs.get(key);
        if (rawVal is String && rawVal.trim().isNotEmpty) {
          final decoded = jsonDecode(rawVal);
          if (decoded is List) {
            rawList = decoded;
            if (key != _primaryKey) {
              needsMigration = true;
            }
            break;
          }
        } else if (rawVal is List) {
          rawList = rawVal;
          if (key != _primaryKey) {
            needsMigration = true;
          }
          break;
        }
      } catch (e) {
        debugPrint('Failed to decode SharedPreferences key $key: $e');
      }

      // Fallback check in case key was saved as a List<String>
      try {
        final List<String>? strList = prefs.getStringList(key);
        if (strList != null) {
          rawList = strList;
          if (key != _primaryKey) {
            needsMigration = true;
          }
          break;
        }
      } catch (e) {
        debugPrint(
          'Failed to read string list from SharedPreferences key $key: $e',
        );
      }
    }

    // 2. If SharedPreferences returned nothing (e.g. on Chrome Web if cache was unpopulated),
    // directly inspect browser window.localStorage for both prefixed and unprefixed keys
    if (rawList == null) {
      final webCandidateKeys = [
        'flutter.$_primaryKey',
        _primaryKey,
        'flutter.$_applicationsDataKey',
        _applicationsDataKey,
        'flutter.$_v2ApplicationsKey',
        _v2ApplicationsKey,
      ];

      for (final webKey in webCandidateKeys) {
        try {
          final String? rawStored = getBrowserLocalStorageItem(webKey);
          if (rawStored != null && rawStored.trim().isNotEmpty) {
            final decodedFirst = jsonDecode(rawStored);
            if (decodedFirst is List) {
              rawList = decodedFirst;
              needsMigration = true;
              break;
            } else if (decodedFirst is String &&
                decodedFirst.trim().isNotEmpty) {
              final decodedSecond = jsonDecode(decodedFirst);
              if (decodedSecond is List) {
                rawList = decodedSecond;
                needsMigration = true;
                break;
              }
            }
          }
        } catch (e) {
          debugPrint('Failed to decode browser localStorage key $webKey: $e');
        }
      }
    }

    if (rawList == null || rawList.isEmpty) {
      return [];
    }

    final List<JobApplication> parsedApplications = [];
    final Set<String> seenIds = {};

    for (final item in rawList) {
      try {
        Map<String, dynamic>? itemMap;
        if (item is Map) {
          itemMap = Map<String, dynamic>.from(item);
        } else if (item is String && item.trim().isNotEmpty) {
          final decodedItem = jsonDecode(item);
          if (decodedItem is Map) {
            itemMap = Map<String, dynamic>.from(decodedItem);
          }
        }

        if (itemMap != null) {
          final app = JobApplication.fromJson(itemMap);
          if (app.id.isNotEmpty && !seenIds.contains(app.id)) {
            seenIds.add(app.id);
            parsedApplications.add(app);
          } else if (app.id.isEmpty) {
            parsedApplications.add(app);
          }
        }
      } catch (e) {
        debugPrint('Error parsing application item: $e');
      }
    }

    // Auto-migrate to canonical keys in both SharedPreferences and browser storage ONLY when migrating
    if (needsMigration && parsedApplications.isNotEmpty) {
      try {
        await saveApplications(parsedApplications);
      } catch (e) {
        debugPrint('Notice: could not auto-migrate to primary key: $e');
      }
    }

    return parsedApplications;
  }

  /// Persists the complete updated list of applications to persistent storage.
  /// Writes simultaneously to SharedPreferences and direct browser localStorage.
  /// Throws an exception if writing fails so callers can report real errors.
  Future<void> saveApplications(List<JobApplication> applications) async {
    final prefs = await SharedPreferences.getInstance();

    final List<Map<String, dynamic>> jsonList = applications
        .map((app) => app.toJson())
        .toList();
    final String jsonString = jsonEncode(jsonList);

    // 1. Save to SharedPreferences
    final bool successPrimary = await prefs.setString(_primaryKey, jsonString);
    await prefs.setString(_applicationsDataKey, jsonString);

    // 2. Direct browser localStorage persistence for Chrome Web
    try {
      // Standard SharedPreferences Web format (JSON encoded string)
      setBrowserLocalStorageItem(
        'flutter.$_primaryKey',
        jsonEncode(jsonString),
      );
      setBrowserLocalStorageItem(
        'flutter.$_applicationsDataKey',
        jsonEncode(jsonString),
      );
      // Direct raw JSON format for resilience
      setBrowserLocalStorageItem(_primaryKey, jsonString);
      setBrowserLocalStorageItem(_applicationsDataKey, jsonString);
    } catch (e) {
      debugPrint('Direct browser localStorage write error: $e');
    }

    if (!successPrimary && !kIsWeb) {
      throw Exception('Failed to persist applications to local storage.');
    }
  }

  /// Deletes a single application by ID and persists the updated list.
  Future<void> deleteApplication(String id) async {
    final apps = await loadApplications();
    final initialLength = apps.length;
    apps.removeWhere((app) => app.id == id);
    if (apps.length != initialLength) {
      await saveApplications(apps);
    }
  }

  /// Permanently removes all saved job application records from persistent storage.
  Future<void> deleteAllApplications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_primaryKey);
    await prefs.remove(_applicationsDataKey);
    await prefs.remove(_v2ApplicationsKey);

    try {
      removeBrowserLocalStorageItem('flutter.$_primaryKey');
      removeBrowserLocalStorageItem(_primaryKey);
      removeBrowserLocalStorageItem('flutter.$_applicationsDataKey');
      removeBrowserLocalStorageItem(_applicationsDataKey);
      removeBrowserLocalStorageItem('flutter.$_v2ApplicationsKey');
      removeBrowserLocalStorageItem(_v2ApplicationsKey);
    } catch (_) {}
  }

  /// Loads the persisted theme mode preference.
  Future<String?> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await prefs.reload();
    } catch (_) {}
    final val = prefs.getString(_themeModeKey);
    if (val != null && val.isNotEmpty) {
      return val;
    }

    // Fallback to browser localStorage
    final webVal =
        getBrowserLocalStorageItem('flutter.$_themeModeKey') ??
        getBrowserLocalStorageItem(_themeModeKey);
    if (webVal != null && webVal.isNotEmpty) {
      try {
        final decoded = jsonDecode(webVal);
        return decoded is String ? decoded : webVal;
      } catch (_) {
        return webVal;
      }
    }
    return null;
  }

  /// Saves the theme mode preference.
  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    final bool success = await prefs.setString(_themeModeKey, mode);

    try {
      setBrowserLocalStorageItem('flutter.$_themeModeKey', jsonEncode(mode));
      setBrowserLocalStorageItem(_themeModeKey, mode);
    } catch (_) {}

    if (!success && !kIsWeb) {
      throw Exception('Failed to save theme mode.');
    }
  }
}
