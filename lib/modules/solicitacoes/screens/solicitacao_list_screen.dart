import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_badge.dart';
import 'package:systex_frotas/core/widgets/dg_card.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/core/widgets/dg_toast.dart';
import 'package:systex_frotas/modules/solicitacoes/models/solicitacao_dto.dart';
import 'package:systex_frotas/modules/solicitacoes/screens/solicitacao_detail_screen.dart';
import 'package:systex_frotas/modules/solicitacoes/services/solicitacao_service.dart';

class SolicitacaoListScreen extends StatefulWidget {
  const SolicitacaoListScreen({super.key});

  @override
  State<SolicitacaoListScreen> createState() => _SolicitacaoListScreenState();
}

class _SolicitacaoListScreenState extends State<SolicitacaoListScreen> {
  final SolicitacaoService _service = SolicitacaoService();
  bool _loading = true;
  List<SolicitacaoDto> _items = const <SolicitacaoDto>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _service.listar();
      if (!mounted) return;
      setState(() => _items = data);
    } catch (_) {
      if (mounted) DgToast.show(context, 'Erro ao carregar solicitações.', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DgScaffold(
      appBar: AppBar(
        title: const Text('Minhas Solicitações'),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded))],
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('Nenhuma solicitação encontrada.'))
              : ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final s = _items[index];
                    return DgCard(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => SolicitacaoDetailScreen(id: s.id)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${s.origem} -> ${s.destino}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(s.dataHora),
                              ],
                            ),
                          ),
                          DgBadge(status: s.status),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
