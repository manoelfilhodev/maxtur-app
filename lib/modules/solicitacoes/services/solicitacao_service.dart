import 'package:dio/dio.dart';
import 'package:systex_frotas/core/api/api_client.dart';
import 'package:systex_frotas/core/api/api_config.dart';
import 'package:systex_frotas/modules/solicitacoes/models/solicitacao_dto.dart';

class SolicitacaoService {
  final Dio _dio = ApiClient.instance.dio;

  Future<void> criar({
    required String origem,
    required String destino,
    required String dataHora,
    required int passageirosPrevistos,
    String? observacao,
    List<int>? passageiroIds,
  }) async {
    await _dio.post(
      ApiConfig.clienteSolicitacoesPath,
      data: <String, dynamic>{
        'origem': origem,
        'destino': destino,
        'data_hora': dataHora,
        'passageiros_previstos': passageirosPrevistos,
        if (observacao != null && observacao.isNotEmpty) 'observacao': observacao,
        if (passageiroIds != null && passageiroIds.isNotEmpty) 'passageiro_ids': passageiroIds,
      },
    );
  }

  Future<List<SolicitacaoDto>> listar() async {
    final response = await _dio.get(ApiConfig.clienteSolicitacoesPath);
    final env = ApiClient.envelope(response);
    if (env.data is! List) return <SolicitacaoDto>[];
    return (env.data as List).whereType<Map<String, dynamic>>().map(SolicitacaoDto.fromJson).toList();
  }

  Future<SolicitacaoDto> detalhe(int id) async {
    final response = await _dio.get('${ApiConfig.clienteSolicitacoesPath}/$id');
    final env = ApiClient.envelope(response);
    if (env.data is! Map<String, dynamic>) throw Exception('Detalhe inválido.');
    return SolicitacaoDto.fromJson(env.data as Map<String, dynamic>);
  }
}
