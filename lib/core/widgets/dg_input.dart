import 'package:flutter/material.dart';
import 'package:systex_frotas/core/theme/dark_glass_theme.dart';

class DgInput extends StatelessWidget {
  const DgInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    this.obscureText = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      onChanged: onChanged,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        fillColor: DarkGlassTheme.surfaceAlt,
        border: _border(Colors.white.withValues(alpha: 0.14)),
        enabledBorder: _border(Colors.white.withValues(alpha: 0.14)),
        focusedBorder: _border(DarkGlassTheme.primary),
      ),
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: 1.2),
    );
  }
}

