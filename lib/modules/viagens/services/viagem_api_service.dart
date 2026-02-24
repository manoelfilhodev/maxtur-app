import 'package:dio/dio.dart';
import 'package:systex_frotas/core/api/api_client.dart';
import 'package:systex_frotas/core/api/api_config.dart';
import 'package:systex_frotas/modules/viagens/models/viagem_models.dart';

class ViagemApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<Funcionario>> getFuncionarios() async {
    final response = await _dio.get(ApiConfig.funcionariosPath);
    final list = _extractList(response.data);
    return list.whereType<Map<String, dynamic>>().map(Funcionario.fromJson).toList();
  }

  Future<void> postSolicitacao(Map<String, dynamic> payload) async {
    await _dio.post(ApiConfig.viagensSolicitacoesPath, data: payload);
  }

  Future<List<ViagemSolicitacao>> getMinhas(String email) async {
    final response = await _dio.get(ApiConfig.viagensMinhasPath, queryParameters: {'email': email});
    final list = _extractList(response.data);
    return list.whereType<Map<String, dynamic>>().map(ViagemSolicitacao.fromJson).toList();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List<dynamic>) return data;
    if (data is Map<String, dynamic>) {
      final list = data['data'] ?? data['solicitacoes'] ?? data['funcionarios'];
      if (list is List<dynamic>) return list;
    }
    return <dynamic>[];
  }
}
