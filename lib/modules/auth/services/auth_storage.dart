import 'package:hive_flutter/hive_flutter.dart';
import 'package:systex_frotas/core/storage/secure_storage.dart';

class AuthStorage {
  static const String _boxName = 'auth_box';
  static const String _tokenKey = 'token';
  static const String _lastEmailKey = 'last_email';
  static const String _lastNomeKey = 'last_nome';

  static Box<String>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<String>(_boxName);
  }

  static Future<String?> getToken() => SecureStorage.read(_tokenKey);
  static Future<void> saveToken(String token) => SecureStorage.write(_tokenKey, token);
  static Future<void> clearToken() => SecureStorage.delete(_tokenKey);

  static String? getLastEmail() => _box?.get(_lastEmailKey);
  static Future<void> saveLastEmail(String email) async => _box?.put(_lastEmailKey, email);

  static String? getLastNome() => _box?.get(_lastNomeKey);
  static Future<void> saveLastNome(String nome) async => _box?.put(_lastNomeKey, nome);

  static Future<void> clearSession({bool clearProfile = true}) async {
    await clearToken();
    if (!clearProfile) return;
    await Future.wait<void>([
      _box?.delete(_lastEmailKey) ?? Future<void>.value(),
      _box?.delete(_lastNomeKey) ?? Future<void>.value(),
    ]);
  }
}
