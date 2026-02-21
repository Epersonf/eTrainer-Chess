import 'package:dio/dio.dart';

abstract class BaseApi {
  static final Dio _dio = Dio();

  static Future<Response> _executeRequest(
    Future<Response> Function() requestFunction,
  ) async {
    _initializeToken();
    try {
      return await requestFunction();
    } on DioException catch (e) {
      if (_isServiceUnavailable(e)) {
        throw Exception(
            'Serviço indisponível no momento. Por favor, tente novamente mais tarde.');
      }
      rethrow;
    }
  }

  static Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _executeRequest(() => _dio.get(
          path,
          queryParameters: queryParameters,
        ));
  }

  static Future<Response> post(String path, {Object? data}) async {
    return _executeRequest(() => _dio.post(
          path,
          data: data,
        ));
  }

  static Future<Response> put(String path, {Object? data}) async {
    return _executeRequest(() => _dio.put(
          path,
          data: data,
        ));
  }

  static Future<Response> patch(String path, {Object? data}) async {
    return _executeRequest(() => _dio.patch(
          path,
          data: data,
        ));
  }

  static Future<Response> delete(String path, {Object? data}) async {
    return _executeRequest(() => _dio.delete(
          path,
          data: data,
        ));
  }

  static bool _isServiceUnavailable(DioException e) {
    // Timeout, erro de conexão, ou status 500/503
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError;
  }

  static String? _initializeToken() {
    return null;
    // var token = AuthTokenPrefs.get();
    // setToken(token);
    // return token;
  }

  static void setToken(String? token) async {
    if (token == null) {
      resetToken();
      return;
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void resetToken() {
    _dio.options.headers.remove('Authorization');
  }
}
