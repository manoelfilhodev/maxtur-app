import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_card.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/core/widgets/dg_toast.dart';
import 'package:systex_frotas/modules/auth/models/me_dto.dart';
import 'package:systex_frotas/modules/funcionario/screens/funcionario_rastreamento_screen.dart';
import 'package:systex_frotas/modules/home/screens/home_screen.dart';

class HomeFuncionarioScreen extends StatelessWidget {
  const HomeFuncionarioScreen({super.key, required this.me});

  final MeDto me;

  @override
  Widget build(BuildContext context) {
    return DgScaffold(
      appBar: AppBar(
        title: const Text('Funcionário'),
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
              subtitle: const Text('Acompanhe sua rota de fretado em tempo real.'),
            ),
          ),
          const SizedBox(height: 12),
          DgCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FuncionarioRastreamentoScreen()),
            ),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.map_rounded, color: Colors.white),
              title: Text('Rastrear Fretado', style: TextStyle(color: Colors.white)),
              trailing: Icon(Icons.chevron_right, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 10),
          DgCard(
            onTap: () => DgToast.show(context, 'Minhas Rotas (em breve).'),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.alt_route_rounded, color: Colors.white),
              title: Text('Minhas Rotas', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
          DgCard(
            onTap: () => DgToast.show(context, 'Meus Horários (em breve).'),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.schedule_rounded, color: Colors.white),
              title: Text('Meus Horários', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
