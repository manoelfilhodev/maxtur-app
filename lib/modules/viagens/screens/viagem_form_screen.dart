import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_button.dart';
import 'package:systex_frotas/core/widgets/dg_input.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/core/widgets/dg_toast.dart';
import 'package:systex_frotas/modules/auth/services/auth_storage.dart';
import 'package:systex_frotas/modules/home/screens/home_screen.dart';
import 'package:systex_frotas/modules/viagens/models/viagem_models.dart';
import 'package:systex_frotas/modules/viagens/screens/viagem_minhas_screen.dart';
import 'package:systex_frotas/modules/viagens/services/viagem_api_service.dart';

class ViagemFormScreen extends StatefulWidget {
  const ViagemFormScreen({super.key});

  @override
  State<ViagemFormScreen> createState() => _ViagemFormScreenState();
}

class _ViagemFormScreenState extends State<ViagemFormScreen> {
  final ViagemApiService _service = ViagemApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _rotaOutroController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _empresaController = TextEditingController();
  final TextEditingController _observacaoController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _rota = 'Zona Sul';

  bool _loadingFuncionarios = true;
  bool _sending = false;

  List<Funcionario> _funcionarios = const [];
  Funcionario? _funcionarioSelecionado;

  static const List<String> _rotas = <String>['Zona Sul', 'Zona Norte', 'Centro', 'Outro'];

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nomeController.dispose();
    _rotaOutroController.dispose();
    _enderecoController.dispose();
    _telefoneController.dispose();
    _empresaController.dispose();
    _observacaoController.dispose();
    _dataController.dispose();
    _horaController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    _refreshDateTimeFields();

    final email = AuthStorage.getLastEmail();
    if (email != null && email.isNotEmpty) {
      _emailController.text = email;
    }

    try {
      final funcionarios = await _service.getFuncionarios();
      if (!mounted) return;
      setState(() {
        _funcionarios = funcionarios;
      });
    } catch (_) {
      if (!mounted) return;
      DgToast.show(context, 'Erro ao carregar funcionários.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _loadingFuncionarios = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _refreshDateTimeFields();
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _refreshDateTimeFields();
      });
    }
  }

  void _refreshDateTimeFields() {
    _dataController.text = _formatDisplayDate(_selectedDate);
    _horaController.text = _formatDisplayTime(_selectedTime);
  }

  void _onSelectFuncionario(Funcionario? funcionario) {
    setState(() => _funcionarioSelecionado = funcionario);
    if (funcionario != null) {
      _enderecoController.text = funcionario.endereco;
      _telefoneController.text = funcionario.telefone;
    }
  }

  String _formatDisplayDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  String _formatDisplayTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _toApiDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$y-$m-$d';
  }

  String _toApiTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_funcionarioSelecionado == null) {
      DgToast.show(context, 'Selecione um funcionário.', isError: true);
      return;
    }

    final rotaFinal = _rota == 'Outro' ? _rotaOutroController.text.trim() : _rota;
    if (rotaFinal.isEmpty) {
      DgToast.show(context, 'Informe a rota.', isError: true);
      return;
    }

    setState(() => _sending = true);

    final payload = <String, dynamic>{
      'solicitante_email': _emailController.text.trim(),
      'data': _toApiDate(_selectedDate),
      'hora': _toApiTime(_selectedTime),
      'rota': rotaFinal,
      'funcionario_id': _funcionarioSelecionado!.id,
      'endereco': _enderecoController.text.trim(),
      'telefone': _telefoneController.text.trim(),
      'empresa': _empresaController.text.trim(),
    };

    final nome = _nomeController.text.trim();
    if (nome.isNotEmpty) payload['solicitante_nome'] = nome;

    final observacao = _observacaoController.text.trim();
    if (observacao.isNotEmpty) payload['observacao'] = observacao;

    try {
      await _service.postSolicitacao(payload);
      await AuthStorage.saveLastEmail(_emailController.text.trim());
      if (!mounted) return;
      DgToast.show(context, 'Solicitação enviada.');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ViagemMinhasScreen(initialEmail: _emailController.text.trim()),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      DgToast.show(context, 'Falha ao enviar solicitação.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DgScaffold(
      appBar: AppBar(
        title: const Text('Nova Solicitação'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                HomeScreen.performLogout(context);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      child: _loadingFuncionarios
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                children: [
                  DgInput(
                    controller: _emailController,
                    label: 'Solicitante email*',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final email = (value ?? '').trim();
                      if (email.isEmpty || !email.contains('@')) {
                        return 'Informe um email válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DgInput(
                    controller: _nomeController,
                    label: 'Solicitante nome (opcional)',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DgInput(
                          label: 'Data*',
                          controller: _dataController,
                          readOnly: true,
                          onTap: _pickDate,
                          suffixIcon: const Icon(Icons.calendar_month),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DgInput(
                          label: 'Hora*',
                          controller: _horaController,
                          readOnly: true,
                          onTap: _pickTime,
                          suffixIcon: const Icon(Icons.access_time),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _rota,
                    decoration: const InputDecoration(labelText: 'Rota*'),
                    items: _rotas
                        .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _rota = value);
                      }
                    },
                  ),
                  if (_rota == 'Outro') ...[
                    const SizedBox(height: 12),
                    DgInput(
                      controller: _rotaOutroController,
                      label: 'Informe a rota',
                      validator: (value) {
                        if (_rota == 'Outro' && (value ?? '').trim().isEmpty) {
                          return 'Informe a rota.';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Funcionario>(
                    initialValue: _funcionarioSelecionado,
                    decoration: const InputDecoration(labelText: 'Funcionário*'),
                    items: _funcionarios
                        .map(
                          (f) => DropdownMenuItem<Funcionario>(
                            value: f,
                            child: Text(f.nome),
                          ),
                        )
                        .toList(),
                    onChanged: _onSelectFuncionario,
                    validator: (value) => value == null ? 'Selecione um funcionário.' : null,
                  ),
                  const SizedBox(height: 12),
                  DgInput(
                    controller: _enderecoController,
                    label: 'Endereço*',
                    validator: (value) => (value ?? '').trim().isEmpty ? 'Informe o endereço.' : null,
                  ),
                  const SizedBox(height: 12),
                  DgInput(
                    controller: _telefoneController,
                    label: 'Telefone*',
                    keyboardType: TextInputType.phone,
                    validator: (value) => (value ?? '').trim().isEmpty ? 'Informe o telefone.' : null,
                  ),
                  const SizedBox(height: 12),
                  DgInput(
                    controller: _empresaController,
                    label: 'Empresa*',
                    validator: (value) => (value ?? '').trim().isEmpty ? 'Informe a empresa.' : null,
                  ),
                  const SizedBox(height: 12),
                  DgInput(
                    controller: _observacaoController,
                    label: 'Observação (opcional)',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 18),
                  DgButton(
                    label: 'Enviar Solicitação',
                    loading: _sending,
                    icon: Icons.send,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
    );
  }
}
