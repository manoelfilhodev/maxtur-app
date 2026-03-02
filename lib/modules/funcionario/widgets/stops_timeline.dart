import 'package:flutter/material.dart';
import 'package:systex_frotas/modules/funcionario/models/stop_point_dto.dart';

class StopsTimeline extends StatelessWidget {
  const StopsTimeline({super.key, required this.stops});

  final List<StopPointDto> stops;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: stops.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final stop = stops[index];
        final color = _statusColor(stop.status);
        return Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.55),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stop.nome, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('Previsto: ${stop.horarioPrevisto}'),
                ],
              ),
            ),
            Text(_statusLabel(stop.status)),
          ],
        );
      },
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'passou':
        return const Color(0xFF3CD070);
      case 'atual':
        return const Color(0xFFFFC85A);
      default:
        return const Color(0xFF8A8A92);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'passou':
        return 'Passou';
      case 'atual':
        return 'Atual';
      default:
        return 'Pendente';
    }
  }
}
