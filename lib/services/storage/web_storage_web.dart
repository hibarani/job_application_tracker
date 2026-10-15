import 'package:web/web.dart' as web;

/// Browser local storage implementation for Flutter Web using HTML5 window.localStorage.
String? getBrowserLocalStorageItem(String key) {
  try {
    return web.window.localStorage.getItem(key);
  } catch (_) {
    return null;
  }
}

void setBrowserLocalStorageItem(String key, String value) {
  try {
    web.window.localStorage.setItem(key, value);
  } catch (_) {}
}

void removeBrowserLocalStorageItem(String key) {
  try {
    web.window.localStorage.removeItem(key);
  } catch (_) {}
}
