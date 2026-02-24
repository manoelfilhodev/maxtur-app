class VeiculoDto {
  VeiculoDto({
    required this.id,
    required this.placa,
    required this.descricao,
  });

  final int id;
  final String placa;
  final String descricao;

  factory VeiculoDto.fromJson(Map<String, dynamic> json) {
    return VeiculoDto(
      id: _toInt(json['id']),
      placa: (json['placa'] ?? '').toString(),
      descricao: (json['descricao'] ?? json['modelo'] ?? '').toString(),
    );
  }
}

class ChecklistDto {
  ChecklistDto({
    required this.id,
    required this.status,
    required this.veiculoId,
    required this.itens,
  });

  final int id;
  final String status;
  final int veiculoId;
  final List<ItemDto> itens;

  factory ChecklistDto.fromJson(Map<String, dynamic> json) {
    final rawItens = json['itens'] ?? json['items'] ?? <dynamic>[];
    final itens = rawItens is List
        ? rawItens.whereType<Map<String, dynamic>>().map(ItemDto.fromJson).toList()
        : <ItemDto>[];

    return ChecklistDto(
      id: _toInt(json['id']),
      status: (json['status'] ?? '').toString(),
      veiculoId: _toInt(json['veiculo_id']),
      itens: itens,
    );
  }
}

class ItemDto {
  ItemDto({
    required this.id,
    required this.codigo,
    required this.titulo,
    required this.obrigatorio,
  });

  final int id;
  final String codigo;
  final String titulo;
  final bool obrigatorio;

  factory ItemDto.fromJson(Map<String, dynamic> json) {
    return ItemDto(
      id: _toInt(json['id']),
      codigo: (json['codigo'] ?? json['id'] ?? '').toString(),
      titulo: (json['titulo'] ?? json['nome'] ?? '').toString(),
      obrigatorio: _toBool(json['obrigatorio']),
    );
  }
}

class RespostaDto {
  RespostaDto({
    required this.itemId,
    required this.status,
    this.observacao,
    this.fotoBase64,
  });

  final int itemId;
  final String status;
  final String? observacao;
  final String? fotoBase64;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'item_id': itemId,
      'status': status,
      if (observacao != null && observacao!.isNotEmpty) 'observacao': observacao,
      if (fotoBase64 != null && fotoBase64!.isNotEmpty) 'foto_base64': fotoBase64,
    };
  }
}

int _toInt(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value == 1;
  final lower = '$value'.toLowerCase();
  return lower == 'true' || lower == '1';
}
