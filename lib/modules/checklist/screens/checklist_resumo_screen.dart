import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_button.dart';
import 'package:systex_frotas/core/widgets/dg_card.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/modules/checklist/screens/checklist_home_screen.dart';
import 'package:systex_frotas/modules/home/screens/home_screen.dart';

class ChecklistResumoScreen extends StatelessWidget {
  const ChecklistResumoScreen({
    super.key,
    required this.checklistNome,
    required this.okCount,
    required this.falhaCount,
  });

  final String checklistNome;
  final int okCount;
  final int falhaCount;

  @override
  Widget build(BuildContext context) {
    return DgScaffold(
      appBar: AppBar(
        title: const Text('Resumo'),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DgCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  checklistNome,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text('OK: $okCount'),
                Text('Falha: $falhaCount'),
                const SizedBox(height: 10),
                const Text('Checklist enviado com sucesso.'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          DgButton(
            label: 'Voltar',
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const ChecklistHomeScreen()),
              (route) => false,
            ),
          ),
        ],
      ),
    );
  }
}
