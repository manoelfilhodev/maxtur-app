import 'package:systex_frotas/modules/auth/models/role_type.dart';

class MeDto {
  MeDto({
    required this.userId,
    required this.userName,
    required this.role,
    required this.operadorId,
    required this.clienteId,
  });

  final int userId;
  final String userName;
  final String role;
  final int operadorId;
  final int? clienteId;
  String get displayName {
    final full = userName.trim();
    if (full.isEmpty) return 'Usuário';
    final parts = full.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'Usuário';
    if (parts.length == 1) return parts.first;
    return '${parts.first} ${parts.last}';
  }

  RoleType get roleType => RoleParser.parse(role);

  factory MeDto.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic> ? json['user'] as Map<String, dynamic> : <String, dynamic>{};
    return MeDto(
      userId: _toInt(user['id']),
      userName: (user['name'] ?? user['nome'] ?? json['name'] ?? json['nome'] ?? '').toString(),
      role: (json['role'] ?? user['role'] ?? '').toString(),
      operadorId: _toInt(json['operador_id']),
      clienteId: _toNullableInt(json['cliente_id']),
    );
  }

  static int _toInt(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse('$value');
  }
}
