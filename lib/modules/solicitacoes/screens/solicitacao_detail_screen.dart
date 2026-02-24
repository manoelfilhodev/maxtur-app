import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_badge.dart';
import 'package:systex_frotas/core/widgets/dg_card.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/core/widgets/dg_toast.dart';
import 'package:systex_frotas/modules/solicitacoes/models/solicitacao_dto.dart';
import 'package:systex_frotas/modules/solicitacoes/services/solicitacao_service.dart';

class SolicitacaoDetailScreen extends StatefulWidget {
  const SolicitacaoDetailScreen({super.key, required this.id});

  final int id;

  @override
  State<SolicitacaoDetailScreen> createState() => _SolicitacaoDetailScreenState();
}

class _SolicitacaoDetailScreenState extends State<SolicitacaoDetailScreen> {
  final SolicitacaoService _service = SolicitacaoService();
  bool _loading = true;
  SolicitacaoDto? _item;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final item = await _service.detalhe(widget.id);
      if (!mounted) return;
      setState(() => _item = item);
    } catch (_) {
      if (mounted) DgToast.show(context, 'Erro ao carregar detalhe.', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    return DgScaffold(
      appBar: AppBar(title: Text('Solicitação #${widget.id}')),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : item == null
              ? const Center(child: Text('Solicitação não encontrada.'))
              : ListView(
                  children: [
                    DgCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                              ),
                              DgBadge(status: item.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Origem: ${item.origem}'),
                          Text('Destino: ${item.destino}'),
                          Text('Data/Hora: ${item.dataHora}'),
                          Text('Passageiros: ${item.passageirosPrevistos}'),
                          if (item.veiculo != null && item.veiculo!.isNotEmpty) Text('Veículo: ${item.veiculo}'),
                          if (item.motorista != null && item.motorista!.isNotEmpty) Text('Motorista: ${item.motorista}'),
                          if (item.observacao != null && item.observacao!.isNotEmpty) Text('Obs: ${item.observacao}'),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
