class ApiEnvelope<T> {
  ApiEnvelope({
    required this.ok,
    required this.message,
    required this.data,
  });

  final bool ok;
  final String message;
  final T data;

  static ApiEnvelope<dynamic> fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ApiEnvelope<dynamic>(
        ok: json['ok'] == true,
        message: (json['message'] ?? '').toString(),
        data: json['data'],
      );
    }
    return ApiEnvelope<dynamic>(ok: true, message: '', data: json);
  }
}
