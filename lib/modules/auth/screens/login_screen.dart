import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:systex_frotas/core/api/api_config.dart';
import 'package:systex_frotas/core/widgets/dg_button.dart';
import 'package:systex_frotas/core/widgets/dg_card.dart';
import 'package:systex_frotas/core/widgets/dg_input.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/core/widgets/dg_toast.dart';
import 'package:systex_frotas/modules/auth/auth_navigation.dart';
import 'package:systex_frotas/modules/auth/services/auth_service.dart';
import 'package:systex_frotas/modules/auth/services/auth_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _service = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  bool _checkingApi = true;
  bool _apiOnline = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = AuthStorage.getLastEmail() ?? '';
    _checkApiConnection();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final email = _emailController.text.trim();
      await _service.login(email: email, password: _passwordController.text);
      final me = await _service.me();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => buildHomeForRole(me)),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      DgToast.show(context, e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkApiConnection() async {
    setState(() => _checkingApi = true);
    try {
      final dio = Dio(
        BaseOptions(
          headers: const <String, dynamic>{
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
        ),
      );
      await dio.getUri(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.mePath}'));
      if (!mounted) return;
      setState(() => _apiOnline = true);
    } on DioException catch (e) {
      if (!mounted) return;
      final status = e.response?.statusCode;
      // API alcançável mesmo sem autenticação (401 esperado no /me).
      setState(() => _apiOnline = e.response != null || status == 401);
    } catch (_) {
      if (!mounted) return;
      setState(() => _apiOnline = false);
    } finally {
      if (mounted) setState(() => _checkingApi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DgScaffold(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: DgCard(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Systex Frotas',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24),
                  ),
                  const SizedBox(height: 6),
                  const Text('Acesso do operador e clientes finais'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 9,
                        color: _checkingApi
                            ? Colors.white54
                            : _apiOnline
                                ? Colors.greenAccent
                                : Colors.redAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _checkingApi ? 'Verificando API...' : (_apiOnline ? 'API online' : 'API indisponível'),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        iconSize: 16,
                        onPressed: _checkingApi ? null : _checkApiConnection,
                        icon: const Icon(Icons.refresh_rounded),
                        tooltip: 'Revalidar API',
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  DgInput(
                    controller: _emailController,
                    label: 'E-mail',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final email = (value ?? '').trim();
                      if (email.isEmpty || !email.contains('@')) return 'Informe um e-mail válido.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DgInput(
                    controller: _passwordController,
                    label: 'Senha',
                    obscureText: true,
                    validator: (value) => (value ?? '').isEmpty ? 'Informe a senha.' : null,
                  ),
                  const SizedBox(height: 16),
                  DgButton(
                    label: 'Entrar',
                    icon: Icons.login_rounded,
                    loading: _loading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
