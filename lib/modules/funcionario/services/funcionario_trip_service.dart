import 'dart:math';

import 'package:dio/dio.dart';
import 'package:systex_frotas/core/api/api_client.dart';
import 'package:systex_frotas/core/api/api_config.dart';
import 'package:systex_frotas/modules/funcionario/models/funcionario_trip_dto.dart';
import 'package:systex_frotas/modules/funcionario/models/stop_point_dto.dart';

class FuncionarioTripService {
  final Dio _dio = ApiClient.instance.dio;

  Future<FuncionarioTripDto> getTripActive({required int tick}) async {
    try {
      final response = await _dio.get(ApiConfig.funcionarioTripActivePath);
      final env = ApiClient.envelope(response);
      if (env.data is! Map<String, dynamic>) throw Exception('Trip ativa inválida.');
      return FuncionarioTripDto.fromJson(env.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;
      final allowMock = status == 404 || status == 405 || status >= 500 || e.type == DioExceptionType.connectionError;
      if (!allowMock) rethrow;
      return _mockTrip(tick);
    } catch (_) {
      return _mockTrip(tick);
    }
  }

  FuncionarioTripDto _mockTrip(int tick) {
    const points = <({double lat, double lng})>[
      (lat: -23.46090, lng: -46.57070),
      (lat: -23.45510, lng: -46.57520),
      (lat: -23.45100, lng: -46.57920),
      (lat: -23.44730, lng: -46.58350),
      (lat: -23.44310, lng: -46.58810),
    ];

    final idx = min(tick % points.length, points.length - 1);
    final pos = points[idx];

    return FuncionarioTripDto(
      rotaId: 1,
      rotaNome: 'Rota Cajamar',
      motoristaNome: 'Carlos Silva',
      vehicleId: 10,
      vehiclePlaca: 'ABC-1234',
      posicaoLat: pos.lat,
      posicaoLng: pos.lng,
      horarioSaida: '05:30',
      previsaoChegada: '06:20',
      mock: true,
      stops: const <StopPointDto>[
        StopPointDto(
          id: 1,
          nome: 'Ponto 1',
          lat: -23.45510,
          lng: -46.57520,
          horarioPrevisto: '05:40',
          status: 'pendente',
        ),
        StopPointDto(
          id: 2,
          nome: 'Ponto 2',
          lat: -23.45100,
          lng: -46.57920,
          horarioPrevisto: '05:50',
          status: 'pendente',
        ),
        StopPointDto(
          id: 3,
          nome: 'Ponto 3',
          lat: -23.44730,
          lng: -46.58350,
          horarioPrevisto: '06:00',
          status: 'pendente',
        ),
        StopPointDto(
          id: 4,
          nome: 'Ponto 4',
          lat: -23.44310,
          lng: -46.58810,
          horarioPrevisto: '06:10',
          status: 'pendente',
        ),
      ],
    );
  }
}
