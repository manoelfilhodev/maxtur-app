import 'package:flutter/material.dart';
import 'package:systex_frotas/core/theme/dark_glass_theme.dart';
import 'package:systex_frotas/modules/checklist/screens/checklist_home_screen.dart';
import 'package:systex_frotas/modules/home/screens/dashboard_home_screen.dart';
import 'package:systex_frotas/modules/home/screens/home_screen.dart';
import 'package:systex_frotas/modules/viagens/screens/viagens_menu_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  late final List<Widget> _tabs = <Widget>[
    const DashboardHomeScreen(),
    const ChecklistHomeScreen(),
    const ViagensMenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkGlassTheme.bg,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Systex Frotas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            SizedBox(height: 1),
            Text('Mobilidade corporativa', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                HomeScreen.performLogout(context);
                return;
              }
              if (value == 'about') {
                showAboutDialog(
                  context: context,
                  applicationName: 'Systex Frotas',
                  applicationVersion: 'MVP',
                  children: const [
                    Text('Aplicativo de mobilidade corporativa e checklists de veículo.'),
                  ],
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'about', child: Text('Sobre')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: _ShellBottomNav(
        currentIndex: _index,
        onChanged: (value) => setState(() => _index = value),
      ),
    );
  }
}

class _ShellBottomNav extends StatelessWidget {
  const _ShellBottomNav({
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = <({IconData icon, String label})>[
      (icon: Icons.home_rounded, label: 'Início'),
      (icon: Icons.fact_check_rounded, label: 'Checklist'),
      (icon: Icons.local_taxi_rounded, label: 'Viagens'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: DarkGlassTheme.surface,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.10))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onChanged(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(items[i].icon, color: selected ? DarkGlassTheme.primary : Colors.white70),
                        const SizedBox(height: 3),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            fontSize: 11,
                            color: selected ? Colors.white : Colors.white70,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 4,
                          width: selected ? 30 : 16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: selected ? DarkGlassTheme.primary : Colors.white24,
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: DarkGlassTheme.primary.withValues(alpha: 0.45),
                                      blurRadius: 12,
                                      spreadRadius: 0.5,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
