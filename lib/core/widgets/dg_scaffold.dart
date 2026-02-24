import 'package:flutter/material.dart';
import 'package:systex_frotas/core/theme/dark_glass_theme.dart';

class DgScaffold extends StatelessWidget {
  const DgScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.padding = const EdgeInsets.all(16),
  });

  final PreferredSizeWidget? appBar;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: DarkGlassTheme.bg,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -30,
            child: _Glow(
              size: 220,
              color: DarkGlassTheme.primary.withValues(alpha: 0.15),
            ),
          ),
          Positioned(
            bottom: -130,
            left: -20,
            child: _Glow(
              size: 260,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

