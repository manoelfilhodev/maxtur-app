import 'package:dio/dio.dart';
import 'package:systex_frotas/core/api/api_config.dart';
import 'package:systex_frotas/core/api/api_envelope.dart';
import 'package:systex_frotas/modules/auth/services/auth_storage.dart';
import 'package:systex_frotas/modules/auth/services/session_manager.dart';

class ApiClient {
  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: const <String, dynamic>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AuthStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await SessionManager.handleUnauthorized();
          }
          handler.next(error);
        },
      ),
    );
  }

  late final Dio dio;

  static final ApiClient _instance = ApiClient._internal();
  static ApiClient get instance => _instance;

  static ApiEnvelope<dynamic> envelope(Response<dynamic> response) {
    return ApiEnvelope.fromJson(response.data);
  }
}
