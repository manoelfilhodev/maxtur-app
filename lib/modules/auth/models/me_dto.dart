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

  String get roleKey => role.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9]'), '');

  bool get isMotorista => const <String>{'motorista', 'driver'}.contains(roleKey);
  bool get isCliente => const <String>{'cliente', 'client', 'clientefinal'}.contains(roleKey);
  bool get isAdmin => const <String>{'admin', 'administrador', 'operador'}.contains(roleKey);

  factory MeDto.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic> ? json['user'] as Map<String, dynamic> : <String, dynamic>{};
    return MeDto(
      userId: _toInt(user['id']),
      userName: (user['name'] ?? '').toString(),
      role: (user['role'] ?? '').toString(),
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
