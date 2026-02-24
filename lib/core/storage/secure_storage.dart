import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  static Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {}
  }

  static Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {}
  }
}
