import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class HttpJsonClient {
  const HttpJsonClient({
    http.Client? client,
    this.timeout = const Duration(seconds: 12),
  }) : _client = client;

  final http.Client? _client;
  final Duration timeout;

  Future<Object?> getJson(
    Uri uri, {
    Map<String, String> headers = const {},
  }) async {
    final client = _client ?? http.Client();
    try {
      final response = await client.get(uri, headers: headers).timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'Respuesta HTTP no exitosa.',
          statusCode: response.statusCode,
        );
      }
      if (response.body.trim().isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException('No se pudo consultar el servicio: $error');
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }
}
