class NotificationDto {
  NotificationDto({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.readAt,
    required this.referenceId,
  });

  final int id;
  final String type;
  final String title;
  final String body;
  final String? readAt;
  final int? referenceId;

  bool get isRead => readAt != null && readAt!.isNotEmpty;

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: _toInt(json['id']),
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? json['message'] ?? '').toString(),
      readAt: json['read_at']?.toString(),
      referenceId: _toNullableInt(json['reference_id']),
    );
  }
}

int _toInt(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;

int? _toNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse('$value');
}
