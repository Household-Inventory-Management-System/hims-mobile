class ApiResponse<T> {
  final T? data;
  final int statusCode;
  final String? error;

  ApiResponse({this.data, required this.statusCode, this.error});

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}
