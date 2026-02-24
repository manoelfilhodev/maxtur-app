import 'package:flutter/material.dart';

class DgBadge extends StatelessWidget {
  const DgBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final config = _resolve(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: config.color, width: 1),
      ),
      child: Text(
        config.label,
        style: TextStyle(color: config.color, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }

  ({Color color, String label}) _resolve(String value) {
    final s = value.toLowerCase().trim();
    if (s.contains('aprova')) return (color: const Color(0xFF43D17A), label: value);
    if (s.contains('nega') || s.contains('rejeit')) return (color: const Color(0xFFFF5A5A), label: value);
    if (s.contains('cancel')) return (color: const Color(0xFF8A8A92), label: value);
    if (s.contains('pend')) return (color: const Color(0xFFFFC85A), label: value);
    return (color: const Color(0xFFFFC85A), label: value.isEmpty ? 'pendente' : value);
  }
}

