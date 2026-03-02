import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_button.dart';
import 'package:systex_frotas/core/widgets/dg_card.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/modules/auth/models/me_dto.dart';
import 'package:systex_frotas/modules/checklist/screens/checklist_veiculo_screen.dart';
import 'package:systex_frotas/modules/home/screens/home_screen.dart';

class HomeMotoristaScreen extends StatelessWidget {
  const HomeMotoristaScreen({super.key, required this.me});

  final MeDto me;

  @override
  Widget build(BuildContext context) {
    return DgScaffold(
      appBar: AppBar(
        title: const Text('Motorista'),
        actions: [
          IconButton(
            onPressed: () => HomeScreen.performLogout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      child: ListView(
        children: [
          DgCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Olá, ${me.displayName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text('Checklist diário do veículo do operador.'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DgButton(
            label: 'Iniciar / Continuar Checklist',
            icon: Icons.fact_check_rounded,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChecklistVeiculoScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          const DgCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Histórico (MVP)', style: TextStyle(color: Colors.white)),
              subtitle: Text('Disponível em próxima fase.'),
            ),
          ),
        ],
      ),
    );
  }
}

