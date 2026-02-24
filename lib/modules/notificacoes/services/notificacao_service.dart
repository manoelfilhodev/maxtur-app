import 'package:dio/dio.dart';
import 'package:systex_frotas/core/api/api_client.dart';
import 'package:systex_frotas/core/api/api_config.dart';
import 'package:systex_frotas/modules/notificacoes/models/notification_dto.dart';

class NotificacaoService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<NotificationDto>> listar() async {
    final response = await _dio.get(ApiConfig.notificationsPath);
    final env = ApiClient.envelope(response);
    if (env.data is! List) return <NotificationDto>[];
    return (env.data as List).whereType<Map<String, dynamic>>().map(NotificationDto.fromJson).toList();
  }

  Future<void> marcarComoLida(int id) async {
    await _dio.patch(ApiConfig.notificationReadPath(id));
  }

  Future<void> atualizarStatusSolicitacao(int id, String status) async {
    await _dio.patch(
      ApiConfig.adminSolicitacaoStatusPath(id),
      data: <String, dynamic>{'status': status},
    );
  }

  Future<void> atribuirSolicitacao({
    required int id,
    required int motoristaId,
    required int veiculoId,
  }) async {
    await _dio.patch(
      ApiConfig.adminSolicitacaoAtribuirPath(id),
      data: <String, dynamic>{
        'motorista_id': motoristaId,
        'veiculo_id': veiculoId,
      },
    );
  }
}
