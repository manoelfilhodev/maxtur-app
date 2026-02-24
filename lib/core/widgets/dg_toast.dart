import 'package:flutter/material.dart';
import 'package:systex_frotas/core/theme/dark_glass_theme.dart';

class DgToast {
  static void show(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? const Color(0xFF481515) : const Color(0xFF18181A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isError ? Colors.redAccent.withValues(alpha: 0.55) : DarkGlassTheme.primary.withValues(alpha: 0.35),
          ),
        ),
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

