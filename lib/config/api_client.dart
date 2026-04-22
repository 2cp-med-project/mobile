// config/api_client.dart
// Central HTTP client — all requests go through here

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'storage_helper.dart';

class ApiClient {

 static const baseUrl = 'http://192.168.30.54:5000/api'; 

  // Increased timeout — 30s for slow local networks
  static const Duration _timeout = Duration(seconds: 30);

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept':       'application/json',
    };
    if (auth) {
      final token = await StorageHelper.getToken();
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  static Future<ApiResponse> get(String path) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl$path'), headers: await _headers())
          .timeout(_timeout);
      return _handle(res);
    } catch (e) {
      return ApiResponse.networkError(_friendlyError(e));
    }
  }

  static Future<ApiResponse> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: await _headers(auth: auth),
            body:    jsonEncode(body),
          )
          .timeout(_timeout);
      return _handle(res);
    } catch (e) {
      return ApiResponse.networkError(_friendlyError(e));
    }
  }

  static Future<ApiResponse> patch(
      String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .patch(Uri.parse('$baseUrl$path'),
              headers: await _headers(), body: jsonEncode(body))
          .timeout(_timeout);
      return _handle(res);
    } catch (e) {
      return ApiResponse.networkError(_friendlyError(e));
    }
  }

  static Future<ApiResponse> put(
      String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .put(Uri.parse('$baseUrl$path'),
              headers: await _headers(), body: jsonEncode(body))
          .timeout(_timeout);
      return _handle(res);
    } catch (e) {
      return ApiResponse.networkError(_friendlyError(e));
    }
  }

  static Future<ApiResponse> delete(String path) async {
    try {
      final res = await http
          .delete(Uri.parse('$baseUrl$path'), headers: await _headers())
          .timeout(_timeout);
      return _handle(res);
    } catch (e) {
      return ApiResponse.networkError(_friendlyError(e));
    }
  }

  static Future<ApiResponse> uploadFile(
      String path, String filePath, String fieldName) async {
    try {
      final req = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl$path'));
      final token = await StorageHelper.getToken();
      if (token != null) req.headers['Authorization'] = 'Bearer $token';
      req.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      final streamed = await req.send().timeout(_timeout);
      final res = await http.Response.fromStream(streamed);
      return _handle(res);
    } catch (e) {
      return ApiResponse.networkError(_friendlyError(e));
    }
  }

  static ApiResponse _handle(http.Response res) {
    dynamic parsed;
    try { parsed = jsonDecode(res.body); } catch (_) { parsed = {}; }
    final ok = res.statusCode >= 200 && res.statusCode < 300;
    String? errMsg;
    if (!ok) {
      if (parsed is Map) {
        errMsg = parsed['message']?.toString() ??
                 parsed['error']?.toString()   ??
                 'Erreur ${res.statusCode}';
      } else {
        errMsg = 'Erreur ${res.statusCode}';
      }
    }
    return ApiResponse(
        statusCode: res.statusCode, data: parsed,
        success: ok, error: errMsg);
  }

  // Convert technical exceptions into readable French messages
  static String _friendlyError(Object e) {
    final msg = e.toString();
    if (e is SocketException || msg.contains('Connection refused')) {
      return 'Impossible de joindre le serveur.\n'
          'Vérifiez que votre backend est démarré et que l\'adresse IP est correcte.';
    }
    if (msg.contains('TimeoutException') || msg.contains('timed out')) {
      return 'Le serveur ne répond pas.\n'
          'Vérifiez que votre téléphone et votre PC sont sur le même réseau Wi-Fi.';
    }
    if (e is HandshakeException) {
      return 'Erreur SSL. Utilisez http:// pour les tests locaux.';
    }
    return 'Erreur réseau : $msg';
  }
}

class ApiResponse {
  final int     statusCode;
  final dynamic data;
  final String? error;
  final bool    success;

  const ApiResponse({
    required this.statusCode,
    required this.data,
    required this.success,
    this.error,
  });

  factory ApiResponse.networkError(String msg) => ApiResponse(
        statusCode: 0, data: {}, success: false,
        error: msg);
}