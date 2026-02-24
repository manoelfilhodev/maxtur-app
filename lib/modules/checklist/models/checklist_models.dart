class Checklist {
  Checklist({required this.id, required this.nome, required this.descricao, required this.itens});

  final int id;
  final String nome;
  final String descricao;
  final List<ChecklistItem> itens;

  factory Checklist.fromJson(Map<String, dynamic> json) {
    final itens = (json['itens'] ?? json['items'] ?? <dynamic>[]) as List<dynamic>;
    return Checklist(
      id: _toInt(json['id']),
      nome: (json['nome'] ?? json['titulo'] ?? 'Checklist').toString(),
      descricao: (json['descricao'] ?? '').toString(),
      itens: itens.whereType<Map<String, dynamic>>().map(ChecklistItem.fromJson).toList(),
    );
  }

  static int _toInt(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
}

class ChecklistItem {
  ChecklistItem({
    required this.id,
    required this.codigo,
    required this.titulo,
    required this.descricao,
    required this.obrigatorio,
  });

  final int id;
  final String codigo;
  final String titulo;
  final String descricao;
  final bool obrigatorio;

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: _toInt(json['id']),
      codigo: (json['codigo'] ?? json['id'] ?? '').toString(),
      titulo: (json['titulo'] ?? json['nome'] ?? '').toString(),
      descricao: (json['descricao'] ?? '').toString(),
      obrigatorio: _toBool(json['obrigatorio']),
    );
  }

  static int _toInt(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;
    return '$value'.toLowerCase() == 'true';
  }
}

class ChecklistResposta {
  ChecklistResposta({
    required this.codigo,
    required this.status,
    required this.observacao,
    this.fotoBase64,
  });

  final String codigo;
  final String status;
  final String observacao;
  final String? fotoBase64;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'codigo': codigo,
      'status': status,
      'observacao': observacao,
    };
    if (fotoBase64 != null && fotoBase64!.isNotEmpty) data['foto_base64'] = fotoBase64;
    return data;
  }
}
