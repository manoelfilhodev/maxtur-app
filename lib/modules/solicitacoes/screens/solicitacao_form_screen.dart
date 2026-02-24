import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_button.dart';
import 'package:systex_frotas/core/widgets/dg_input.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/core/widgets/dg_toast.dart';
import 'package:systex_frotas/modules/solicitacoes/services/solicitacao_service.dart';

class SolicitacaoFormScreen extends StatefulWidget {
  const SolicitacaoFormScreen({super.key});

  @override
  State<SolicitacaoFormScreen> createState() => _SolicitacaoFormScreenState();
}

class _SolicitacaoFormScreenState extends State<SolicitacaoFormScreen> {
  final SolicitacaoService _service = SolicitacaoService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _origem = TextEditingController();
  final TextEditingController _destino = TextEditingController();
  final TextEditingController _dataHora = TextEditingController();
  final TextEditingController _passageiros = TextEditingController(text: '1');
  final TextEditingController _obs = TextEditingController();
  bool _sending = false;
  DateTime _selected = DateTime.now().add(const Duration(hours: 1));

  @override
  void initState() {
    super.initState();
    _refreshDate();
  }

  @override
  void dispose() {
    _origem.dispose();
    _destino.dispose();
    _dataHora.dispose();
    _passageiros.dispose();
    _obs.dispose();
    super.dispose();
  }

  void _refreshDate() {
    final d = _selected.day.toString().padLeft(2, '0');
    final m = _selected.month.toString().padLeft(2, '0');
    final y = _selected.year;
    final h = _selected.hour.toString().padLeft(2, '0');
    final min = _selected.minute.toString().padLeft(2, '0');
    _dataHora.text = '$d/$m/$y $h:$min';
  }

  String _toApiDate() {
    final y = _selected.year;
    final m = _selected.month.toString().padLeft(2, '0');
    final d = _selected.day.toString().padLeft(2, '0');
    final h = _selected.hour.toString().padLeft(2, '0');
    final min = _selected.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min:00';
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_selected));
    if (time == null) return;
    setState(() {
      _selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _refreshDate();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      await _service.criar(
        origem: _origem.text.trim(),
        destino: _destino.text.trim(),
        dataHora: _toApiDate(),
        passageirosPrevistos: int.parse(_passageiros.text.trim()),
        observacao: _obs.text.trim().isEmpty ? null : _obs.text.trim(),
      );
      if (!mounted) return;
      DgToast.show(context, 'Solicitação enviada.');
      Navigator.of(context).pop();
    } catch (_) {
      if (mounted) DgToast.show(context, 'Falha ao criar solicitação.', isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DgScaffold(
      appBar: AppBar(title: const Text('Nova Solicitação')),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            DgInput(
              controller: _origem,
              label: 'Origem',
              validator: (v) => (v ?? '').trim().isEmpty ? 'Informe a origem.' : null,
            ),
            const SizedBox(height: 10),
            DgInput(
              controller: _destino,
              label: 'Destino',
              validator: (v) => (v ?? '').trim().isEmpty ? 'Informe o destino.' : null,
            ),
            const SizedBox(height: 10),
            DgInput(
              controller: _dataHora,
              label: 'Data/Hora',
              readOnly: true,
              onTap: _pickDateTime,
              suffixIcon: const Icon(Icons.calendar_month_rounded),
            ),
            const SizedBox(height: 10),
            DgInput(
              controller: _passageiros,
              label: 'Passageiros previstos',
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null || n < 1) return 'Informe ao menos 1 passageiro.';
                return null;
              },
            ),
            const SizedBox(height: 10),
            DgInput(
              controller: _obs,
              label: 'Observação',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DgButton(
              label: 'Enviar',
              icon: Icons.send_rounded,
              loading: _sending,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
