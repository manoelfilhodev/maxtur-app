import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_card.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/modules/auth/models/me_dto.dart';
import 'package:systex_frotas/modules/home/screens/home_screen.dart';
import 'package:systex_frotas/modules/notificacoes/screens/notificacoes_screen.dart';

class HomeAdminScreen extends StatelessWidget {
  const HomeAdminScreen({super.key, required this.me});

  final MeDto me;

  @override
  Widget build(BuildContext context) {
    return DgScaffold(
      appBar: AppBar(
        title: const Text('Admin Operador'),
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
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Olá, ${me.userName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              subtitle: Text('Operador #${me.operadorId}'),
            ),
          ),
          const SizedBox(height: 12),
          DgCard(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificacoesScreen())),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.notifications_active_rounded, color: Colors.white),
              title: Text('Notificações', style: TextStyle(color: Colors.white)),
              subtitle: Text('VIAGEM_SOLICITADA e CHECKLIST_REPROVADO'),
              trailing: Icon(Icons.chevron_right, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 10),
          const DgCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.flash_on_rounded, color: Colors.white),
              title: Text('Fila rápida (MVP)', style: TextStyle(color: Colors.white)),
              subtitle: Text('Ações via notificações.'),
            ),
          ),
        ],
      ),
    );
  }
}
