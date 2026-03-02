class StopPointDto {
  const StopPointDto({
    required this.id,
    required this.nome,
    required this.lat,
    required this.lng,
    required this.horarioPrevisto,
    required this.status,
  });

  final int id;
  final String nome;
  final double lat;
  final double lng;
  final String horarioPrevisto;
  final String status;

  factory StopPointDto.fromJson(Map<String, dynamic> json) {
    return StopPointDto(
      id: _toInt(json['id']),
      nome: (json['nome'] ?? '').toString(),
      lat: _toDouble(json['lat']),
      lng: _toDouble(json['lng']),
      horarioPrevisto: (json['horarioPrevisto'] ?? json['horario_previsto'] ?? '').toString(),
      status: (json['status'] ?? 'pendente').toString(),
    );
  }

  StopPointDto copyWith({
    int? id,
    String? nome,
    double? lat,
    double? lng,
    String? horarioPrevisto,
    String? status,
  }) {
    return StopPointDto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      horarioPrevisto: horarioPrevisto ?? this.horarioPrevisto,
      status: status ?? this.status,
    );
  }
}

int _toInt(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}
