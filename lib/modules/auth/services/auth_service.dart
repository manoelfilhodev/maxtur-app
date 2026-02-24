import 'package:dio/dio.dart';
import 'package:systex_frotas/core/api/api_client.dart';
import 'package:systex_frotas/core/api/api_config.dart';
import 'package:systex_frotas/modules/auth/models/me_dto.dart';
import 'package:systex_frotas/modules/auth/services/auth_storage.dart';

class AuthService {
  final Dio _dio = ApiClient.instance.dio;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final payload = <String, dynamic>{
      'email': email,
      'password': password,
    };

    try {
      final response = await _dio.post(ApiConfig.loginPath, data: payload);
      final env = ApiClient.envelope(response);
      final data = env.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Resposta de login inválida.');
      }

      final token = (data['token'] ?? data['access_token'] ?? '').toString();
      if (token.isEmpty) throw Exception('Token não retornado pela API.');

      await AuthStorage.saveToken(token);
      await AuthStorage.saveLastEmail(email);
    } on DioException catch (e) {
      throw Exception(_extractApiError(e));
    }
  }

  Future<MeDto> me() async {
    try {
      final response = await _dio.get(ApiConfig.mePath);
      final env = ApiClient.envelope(response);
      final data = env.data;
      if (data is! Map<String, dynamic>) throw Exception('Resposta /me inválida.');
      return MeDto.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_extractApiError(e));
    }
  }

  Future<void> logout() => AuthStorage.clearSession(clearProfile: true);

  Future<bool> hasSession() async {
    final token = await AuthStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  String _extractApiError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Sem conexão com a API local.';
    }
    return 'Falha na requisição (${e.response?.statusCode ?? 'sem status'}).';
  }
}
