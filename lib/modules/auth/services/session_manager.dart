import 'package:flutter/material.dart';
import 'package:systex_frotas/modules/auth/screens/login_screen.dart';
import 'package:systex_frotas/modules/auth/services/auth_storage.dart';

class SessionManager {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static bool _handlingUnauthorized = false;

  static Future<void> handleUnauthorized() async {
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;
    await AuthStorage.clearSession(clearProfile: false);
    final nav = navigatorKey.currentState;
    if (nav != null) {
      nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
    _handlingUnauthorized = false;
  }
}
