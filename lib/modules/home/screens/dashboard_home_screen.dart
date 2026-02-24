import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_badge.dart';
import 'package:systex_frotas/core/widgets/dg_button.dart';
import 'package:systex_frotas/core/widgets/dg_card.dart';
import 'package:systex_frotas/core/widgets/dg_toast.dart';
import 'package:systex_frotas/modules/auth/services/auth_storage.dart';
import 'package:systex_frotas/modules/checklist/screens/checklist_home_screen.dart';
import 'package:systex_frotas/modules/checklist/services/checklist_api_service.dart';
import 'package:systex_frotas/modules/viagens/screens/viagem_minhas_screen.dart';
import 'package:systex_frotas/modules/viagens/screens/viagens_menu_screen.dart';
import 'package:systex_frotas/modules/viagens_uber/models/trip_draft.dart';
import 'package:systex_frotas/modules/viagens_uber/screens/trip_where_to_screen.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  bool _apiOnline = true;
  bool _show = false;
  String _nome = 'Operador';
  bool _hasRecents = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final nome = AuthStorage.getLastNome();
    final lastEmail = AuthStorage.getLastEmail();

    bool online = true;
    try {
      await ChecklistApiService().getAll();
    } catch (_) {
      online = false;
    }

    if (!mounted) return;
    setState(() {
      _nome = (nome == null || nome.trim().isEmpty) ? 'Operador' : nome.trim();
      _hasRecents = lastEmail != null && lastEmail.isNotEmpty;
      _apiOnline = online;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AnimatedBlock(
            index: 0,
            show: _show,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Boa noite,', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 3),
                      Text(
                        _nome,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                DgBadge(status: _apiOnline ? 'API online' : 'Offline'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _AnimatedBlock(
            index: 1,
            show: _show,
            child: DgCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.route_rounded, size: 42, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Solicitar viagem extra',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 4),
                            Text('Fluxo rápido estilo Uber'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DgButton(
                    label: 'Solicitar agora',
                    icon: Icons.local_taxi,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => TripWhereToScreen(draft: TripDraft())),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ViagemMinhasScreen()),
                      );
                    },
                    icon: const Icon(Icons.history_rounded),
                    label: const Text('Minhas solicitações'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _AnimatedBlock(
            index: 2,
            show: _show,
            child: const Text(
              'Ações rápidas',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          _AnimatedBlock(
            index: 3,
            show: _show,
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.15,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _QuickCard(
                  icon: Icons.fact_check_rounded,
                  title: 'Iniciar checklist',
                  subtitle: 'Inspeção do veículo',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChecklistHomeScreen()),
                  ),
                ),
                _QuickCard(
                  icon: Icons.local_taxi_rounded,
                  title: 'Viagens extras',
                  subtitle: 'Menu completo',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ViagensMenuScreen()),
                  ),
                ),
                _QuickCard(
                  icon: Icons.receipt_long_rounded,
                  title: 'Minhas solicitações',
                  subtitle: 'Histórico por e-mail',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ViagemMinhasScreen()),
                  ),
                ),
                _QuickCard(
                  icon: Icons.manage_accounts_rounded,
                  title: 'Config/Perfil',
                  subtitle: 'Preferências da conta',
                  onTap: () => DgToast.show(context, 'Em breve'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _AnimatedBlock(
            index: 4,
            show: _show,
            child: const Text(
              'Recentes',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          _AnimatedBlock(
            index: 5,
            show: _show,
            child: _hasRecents
                ? Column(
                    children: const [
                      _RecentTile(title: 'Última solicitação', subtitle: 'Rota corporativa - hoje', badge: 'pendente'),
                      SizedBox(height: 8),
                      _RecentTile(title: 'Último checklist', subtitle: 'Checklist diário do veículo'),
                    ],
                  )
                : DgCard(
                    child: Column(
                      children: const [
                        Icon(Icons.inbox_rounded, color: Colors.white70, size: 32),
                        SizedBox(height: 8),
                        Text('Sem atividades recentes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        SizedBox(height: 3),
                        Text('Faça uma solicitação ou checklist para ver aqui.'),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DgCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.chevron_right, color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  const _RecentTile({
    required this.title,
    required this.subtitle,
    this.badge,
  });

  final String title;
  final String subtitle;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return DgCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle),
              ],
            ),
          ),
          if (badge != null) DgBadge(status: badge!),
        ],
      ),
    );
  }
}

class _AnimatedBlock extends StatelessWidget {
  const _AnimatedBlock({
    required this.index,
    required this.show,
    required this.child,
  });

  final int index;
  final bool show;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delay = index * 80;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 14, end: show ? 0 : 14),
      duration: Duration(milliseconds: 360 + delay),
      curve: Curves.easeOut,
      builder: (_, value, inner) {
        return Transform.translate(offset: Offset(0, value), child: inner);
      },
      child: AnimatedOpacity(
        opacity: show ? 1 : 0,
        duration: Duration(milliseconds: 260 + delay),
        child: child,
      ),
    );
  }
}
