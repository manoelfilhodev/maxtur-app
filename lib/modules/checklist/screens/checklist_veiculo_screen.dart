import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_button.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/core/widgets/dg_toast.dart';
import 'package:systex_frotas/modules/checklist/models/checklist_dto.dart';
import 'package:systex_frotas/modules/checklist/screens/checklist_modo_app_screen.dart';
import 'package:systex_frotas/modules/checklist/services/checklist_service.dart';

class ChecklistVeiculoScreen extends StatefulWidget {
  const ChecklistVeiculoScreen({super.key});

  @override
  State<ChecklistVeiculoScreen> createState() => _ChecklistVeiculoScreenState();
}

class _ChecklistVeiculoScreenState extends State<ChecklistVeiculoScreen> {
  final ChecklistService _service = ChecklistService();
  bool _loading = true;
  bool _starting = false;
  List<VeiculoDto> _veiculos = const <VeiculoDto>[];
  VeiculoDto? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final veiculos = await _service.listarVeiculos();
      if (!mounted) return;
      setState(() {
        _veiculos = veiculos;
        _selected = veiculos.isNotEmpty ? veiculos.first : null;
      });
    } catch (_) {
      if (mounted) DgToast.show(context, 'Erro ao carregar veículos.', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _start() async {
    final selected = _selected;
    if (selected == null) {
      DgToast.show(context, 'Selecione um veículo.', isError: true);
      return;
    }
    setState(() => _starting = true);
    try {
      final checklist = await _service.iniciar(selected.id);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChecklistModoAppScreen(
            checklist: checklist,
            veiculo: selected,
          ),
        ),
      );
    } catch (_) {
      if (mounted) DgToast.show(context, 'Falha ao iniciar checklist.', isError: true);
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DgScaffold(
      appBar: AppBar(title: const Text('Selecionar Veículo')),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _veiculos.isEmpty
              ? const Center(child: Text('Nenhum veículo encontrado.'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<VeiculoDto>(
                      initialValue: _selected,
                      decoration: const InputDecoration(labelText: 'Veículo do operador'),
                      items: _veiculos
                          .map(
                            (v) => DropdownMenuItem<VeiculoDto>(
                              value: v,
                              child: Text('${v.placa} - ${v.descricao}'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selected = v),
                    ),
                    const SizedBox(height: 16),
                    DgButton(
                      label: 'Iniciar Checklist',
                      icon: Icons.play_arrow_rounded,
                      loading: _starting,
                      onPressed: _start,
                    ),
                  ],
                ),
    );
  }
}
