import 'package:flutter/material.dart';
import 'package:systex_frotas/core/theme/dark_glass_theme.dart';
import 'package:systex_frotas/modules/auth/screens/app_boot_screen.dart';
import 'package:systex_frotas/modules/auth/services/session_manager.dart';

class SystexFrotasApp extends StatelessWidget {
  const SystexFrotasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Systex Frotas',
      debugShowCheckedModeBanner: false,
      navigatorKey: SessionManager.navigatorKey,
      theme: DarkGlassTheme.theme,
      home: const AppBootScreen(),
    );
  }
}
