import 'package:flutter/material.dart';
import 'package:systex_frotas/modules/auth/auth_navigation.dart';
import 'package:systex_frotas/modules/auth/screens/login_screen.dart';
import 'package:systex_frotas/modules/auth/services/auth_service.dart';
import 'package:systex_frotas/modules/auth/services/auth_storage.dart';

class AppBootScreen extends StatefulWidget {
  const AppBootScreen({super.key});

  @override
  State<AppBootScreen> createState() => _AppBootScreenState();
}

class _AppBootScreenState extends State<AppBootScreen> {
  final AuthService _service = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    try {
      final hasToken = await _service.hasSession();
      if (!hasToken) {
        await AuthStorage.clearSession(clearProfile: false);
        if (!mounted) return;
        _goTo(const LoginScreen());
        return;
      }

      final me = await _service.me();
      if (!mounted) return;
      _goTo(buildHomeForRole(me));
    } catch (_) {
      await AuthStorage.clearSession(clearProfile: false);
      if (!mounted) return;
      _goTo(const LoginScreen());
    }
  }

  void _goTo(Widget screen) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
