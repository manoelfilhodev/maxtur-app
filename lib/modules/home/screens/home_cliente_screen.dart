import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_card.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/modules/auth/models/me_dto.dart';
import 'package:systex_frotas/modules/home/screens/home_screen.dart';
import 'package:systex_frotas/modules/solicitacoes/screens/solicitacao_form_screen.dart';
import 'package:systex_frotas/modules/solicitacoes/screens/solicitacao_list_screen.dart';

class HomeClienteScreen extends StatelessWidget {
  const HomeClienteScreen({super.key, required this.me});

  final MeDto me;

  @override
  Widget build(BuildContext context) {
    return DgScaffold(
      appBar: AppBar(
        title: const Text('Cliente Final'),
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
              title: Text('Olá, ${me.displayName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              subtitle: Text('Cliente #${me.clienteId ?? '-'} do operador #${me.operadorId}.'),
            ),
          ),
          const SizedBox(height: 12),
          DgCard(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SolicitacaoFormScreen())),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.add_rounded, color: Colors.white),
              title: Text('Nova Solicitação', style: TextStyle(color: Colors.white)),
              trailing: Icon(Icons.chevron_right, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 10),
          DgCard(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SolicitacaoListScreen())),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.list_alt_rounded, color: Colors.white),
              title: Text('Minhas Solicitações', style: TextStyle(color: Colors.white)),
              trailing: Icon(Icons.chevron_right, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

