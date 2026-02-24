import 'dart:async';

import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_badge.dart';
import 'package:systex_frotas/core/widgets/dg_button.dart';
import 'package:systex_frotas/core/widgets/dg_card.dart';
import 'package:systex_frotas/core/widgets/dg_input.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/core/widgets/dg_toast.dart';
import 'package:systex_frotas/modules/notificacoes/models/notification_dto.dart';
import 'package:systex_frotas/modules/notificacoes/services/notificacao_service.dart';

class NotificacoesScreen extends StatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> {
  final NotificacaoService _service = NotificacaoService();
  bool _loading = true;
  List<NotificationDto> _items = const <NotificationDto>[];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final data = await _service.listar();
      if (!mounted) return;
      setState(() => _items = data);
    } catch (_) {
      if (!silent && mounted) DgToast.show(context, 'Erro ao carregar notificações.', isError: true);
    } finally {
      if (!silent && mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openNotification(NotificationDto n) async {
    if (!n.isRead) {
      await _service.marcarComoLida(n.id);
      if (mounted) _load(silent: true);
    }

    if (n.type == 'VIAGEM_SOLICITADA' && n.referenceId != null) {
      await _showSolicitacaoActions(n.referenceId!);
      return;
    }

    if (n.type == 'CHECKLIST_REPROVADO') {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Checklist reprovado'),
          content: Text('Checklist referência: ${n.referenceId ?? '-'}'),
          actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Fechar'))],
        ),
      );
    }
  }

  Future<void> _showSolicitacaoActions(int solicitacaoId) async {
    final statusController = TextEditingController();
    final motoristaController = TextEditingController();
    final veiculoController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ações solicitação #$solicitacaoId', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              DgInput(controller: statusController, label: 'Novo status (pendente/aprovada/rejeitada)'),
              const SizedBox(height: 8),
              DgButton(
                label: 'Atualizar Status',
                onPressed: () async {
                  final status = statusController.text.trim();
                  if (status.isEmpty) return;
                  try {
                    await _service.atualizarStatusSolicitacao(solicitacaoId, status);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    if (mounted) DgToast.show(context, 'Status atualizado.');
                  } catch (_) {
                    if (mounted) DgToast.show(context, 'Erro ao atualizar status.', isError: true);
                  }
                },
              ),
              const SizedBox(height: 12),
              DgInput(controller: motoristaController, label: 'Motorista ID'),
              const SizedBox(height: 8),
              DgInput(controller: veiculoController, label: 'Veículo ID'),
              const SizedBox(height: 8),
              DgButton(
                label: 'Atribuir',
                onPressed: () async {
                  final motoristaId = int.tryParse(motoristaController.text.trim());
                  final veiculoId = int.tryParse(veiculoController.text.trim());
                  if (motoristaId == null || veiculoId == null) return;
                  try {
                    await _service.atribuirSolicitacao(
                      id: solicitacaoId,
                      motoristaId: motoristaId,
                      veiculoId: veiculoId,
                    );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    if (mounted) DgToast.show(context, 'Solicitação atribuída.');
                  } catch (_) {
                    if (mounted) DgToast.show(context, 'Erro ao atribuir.', isError: true);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DgScaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded))],
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('Nenhuma notificação.'))
              : ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final n = _items[i];
                    return DgCard(
                      onTap: () => _openNotification(n),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(n.body),
                                const SizedBox(height: 6),
                                Text(n.type),
                              ],
                            ),
                          ),
                          DgBadge(status: n.isRead ? 'lida' : 'nova'),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
