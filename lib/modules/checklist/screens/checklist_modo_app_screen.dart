import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:systex_frotas/core/widgets/dg_badge.dart';
import 'package:systex_frotas/core/widgets/dg_button.dart';
import 'package:systex_frotas/core/widgets/dg_card.dart';
import 'package:systex_frotas/core/widgets/dg_input.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/core/widgets/dg_toast.dart';
import 'package:systex_frotas/modules/checklist/models/checklist_dto.dart';
import 'package:systex_frotas/modules/checklist/screens/checklist_summary_screen.dart';
import 'package:systex_frotas/modules/checklist/services/checklist_service.dart';

class ChecklistModoAppScreen extends StatefulWidget {
  const ChecklistModoAppScreen({
    super.key,
    required this.checklist,
    required this.veiculo,
  });

  final ChecklistDto checklist;
  final VeiculoDto veiculo;

  @override
  State<ChecklistModoAppScreen> createState() => _ChecklistModoAppScreenState();
}

class _ChecklistModoAppScreenState extends State<ChecklistModoAppScreen> {
  final ChecklistService _service = ChecklistService();
  final ImagePicker _picker = ImagePicker();

  final Map<int, String> _statusByItem = <int, String>{};
  final Map<int, TextEditingController> _obsByItem = <int, TextEditingController>{};
  final Map<int, String> _fotoByItem = <int, String>{};
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    for (final item in widget.checklist.itens) {
      _obsByItem[item.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _obsByItem.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _capturarFoto(int itemId) async {
    final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _fotoByItem[itemId] = base64Encode(bytes));
  }

  bool _isValid() {
    for (final item in widget.checklist.itens) {
      final status = _statusByItem[item.id];
      if (status == null) return false;
      if (status == 'falha') {
        final obs = (_obsByItem[item.id]?.text ?? '').trim();
        final foto = _fotoByItem[item.id];
        if (obs.isEmpty || foto == null || foto.isEmpty) return false;
      }
    }
    return true;
  }

  Future<void> _enviar() async {
    if (!_isValid()) {
      DgToast.show(
        context,
        'Responda todos os itens. Em falha, observação e foto são obrigatórios.',
        isError: true,
      );
      return;
    }

    final respostas = widget.checklist.itens
        .map(
          (item) => RespostaDto(
            itemId: item.id,
            status: _statusByItem[item.id]!,
            observacao: (_obsByItem[item.id]?.text ?? '').trim(),
            fotoBase64: _fotoByItem[item.id],
          ),
        )
        .toList();

    setState(() => _sending = true);
    try {
      await _service.enviarRespostas(widget.checklist.id, respostas);
      final finalizacao = await _service.finalizar(widget.checklist.id);
      final apto = (finalizacao['resultado'] ?? '').toString() == 'apto';
      final falhas = respostas.where((r) => r.status == 'falha').map((r) => r.itemId).toList();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChecklistSummaryScreen(
            checklistId: widget.checklist.id,
            apto: apto,
            falhas: falhas,
          ),
        ),
      );
    } catch (_) {
      if (mounted) DgToast.show(context, 'Falha ao enviar checklist.', isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DgScaffold(
      appBar: AppBar(
        title: Text('Checklist ${widget.veiculo.placa}'),
        actions: [DgBadge(status: _isValid() ? 'pronto' : 'pendente')],
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: widget.checklist.itens.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final item = widget.checklist.itens[index];
                final status = _statusByItem[item.id];
                final isFalha = status == 'falha';
                return DgCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('OK'),
                            selected: status == 'ok',
                            onSelected: (_) => setState(() => _statusByItem[item.id] = 'ok'),
                          ),
                          ChoiceChip(
                            label: const Text('FALHA'),
                            selected: status == 'falha',
                            onSelected: (_) => setState(() => _statusByItem[item.id] = 'falha'),
                          ),
                        ],
                      ),
                      if (isFalha) ...[
                        const SizedBox(height: 10),
                        DgInput(
                          controller: _obsByItem[item.id],
                          label: 'Observação obrigatória',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: DgButton(
                                label: _fotoByItem[item.id] == null ? 'Capturar foto' : 'Foto capturada',
                                icon: Icons.camera_alt_rounded,
                                onPressed: () => _capturarFoto(item.id),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          DgButton(
            label: 'Enviar e Finalizar',
            icon: Icons.check_circle_rounded,
            loading: _sending,
            onPressed: _enviar,
          ),
        ],
      ),
    );
  }
}
