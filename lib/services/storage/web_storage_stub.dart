/// Stub implementation for platforms that do not support browser DOM storage (e.g. Dart VM, unit tests).
String? getBrowserLocalStorageItem(String key) => null;
void setBrowserLocalStorageItem(String key, String value) {}
void removeBrowserLocalStorageItem(String key) {}
