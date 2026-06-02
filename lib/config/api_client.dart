import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'storage_helper.dart';
import 'api_endpoints.dart';

class ApiClient {
<<<<<<< HEAD
  //static const baseUrl ='http://10.58.114.26:5000/api';
=======
  static const baseUrl =
      'http://10.68.13.26:5000/api';
>>>>>>> origin/main

  static const Duration _timeout =
      Duration(seconds: 20);
 //static const baseUrl = 'http://192.168.30.54:5000/api'; 
  //static const baseUrl = 'http://172.23.213.202:5000/api'; 
static const baseUrl = 'http://192.168.1.13:5000/api'; // Android emulator localhost
 

  static Future<Map<String, String>> _headers({
    bool auth = true,
  }) async {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token =
          await StorageHelper.getToken();

      if (token != null) {
        h['Authorization'] =
            'Bearer $token';
      }
    }

    return h;
  }

  //  Refresh token 

  static Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken =
          await StorageHelper
              .getRefreshToken();

      if (refreshToken == null) {
        return false;
      }

      final res = await http
          .post(
            Uri.parse(
              '$baseUrl${Endpoints.refreshToken}',
            ),
            headers: {
              'Content-Type':
                  'application/json',
              'Accept':
                  'application/json',
            },
            body: jsonEncode({
              'refreshToken':
                  refreshToken,
            }),
          )
          .timeout(_timeout);

      if (res.statusCode >= 200 &&
          res.statusCode < 300) {
        final data =
            jsonDecode(res.body);

        // adapt field name if backend differs
        final newToken =
            data['token'] ??
            data['accessToken'];

        if (newToken != null) {
          await StorageHelper.saveToken(
            newToken,
          );

          return true;
        }
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  //  Request wrapper 

  static Future<ApiResponse>
      _sendWithRetry(
    Future<http.Response> Function()
        request,
  ) async {
    try {
      var response = await request()
          .timeout(_timeout);

      // access token expired
      if (response.statusCode == 401) {
        final refreshed =
            await _refreshAccessToken();

        if (refreshed) {
          response = await request()
              .timeout(_timeout);
        } else {
          await StorageHelper.clear();
        }
      }

      return _handle(response);
    } catch (e) {
      return ApiResponse.networkError(
        _friendlyError(e),
      );
    }
  }

  //  GET 

  static Future<ApiResponse> get(
    String path,
  ) async {
    return _sendWithRetry(
      () async => http.get(
        Uri.parse('$baseUrl$path'),
        headers: await _headers(),
      ),
    );
  }

  //  POST 

  static Future<ApiResponse> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    return _sendWithRetry(
      () async => http.post(
        Uri.parse('$baseUrl$path'),
        headers:
            await _headers(auth: auth),
        body: jsonEncode(body),
      ),
    );
  }

  //  PATCH 

  static Future<ApiResponse> patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _sendWithRetry(
      () async => http.patch(
        Uri.parse('$baseUrl$path'),
        headers: await _headers(),
        body: jsonEncode(body),
      ),
    );
  }

  //  PUT 

  static Future<ApiResponse> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _sendWithRetry(
      () async => http.put(
        Uri.parse('$baseUrl$path'),
        headers: await _headers(),
        body: jsonEncode(body),
      ),
    );
  }

  //  DELETE 

  static Future<ApiResponse> delete(
    String path,
  ) async {
    return _sendWithRetry(
      () async => http.delete(
        Uri.parse('$baseUrl$path'),
        headers: await _headers(),
      ),
    );
  }

  //  Upload 

  static Future<ApiResponse>
      uploadFile(
    String path,
    String filePath,
    String fieldName,
  ) async {
    try {
      final req =
          http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$path'),
      );

      final token =
          await StorageHelper.getToken();

      if (token != null) {
        req.headers[
                'Authorization'] =
            'Bearer $token';
      }

      req.files.add(
        await http.MultipartFile
            .fromPath(
          fieldName,
          filePath,
        ),
      );

      final streamed =
          await req.send();

      final res =
          await http.Response.fromStream(
        streamed,
      );

      return _handle(res);
    } catch (e) {
      return ApiResponse.networkError(
        _friendlyError(e),
      );
    }
  }

  //  Response parser 

  static ApiResponse _handle(
    http.Response res,
  ) {
    dynamic parsed;

    try {
      parsed = jsonDecode(res.body);
    } catch (_) {
      parsed = {};
    }

    final ok =
        res.statusCode >= 200 &&
            res.statusCode < 300;

    String? errMsg;

    if (!ok) {
      if (parsed is Map) {
        errMsg =
            parsed['message']
                    ?.toString() ??
                parsed['error']
                    ?.toString() ??
                'Erreur ${res.statusCode}';
      } else {
        errMsg =
            'Erreur ${res.statusCode}';
      }
    }

    return ApiResponse(
      statusCode: res.statusCode,
      data: parsed,
      success: ok,
      error: errMsg,
    );
  }

  //  Friendly errors 

  static String _friendlyError(
    Object e,
  ) {
    final msg = e.toString();

    if (e is SocketException ||
        msg.contains(
            'Connection refused')) {
      return 'Impossible de joindre le serveur.\n'
          'Vérifiez que votre backend est démarré et que l\'adresse IP est correcte.';
    }

    if (msg.contains(
            'TimeoutException') ||
        msg.contains(
            'timed out')) {
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
  final int statusCode;
  final dynamic data;
  final String? error;
  final bool success;

  const ApiResponse({
    required this.statusCode,
    required this.data,
    required this.success,
    this.error,
  });

  factory ApiResponse.networkError(
    String msg,
  ) {
    return ApiResponse(
      statusCode: 0,
      data: {},
      success: false,
      error: msg,
    );
  }
}