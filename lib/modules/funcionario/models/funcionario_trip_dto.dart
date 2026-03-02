import 'package:systex_frotas/modules/funcionario/models/stop_point_dto.dart';

class FuncionarioTripDto {
  FuncionarioTripDto({
    required this.rotaId,
    required this.rotaNome,
    required this.motoristaNome,
    required this.vehicleId,
    required this.vehiclePlaca,
    required this.posicaoLat,
    required this.posicaoLng,
    required this.horarioSaida,
    required this.previsaoChegada,
    required this.stops,
    this.mock = false,
  });

  final int rotaId;
  final String rotaNome;
  final String motoristaNome;
  final int vehicleId;
  final String vehiclePlaca;
  final double posicaoLat;
  final double posicaoLng;
  final String horarioSaida;
  final String previsaoChegada;
  final List<StopPointDto> stops;
  final bool mock;

  factory FuncionarioTripDto.fromJson(Map<String, dynamic> json) {
    final rota = json['rota'] is Map<String, dynamic> ? json['rota'] as Map<String, dynamic> : <String, dynamic>{};
    final motorista = json['motorista'] is Map<String, dynamic>
        ? json['motorista'] as Map<String, dynamic>
        : <String, dynamic>{};
    final vehicle = json['vehicle'] is Map<String, dynamic> ? json['vehicle'] as Map<String, dynamic> : <String, dynamic>{};
    final posicao = json['posicaoAtual'] is Map<String, dynamic>
        ? json['posicaoAtual'] as Map<String, dynamic>
        : <String, dynamic>{};
    final rawStops = json['stops'] is List ? json['stops'] as List : <dynamic>[];

    return FuncionarioTripDto(
      rotaId: _toInt(rota['id']),
      rotaNome: (rota['nome'] ?? '').toString(),
      motoristaNome: (motorista['nome'] ?? '').toString(),
      vehicleId: _toInt(vehicle['id']),
      vehiclePlaca: (vehicle['placa'] ?? '').toString(),
      posicaoLat: _toDouble(posicao['lat']),
      posicaoLng: _toDouble(posicao['lng']),
      horarioSaida: (json['horarioSaida'] ?? json['horario_saida'] ?? '--:--').toString(),
      previsaoChegada: (json['previsaoChegada'] ?? json['previsao_chegada'] ?? '--:--').toString(),
      stops: rawStops.whereType<Map<String, dynamic>>().map(StopPointDto.fromJson).toList(),
    );
  }

  FuncionarioTripDto copyWith({
    double? posicaoLat,
    double? posicaoLng,
    List<StopPointDto>? stops,
    bool? mock,
  }) {
    return FuncionarioTripDto(
      rotaId: rotaId,
      rotaNome: rotaNome,
      motoristaNome: motoristaNome,
      vehicleId: vehicleId,
      vehiclePlaca: vehiclePlaca,
      posicaoLat: posicaoLat ?? this.posicaoLat,
      posicaoLng: posicaoLng ?? this.posicaoLng,
      horarioSaida: horarioSaida,
      previsaoChegada: previsaoChegada,
      stops: stops ?? this.stops,
      mock: mock ?? this.mock,
    );
  }
}

int _toInt(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}
