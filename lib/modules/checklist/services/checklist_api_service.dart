import 'package:dio/dio.dart';
import 'package:systex_frotas/core/api/api_client.dart';
import 'package:systex_frotas/core/api/api_config.dart';
import 'package:systex_frotas/modules/checklist/models/checklist_models.dart';

class ChecklistApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<Checklist>> getAll() async {
    final response = await _dio.get(ApiConfig.checklistsPath);
    final list = _extractList(response.data);
    return list.whereType<Map<String, dynamic>>().map(Checklist.fromJson).toList();
  }

  Future<Checklist> getById(int id) async {
    final response = await _dio.get(ApiConfig.checklistDetailPath(id));
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final core = data['data'];
      if (core is Map<String, dynamic>) return Checklist.fromJson(core);
      return Checklist.fromJson(data);
    }
    throw Exception('Resposta inválida para checklist.');
  }

  Future<void> postRespostas(int id, List<ChecklistResposta> respostas) async {
    await _dio.post(
      ApiConfig.checklistRespostasPath(id),
      data: respostas.map((e) => e.toJson()).toList(),
    );
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List<dynamic>) return data;
    if (data is Map<String, dynamic>) {
      final list = data['data'] ?? data['checklists'];
      if (list is List<dynamic>) return list;
    }
    return <dynamic>[];
  }
}
