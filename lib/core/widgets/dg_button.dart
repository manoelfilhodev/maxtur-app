import 'package:flutter/material.dart';
import 'package:systex_frotas/core/theme/dark_glass_theme.dart';

class DgButton extends StatelessWidget {
  const DgButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final disabled = loading || onPressed == null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: disabled
            ? const LinearGradient(colors: [Color(0xFF613131), Color(0xFF4D2424)])
            : const LinearGradient(colors: [Color(0xFFFF4040), Color(0xFFFF1D1D)]),
        boxShadow: disabled
            ? []
            : [
                BoxShadow(
                  color: DarkGlassTheme.primary.withValues(alpha: 0.45),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: disabled ? null : onPressed,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

