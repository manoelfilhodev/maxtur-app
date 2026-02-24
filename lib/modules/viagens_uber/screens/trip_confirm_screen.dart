import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_button.dart';
import 'package:systex_frotas/core/widgets/dg_card.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/core/widgets/dg_toast.dart';
import 'package:systex_frotas/modules/home/screens/home_screen.dart';
import 'package:systex_frotas/modules/viagens/screens/viagem_minhas_screen.dart';
import 'package:systex_frotas/modules/viagens/services/viagem_api_service.dart';
import 'package:systex_frotas/modules/viagens_uber/models/trip_draft.dart';

class TripConfirmScreen extends StatefulWidget {
  const TripConfirmScreen({super.key, required this.draft});

  final TripDraft draft;

  @override
  State<TripConfirmScreen> createState() => _TripConfirmScreenState();
}

class _TripConfirmScreenState extends State<TripConfirmScreen> {
  final ViagemApiService _service = ViagemApiService();
  bool _sending = false;

  String _formatDateBR(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  String _formatDateISO(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$y-$m-$d';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _confirm() async {
    final d = widget.draft;
    if (d.data == null || d.hora == null || d.funcionarioId == null) {
      DgToast.show(context, 'Dados incompletos para confirmar.', isError: true);
      return;
    }

    setState(() => _sending = true);
    try {
      final payload = <String, dynamic>{
        'solicitante_email': d.solicitanteEmail,
        'data': _formatDateISO(d.data!),
        'hora': _formatTime(d.hora!),
        'rota': d.rotaFinal,
        'funcionario_id': d.funcionarioId,
        'endereco': d.endereco ?? '',
        'telefone': d.telefone ?? '',
        'empresa': d.empresa,
      };

      if (d.solicitanteNome != null && d.solicitanteNome!.isNotEmpty) {
        payload['solicitante_nome'] = d.solicitanteNome;
      }
      if (d.observacao != null && d.observacao!.isNotEmpty) {
        payload['observacao'] = d.observacao;
      }

      await _service.postSolicitacao(payload);

      if (!mounted) return;
      DgToast.show(context, 'Solicitação enviada com sucesso.');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => ViagemMinhasScreen(initialEmail: d.solicitanteEmail)),
        (route) => route.isFirst,
      );
    } catch (_) {
      if (!mounted) return;
      DgToast.show(context, 'Falha ao confirmar solicitação.', isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.draft;

    return DgScaffold(
      appBar: AppBar(
        title: const Text('Confirmar Solicitação'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') HomeScreen.performLogout(context);
            },
            itemBuilder: (_) => const [PopupMenuItem(value: 'logout', child: Text('Logout'))],
          ),
        ],
      ),
      child: ListView(
        children: [
          DgCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Trajeto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('${d.origem} -> ${d.destino}'),
                Text('Rota: ${d.rotaFinal}'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          DgCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Data e Hora', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('${d.data != null ? _formatDateBR(d.data!) : '-'} ${d.hora != null ? _formatTime(d.hora!) : '-'}'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          DgCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Passageiro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(d.funcionarioNome ?? 'Não informado'),
                Text('Telefone: ${d.telefone ?? '-'}'),
                Text('Endereço: ${d.endereco ?? '-'}'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          DgCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Empresa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(d.empresa),
                if (d.observacao != null && d.observacao!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Observação', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(d.observacao!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          DgButton(
            label: 'Confirmar solicitação',
            icon: Icons.local_taxi,
            loading: _sending,
            onPressed: _confirm,
          ),
        ],
      ),
    );
  }
}
