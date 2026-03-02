import 'package:dio/dio.dart';
import 'package:systex_frotas/core/api/api_client.dart';
import 'package:systex_frotas/core/api/api_config.dart';
import 'package:systex_frotas/modules/funcionario/models/funcionario_feedback_dto.dart';

class FuncionarioFeedbackService {
  final Dio _dio = ApiClient.instance.dio;

  Future<void> enviar(FuncionarioFeedbackDto dto) async {
    try {
      await _dio.post(
        ApiConfig.funcionarioFeedbackPath,
        data: dto.toJson(),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) {
          throw Exception(message);
        }
      }
      throw Exception('Falha ao enviar feedback.');
    }
  }
}
