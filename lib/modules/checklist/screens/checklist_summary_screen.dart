import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_button.dart';
import 'package:systex_frotas/core/widgets/dg_card.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';

class ChecklistSummaryScreen extends StatelessWidget {
  const ChecklistSummaryScreen({
    super.key,
    required this.checklistId,
    required this.apto,
    required this.falhas,
  });

  final int checklistId;
  final bool apto;
  final List<int> falhas;

  @override
  Widget build(BuildContext context) {
    return DgScaffold(
      appBar: AppBar(title: const Text('Resumo do Checklist')),
      child: Column(
        children: [
          DgCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Checklist #$checklistId', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(apto ? 'Resultado: APTO' : 'Resultado: NÃO CONFORME'),
                const SizedBox(height: 8),
                Text(falhas.isEmpty ? 'Sem falhas registradas.' : 'Itens com falha: ${falhas.join(', ')}'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          DgButton(
            label: 'Concluir',
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
    );
  }
}
