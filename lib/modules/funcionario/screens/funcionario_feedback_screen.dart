import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_button.dart';
import 'package:systex_frotas/core/widgets/dg_input.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/core/widgets/dg_toast.dart';
import 'package:systex_frotas/modules/funcionario/models/funcionario_feedback_dto.dart';
import 'package:systex_frotas/modules/funcionario/services/funcionario_feedback_service.dart';

class FuncionarioFeedbackScreen extends StatefulWidget {
  const FuncionarioFeedbackScreen({super.key});

  @override
  State<FuncionarioFeedbackScreen> createState() => _FuncionarioFeedbackScreenState();
}

class _FuncionarioFeedbackScreenState extends State<FuncionarioFeedbackScreen> {
  final FuncionarioFeedbackService _service = FuncionarioFeedbackService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _mensagemController = TextEditingController();
  FuncionarioFeedbackTipo _tipo = FuncionarioFeedbackTipo.sugestao;
  bool _sending = false;

  @override
  void dispose() {
    _mensagemController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      final dto = FuncionarioFeedbackDto(
        tipo: _tipo,
        mensagem: _mensagemController.text,
      );
      await _service.enviar(dto);
      if (!mounted) return;
      DgToast.show(context, 'Feedback enviado com sucesso.');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      DgToast.show(context, e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DgScaffold(
      appBar: AppBar(title: const Text('Sugestões e Críticas')),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            DropdownButtonFormField<FuncionarioFeedbackTipo>(
              initialValue: _tipo,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: const [
                DropdownMenuItem(
                  value: FuncionarioFeedbackTipo.sugestao,
                  child: Text('Sugestão'),
                ),
                DropdownMenuItem(
                  value: FuncionarioFeedbackTipo.critica,
                  child: Text('Crítica'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _tipo = value);
              },
            ),
            const SizedBox(height: 12),
            DgInput(
              controller: _mensagemController,
              label: 'Mensagem',
              maxLines: 6,
              validator: (v) {
                final text = (v ?? '').trim();
                if (text.isEmpty) return 'Informe a mensagem.';
                if (text.length < 10) return 'Escreva pelo menos 10 caracteres.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DgButton(
              label: 'Enviar',
              icon: Icons.send_rounded,
              loading: _sending,
              onPressed: _enviar,
            ),
          ],
        ),
      ),
    );
  }
}
