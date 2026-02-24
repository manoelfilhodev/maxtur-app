import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_button.dart';
import 'package:systex_frotas/core/widgets/dg_card.dart';
import 'package:systex_frotas/core/widgets/dg_input.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/core/widgets/dg_toast.dart';
import 'package:systex_frotas/modules/checklist/models/checklist_models.dart';
import 'package:systex_frotas/modules/checklist/screens/checklist_resumo_screen.dart';
import 'package:systex_frotas/modules/checklist/services/checklist_api_service.dart';
import 'package:systex_frotas/modules/home/screens/home_screen.dart';

class ChecklistRunScreen extends StatefulWidget {
  const ChecklistRunScreen({
    super.key,
    required this.checklistId,
    required this.checklistNome,
  });

  final int checklistId;
  final String checklistNome;

  @override
  State<ChecklistRunScreen> createState() => _ChecklistRunScreenState();
}

class _ChecklistRunScreenState extends State<ChecklistRunScreen> {
  final ChecklistApiService _service = ChecklistApiService();

  bool _loading = true;
  bool _sending = false;
  Checklist? _checklist;

  final Map<String, String> _statusMap = <String, String>{};
  final Map<String, TextEditingController> _obsControllers = <String, TextEditingController>{};
  final Set<String> _obsOpen = <String>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _obsControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final checklist = await _service.getById(widget.checklistId);
      if (!mounted) return;
      setState(() {
        _checklist = checklist;
        for (final item in checklist.itens) {
          _statusMap[item.codigo] = _statusMap[item.codigo] ?? 'ok';
          _obsControllers[item.codigo] = _obsControllers[item.codigo] ?? TextEditingController();
        }
      });
    } catch (_) {
      if (!mounted) return;
      DgToast.show(context, 'Erro ao abrir checklist.', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final checklist = _checklist;
    if (checklist == null) return;

    setState(() => _sending = true);
    try {
      final respostas = checklist.itens
          .map(
            (item) => ChecklistResposta(
              codigo: item.codigo,
              status: _statusMap[item.codigo] ?? 'ok',
              observacao: _obsControllers[item.codigo]?.text.trim() ?? '',
            ),
          )
          .toList();

      await _service.postRespostas(checklist.id, respostas);

      final okCount = respostas.where((e) => e.status == 'ok').length;
      final falhaCount = respostas.length - okCount;

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChecklistResumoScreen(
            checklistNome: checklist.nome,
            okCount: okCount,
            falhaCount: falhaCount,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      DgToast.show(context, 'Erro ao enviar respostas.', isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final checklist = _checklist;

    return DgScaffold(
      appBar: AppBar(
        title: Text(widget.checklistNome),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') HomeScreen.performLogout(context);
            },
            itemBuilder: (_) => const [PopupMenuItem(value: 'logout', child: Text('Logout'))],
          ),
        ],
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : checklist == null
              ? const Center(child: Text('Checklist indisponível.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: checklist.itens.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, index) {
                          final item = checklist.itens[index];
                          final status = _statusMap[item.codigo] ?? 'ok';
                          final openObs = _obsOpen.contains(item.codigo);

                          return DgCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.codigo} - ${item.titulo}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                                if (item.descricao.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(item.descricao),
                                ],
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    ChoiceChip(
                                      label: const Text('OK'),
                                      selected: status == 'ok',
                                      onSelected: (_) => setState(() => _statusMap[item.codigo] = 'ok'),
                                    ),
                                    ChoiceChip(
                                      label: const Text('FALHA'),
                                      selected: status == 'falha',
                                      onSelected: (_) => setState(() => _statusMap[item.codigo] = 'falha'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      if (openObs) {
                                        _obsOpen.remove(item.codigo);
                                      } else {
                                        _obsOpen.add(item.codigo);
                                      }
                                    });
                                  },
                                  icon: Icon(openObs ? Icons.expand_less : Icons.expand_more),
                                  label: const Text('Observação (opcional)'),
                                ),
                                if (openObs)
                                  DgInput(
                                    controller: _obsControllers[item.codigo],
                                    label: 'Observação',
                                    maxLines: 2,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    DgButton(
                      label: 'Enviar',
                      icon: Icons.send,
                      loading: _sending,
                      onPressed: _send,
                    ),
                  ],
                ),
    );
  }
}
