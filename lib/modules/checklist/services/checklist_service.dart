import 'package:dio/dio.dart';
import 'package:systex_frotas/core/api/api_client.dart';
import 'package:systex_frotas/core/api/api_config.dart';
import 'package:systex_frotas/modules/checklist/models/checklist_dto.dart';

class ChecklistService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<VeiculoDto>> listarVeiculos() async {
    final response = await _dio.get(ApiConfig.checklistsVeiculosPath);
    final env = ApiClient.envelope(response);
    final data = env.data;
    if (data is! List) return <VeiculoDto>[];
    return data.whereType<Map<String, dynamic>>().map(VeiculoDto.fromJson).toList();
  }

  Future<ChecklistDto> iniciar(int veiculoId) async {
    final response = await _dio.post(
      ApiConfig.checklistIniciarPath,
      data: <String, dynamic>{'veiculo_id': veiculoId},
    );
    final env = ApiClient.envelope(response);
    if (env.data is! Map<String, dynamic>) throw Exception('Checklist inválido.');
    return ChecklistDto.fromJson(env.data as Map<String, dynamic>);
  }

  Future<ChecklistDto> detalhe(int checklistId) async {
    final response = await _dio.get(ApiConfig.checklistDetailPath(checklistId));
    final env = ApiClient.envelope(response);
    if (env.data is! Map<String, dynamic>) throw Exception('Checklist inválido.');
    return ChecklistDto.fromJson(env.data as Map<String, dynamic>);
  }

  Future<void> enviarRespostas(int checklistId, List<RespostaDto> respostas) async {
    await _dio.post(
      ApiConfig.checklistRespostasPath(checklistId),
      data: <String, dynamic>{'respostas': respostas.map((r) => r.toJson()).toList()},
    );
  }

  Future<Map<String, dynamic>> finalizar(int checklistId) async {
    final response = await _dio.post(ApiConfig.checklistFinalizarPath(checklistId));
    final env = ApiClient.envelope(response);
    if (env.data is Map<String, dynamic>) return env.data as Map<String, dynamic>;
    return <String, dynamic>{};
  }
}
