import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_badge.dart';
import 'package:systex_frotas/core/widgets/dg_button.dart';
import 'package:systex_frotas/core/widgets/dg_card.dart';
import 'package:systex_frotas/core/widgets/dg_input.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/core/widgets/dg_toast.dart';
import 'package:systex_frotas/modules/auth/services/auth_storage.dart';
import 'package:systex_frotas/modules/home/screens/home_screen.dart';
import 'package:systex_frotas/modules/viagens/models/viagem_models.dart';
import 'package:systex_frotas/modules/viagens/services/viagem_api_service.dart';

class ViagemMinhasScreen extends StatefulWidget {
  const ViagemMinhasScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ViagemMinhasScreen> createState() => _ViagemMinhasScreenState();
}

class _ViagemMinhasScreenState extends State<ViagemMinhasScreen> {
  final ViagemApiService _service = ViagemApiService();
  final TextEditingController _emailController = TextEditingController();

  bool _loading = false;
  List<ViagemSolicitacao> _items = const [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final cached = widget.initialEmail ?? AuthStorage.getLastEmail();
    if (cached != null && cached.isNotEmpty) {
      _emailController.text = cached;
      await _load(emailArg: cached, showToastOnEmpty: false);
    }
  }

  String _formatDateDisplay(String value) {
    if (value.contains('/')) return value;
    final p = value.split('-');
    if (p.length >= 3) return '${p[2].padLeft(2, '0')}/${p[1].padLeft(2, '0')}/${p[0]}';
    return value;
  }

  String _formatTimeDisplay(String value) {
    final p = value.split(':');
    if (p.length >= 2) return '${p[0].padLeft(2, '0')}:${p[1].padLeft(2, '0')}';
    return value;
  }

  String _formatCreatedAt(String value) {
    if (value.isEmpty) return '';
    final dt = DateTime.tryParse(value);
    if (dt == null) return value;
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }

  Future<void> _load({String? emailArg, bool showToastOnEmpty = true}) async {
    final email = (emailArg ?? _emailController.text).trim();
    if (email.isEmpty || !email.contains('@')) {
      if (showToastOnEmpty) DgToast.show(context, 'Informe um email válido.', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthStorage.saveLastEmail(email);
      final items = await _service.getMinhas(email);
      setState(() => _items = items);
    } catch (_) {
      if (!mounted) return;
      DgToast.show(context, 'Erro ao carregar solicitações.', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DgScaffold(
      appBar: AppBar(
        title: const Text('Minhas Solicitações'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') HomeScreen.performLogout(context);
            },
            itemBuilder: (_) => const [PopupMenuItem(value: 'logout', child: Text('Logout'))],
          ),
        ],
      ),
      child: Column(
        children: [
          DgInput(
            controller: _emailController,
            label: 'Email do solicitante',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          DgButton(
            label: 'Carregar',
            icon: Icons.refresh,
            loading: _loading,
            onPressed: _loading ? null : () => _load(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _load(showToastOnEmpty: false),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('Nenhuma solicitação encontrada.')),
                          ],
                        )
                      : ListView.separated(
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, index) {
                            final item = _items[index];
                            final createdAt = _formatCreatedAt(item.createdAt);
                            return DgCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.funcionarioNome.isEmpty
                                              ? 'Funcionário #${item.funcionarioId}'
                                              : item.funcionarioNome,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      DgBadge(status: item.status),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Data/Hora: ${_formatDateDisplay(item.data)} ${_formatTimeDisplay(item.hora)}'),
                                  Text('Rota: ${item.rota}'),
                                  Text('Empresa: ${item.empresa}'),
                                  if (createdAt.isNotEmpty) Text('Criada em: $createdAt'),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
