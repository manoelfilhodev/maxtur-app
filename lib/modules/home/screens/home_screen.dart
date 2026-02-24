import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_toast.dart';
import 'package:systex_frotas/modules/auth/screens/login_screen.dart';
import 'package:systex_frotas/modules/auth/services/auth_service.dart';
import 'package:systex_frotas/modules/home/screens/app_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static Future<void> performLogout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    DgToast.show(context, 'Sessão encerrada.');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const AppShell();
  }
}
