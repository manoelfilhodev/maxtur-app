import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:systex_frotas/core/widgets/dg_badge.dart';
import 'package:systex_frotas/core/widgets/dg_card.dart';
import 'package:systex_frotas/core/widgets/dg_scaffold.dart';
import 'package:systex_frotas/core/widgets/dg_toast.dart';
import 'package:systex_frotas/modules/funcionario/models/funcionario_trip_dto.dart';
import 'package:systex_frotas/modules/funcionario/models/stop_point_dto.dart';
import 'package:systex_frotas/modules/funcionario/services/funcionario_trip_service.dart';
import 'package:systex_frotas/modules/funcionario/widgets/stops_timeline.dart';

class FuncionarioRastreamentoScreen extends StatefulWidget {
  const FuncionarioRastreamentoScreen({super.key});

  @override
  State<FuncionarioRastreamentoScreen> createState() => _FuncionarioRastreamentoScreenState();
}

class _FuncionarioRastreamentoScreenState extends State<FuncionarioRastreamentoScreen> {
  final FuncionarioTripService _service = FuncionarioTripService();
  GoogleMapController? _mapController;
  Timer? _timer;
  int _pollTick = 0;

  bool _loading = true;
  FuncionarioTripDto? _trip;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final trip = await _service.getTripActive(tick: _pollTick);
      _pollTick += 1;
      final computedStops = _computeStopStatuses(
        vehicleLat: trip.posicaoLat,
        vehicleLng: trip.posicaoLng,
        stops: trip.stops,
      );
      final finalTrip = trip.copyWith(stops: computedStops);
      if (!mounted) return;
      setState(() => _trip = finalTrip);
      final target = LatLng(finalTrip.posicaoLat, finalTrip.posicaoLng);
      _mapController?.animateCamera(CameraUpdate.newLatLng(target));
    } catch (_) {
      if (!silent && mounted) DgToast.show(context, 'Falha ao carregar rastreamento.', isError: true);
    } finally {
      if (!silent && mounted) setState(() => _loading = false);
    }
  }

  List<StopPointDto> _computeStopStatuses({
    required double vehicleLat,
    required double vehicleLng,
    required List<StopPointDto> stops,
  }) {
    final updated = stops
        .map((s) {
          final distance = _distanceMeters(vehicleLat, vehicleLng, s.lat, s.lng);
          if (distance < 100) return s.copyWith(status: 'passou');
          return s.copyWith(status: 'pendente');
        })
        .toList();

    final firstPending = updated.indexWhere((s) => s.status == 'pendente');
    if (firstPending >= 0) {
      updated[firstPending] = updated[firstPending].copyWith(status: 'atual');
    }
    return updated;
  }

  double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) * math.cos(_degToRad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180);

  Set<Marker> _buildMarkers(FuncionarioTripDto trip) {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('vehicle'),
        position: LatLng(trip.posicaoLat, trip.posicaoLng),
        infoWindow: InfoWindow(title: 'Veículo ${trip.vehiclePlaca}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    };

    for (final stop in trip.stops) {
      markers.add(
        Marker(
          markerId: MarkerId('stop_${stop.id}'),
          position: LatLng(stop.lat, stop.lng),
          infoWindow: InfoWindow(title: stop.nome, snippet: 'Previsto ${stop.horarioPrevisto}'),
          icon: BitmapDescriptor.defaultMarkerWithHue(_stopHue(stop.status)),
        ),
      );
    }
    return markers;
  }

  double _stopHue(String status) {
    switch (status) {
      case 'passou':
        return BitmapDescriptor.hueGreen;
      case 'atual':
        return BitmapDescriptor.hueYellow;
      default:
        return BitmapDescriptor.hueRose;
    }
  }

  Set<Polyline> _buildPolylines(FuncionarioTripDto trip) {
    final points = <LatLng>[
      LatLng(trip.posicaoLat, trip.posicaoLng),
      ...trip.stops.map((s) => LatLng(s.lat, s.lng)),
    ];
    return <Polyline>{
      Polyline(
        polylineId: const PolylineId('trip_route'),
        points: points,
        width: 4,
        color: const Color(0xFFFF4B4B),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final trip = _trip;
    return DgScaffold(
      appBar: AppBar(
        title: const Text('Rastrear Fretado'),
        actions: [
          if (trip != null) DgBadge(status: trip.mock ? 'mock' : 'ao vivo'),
          IconButton(onPressed: () => _load(), icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      child: _loading && trip == null
          ? const Center(child: CircularProgressIndicator())
          : trip == null
              ? const Center(child: Text('Sem viagem ativa no momento.'))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final mapHeight = constraints.maxHeight * 0.60;
                    return Column(
                      children: [
                        SizedBox(
                          height: mapHeight,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: GoogleMap(
                              onMapCreated: (c) => _mapController = c,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(trip.posicaoLat, trip.posicaoLng),
                                zoom: 13,
                              ),
                              markers: _buildMarkers(trip),
                              polylines: _buildPolylines(trip),
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        DgCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(trip.rotaNome, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text('Motorista: ${trip.motoristaNome}'),
                              Text('Saída: ${trip.horarioSaida}'),
                              Text('Chegada prevista: ${trip.previsaoChegada}'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(child: StopsTimeline(stops: trip.stops)),
                      ],
                    );
                  },
                ),
    );
  }
}
