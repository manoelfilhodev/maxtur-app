import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_button.dart';
import 'package:systex_frotas/core/widgets/dg_card.dart';
import 'package:systex_frotas/core/widgets/dg_input.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/core/widgets/dg_toast.dart';
import 'package:systex_frotas/modules/home/screens/home_screen.dart';
import 'package:systex_frotas/modules/viagens_uber/models/trip_draft.dart';
import 'package:systex_frotas/modules/viagens_uber/screens/trip_details_screen.dart';

class TripWhereToScreen extends StatefulWidget {
  const TripWhereToScreen({super.key, required this.draft});

  final TripDraft draft;

  @override
  State<TripWhereToScreen> createState() => _TripWhereToScreenState();
}

class _TripWhereToScreenState extends State<TripWhereToScreen> {
  late final TextEditingController _origemController;
  late final TextEditingController _destinoController;
  late final TextEditingController _rotaOutroController;

  static const List<String> _zonas = ['Zona Sul', 'Zona Norte', 'Centro', 'Aeroporto', 'Outro'];

  @override
  void initState() {
    super.initState();
    _origemController = TextEditingController(text: widget.draft.origem);
    _destinoController = TextEditingController(text: widget.draft.destino);
    _rotaOutroController = TextEditingController(text: widget.draft.rotaOutroTexto ?? '');
  }

  @override
  void dispose() {
    _origemController.dispose();
    _destinoController.dispose();
    _rotaOutroController.dispose();
    super.dispose();
  }

  void _continue() {
    final destino = _destinoController.text.trim();
    if (destino.isEmpty) {
      DgToast.show(context, 'Informe o destino.', isError: true);
      return;
    }

    if (widget.draft.rotaZona == 'Outro' && _rotaOutroController.text.trim().isEmpty) {
      DgToast.show(context, 'Informe o nome da rota.', isError: true);
      return;
    }

    widget.draft.origem = _origemController.text.trim().isEmpty ? 'Empresa' : _origemController.text.trim();
    widget.draft.destino = destino;
    widget.draft.rotaOutroTexto = widget.draft.rotaZona == 'Outro' ? _rotaOutroController.text.trim() : null;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TripDetailsScreen(draft: widget.draft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DgScaffold(
      appBar: AppBar(
        title: const Text('Para onde?'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') HomeScreen.performLogout(context);
            },
            itemBuilder: (_) => const [PopupMenuItem(value: 'logout', child: Text('Logout'))],
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: DgCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DgInput(controller: _origemController, label: 'Origem', hint: 'Empresa'),
                const SizedBox(height: 10),
                DgInput(controller: _destinoController, label: 'Para onde?', hint: 'Destino da viagem'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _zonas
                      .map(
                        (zona) => ChoiceChip(
                          label: Text(zona),
                          selected: widget.draft.rotaZona == zona,
                          onSelected: (_) => setState(() => widget.draft.rotaZona = zona),
                        ),
                      )
                      .toList(),
                ),
                if (widget.draft.rotaZona == 'Outro') ...[
                  const SizedBox(height: 10),
                  DgInput(controller: _rotaOutroController, label: 'Nome da rota'),
                ],
                const SizedBox(height: 16),
                DgButton(label: 'Continuar', icon: Icons.arrow_forward, onPressed: _continue),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
