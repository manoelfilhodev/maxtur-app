import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_card.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/modules/home/screens/home_screen.dart';
import 'package:systex_frotas/modules/viagens/screens/viagem_minhas_screen.dart';
import 'package:systex_frotas/modules/viagens_uber/models/trip_draft.dart';
import 'package:systex_frotas/modules/viagens_uber/screens/trip_where_to_screen.dart';

class ViagensMenuScreen extends StatelessWidget {
  const ViagensMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DgScaffold(
      appBar: AppBar(
        title: const Text('Viagens Extras'),
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
          DgCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => TripWhereToScreen(draft: TripDraft())),
            ),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Solicitar Viagem (Uber-like)', style: TextStyle(color: Colors.white)),
              subtitle: Text('Fluxo rápido em 3 etapas, sem mapa.'),
              trailing: Icon(Icons.chevron_right, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          DgCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ViagemMinhasScreen()),
            ),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Minhas Solicitações', style: TextStyle(color: Colors.white)),
              subtitle: Text('Consultar por email do solicitante.'),
              trailing: Icon(Icons.chevron_right, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
