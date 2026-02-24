import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_button.dart';
import 'package:systex_frotas/core/widgets/dg_input.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/core/widgets/dg_toast.dart';
import 'package:systex_frotas/modules/auth/services/auth_storage.dart';
import 'package:systex_frotas/modules/home/screens/home_screen.dart';
import 'package:systex_frotas/modules/viagens/models/viagem_models.dart';
import 'package:systex_frotas/modules/viagens/services/viagem_api_service.dart';
import 'package:systex_frotas/modules/viagens_uber/models/trip_draft.dart';
import 'package:systex_frotas/modules/viagens_uber/screens/trip_confirm_screen.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({super.key, required this.draft});

  final TripDraft draft;

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final ViagemApiService _service = ViagemApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _empresaController = TextEditingController();
  final TextEditingController _obsController = TextEditingController();

  DateTime _data = DateTime.now();
  TimeOfDay _hora = TimeOfDay.now();
  List<Funcionario> _funcionarios = const [];
  Funcionario? _funcionario;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nomeController.dispose();
    _dataController.dispose();
    _horaController.dispose();
    _enderecoController.dispose();
    _telefoneController.dispose();
    _empresaController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    _emailController.text = widget.draft.solicitanteEmail.isNotEmpty
        ? widget.draft.solicitanteEmail
        : (AuthStorage.getLastEmail() ?? '');
    _nomeController.text = widget.draft.solicitanteNome ?? (AuthStorage.getLastNome() ?? '');

    if (widget.draft.data != null) _data = widget.draft.data!;
    if (widget.draft.hora != null) _hora = widget.draft.hora!;
    _dataController.text = _formatDateBR(_data);
    _horaController.text = _formatTime(_hora);

    _empresaController.text = widget.draft.empresa;
    _obsController.text = widget.draft.observacao ?? '';
    _enderecoController.text = widget.draft.endereco ?? '';
    _telefoneController.text = widget.draft.telefone ?? '';

    try {
      final funcionarios = await _service.getFuncionarios();
      if (!mounted) return;
      setState(() {
        _funcionarios = funcionarios;
        if (widget.draft.funcionarioId != null) {
          _funcionario = funcionarios.cast<Funcionario?>().firstWhere(
                (f) => f?.id == widget.draft.funcionarioId,
                orElse: () => null,
              );
        }
      });
    } catch (_) {
      if (mounted) DgToast.show(context, 'Erro ao carregar funcionários.', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDateBR(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _data = picked;
        _dataController.text = _formatDateBR(picked);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _hora);
    if (picked != null) {
      setState(() {
        _hora = picked;
        _horaController.text = _formatTime(picked);
      });
    }
  }

  void _onSelectFuncionario(Funcionario? f) {
    setState(() => _funcionario = f);
    if (f != null) {
      _enderecoController.text = f.endereco;
      _telefoneController.text = f.telefone;
    }
  }

  Future<void> _saveAndGoNext() async {
    if (!_formKey.currentState!.validate()) return;
    if (_funcionario == null) {
      DgToast.show(context, 'Selecione um funcionário.', isError: true);
      return;
    }

    widget.draft.solicitanteEmail = _emailController.text.trim();
    widget.draft.solicitanteNome = _nomeController.text.trim().isEmpty ? null : _nomeController.text.trim();
    widget.draft.data = _data;
    widget.draft.hora = _hora;
    widget.draft.funcionarioId = _funcionario!.id;
    widget.draft.funcionarioNome = _funcionario!.nome;
    widget.draft.endereco = _enderecoController.text.trim();
    widget.draft.telefone = _telefoneController.text.trim();
    widget.draft.empresa = _empresaController.text.trim();
    widget.draft.observacao = _obsController.text.trim().isEmpty ? null : _obsController.text.trim();

    await AuthStorage.saveLastEmail(widget.draft.solicitanteEmail);
    if (widget.draft.solicitanteNome != null) {
      await AuthStorage.saveLastNome(widget.draft.solicitanteNome!);
    }

    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => TripConfirmScreen(draft: widget.draft)));
  }

  @override
  Widget build(BuildContext context) {
    return DgScaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Viagem'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') HomeScreen.performLogout(context);
            },
            itemBuilder: (_) => const [PopupMenuItem(value: 'logout', child: Text('Logout'))],
          ),
        ],
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                children: [
                  DgInput(
                    controller: _emailController,
                    label: 'Solicitante email*',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => AuthStorage.saveLastEmail(value.trim()),
                    validator: (v) {
                      final x = (v ?? '').trim();
                      if (x.isEmpty || !x.contains('@')) return 'Informe um email válido.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  DgInput(
                    controller: _nomeController,
                    label: 'Solicitante nome (opcional)',
                    onChanged: (value) {
                      if (value.trim().isNotEmpty) AuthStorage.saveLastNome(value.trim());
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DgInput(
                          controller: _dataController,
                          label: 'Data*',
                          readOnly: true,
                          onTap: _pickDate,
                          suffixIcon: const Icon(Icons.calendar_month),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DgInput(
                          controller: _horaController,
                          label: 'Hora*',
                          readOnly: true,
                          onTap: _pickTime,
                          suffixIcon: const Icon(Icons.access_time),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<Funcionario>(
                    initialValue: _funcionario,
                    decoration: const InputDecoration(labelText: 'Funcionário*'),
                    items: _funcionarios
                        .map((f) => DropdownMenuItem<Funcionario>(value: f, child: Text(f.nome)))
                        .toList(),
                    onChanged: _onSelectFuncionario,
                    validator: (v) => v == null ? 'Selecione um funcionário.' : null,
                  ),
                  const SizedBox(height: 10),
                  DgInput(
                    controller: _enderecoController,
                    label: 'Endereço*',
                    validator: (v) => (v ?? '').trim().isEmpty ? 'Informe o endereço.' : null,
                  ),
                  const SizedBox(height: 10),
                  DgInput(
                    controller: _telefoneController,
                    label: 'Telefone*',
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v ?? '').trim().isEmpty ? 'Informe o telefone.' : null,
                  ),
                  const SizedBox(height: 10),
                  DgInput(
                    controller: _empresaController,
                    label: 'Empresa*',
                    validator: (v) => (v ?? '').trim().isEmpty ? 'Informe a empresa.' : null,
                  ),
                  const SizedBox(height: 10),
                  DgInput(controller: _obsController, label: 'Observação (opcional)', maxLines: 3),
                  const SizedBox(height: 16),
                  DgButton(label: 'Revisar', icon: Icons.checklist, onPressed: _saveAndGoNext),
                ],
              ),
            ),
    );
  }
}
