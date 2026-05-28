import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/storage_helper.dart';

class ConsultationService {
  static Future<List<dynamic>> getConsultations({
    required String patientId,
    int page = 0,
    int limit = 20,
    String order = 'desc',
    String sortBy = 'date',
  }) async {
    final token = await StorageHelper.getToken();

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}'
      '${ApiConfig.recordsByPatient(patientId)}'
      '?page=$page'
      '&limit=$limit'
      '&order=$order'
      '&sortBy=$sortBy',
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // adapt depending on backend response
      return data['consultations'] ??
          data['data'] ??
          data;
    }

    throw Exception(
      'Failed to load consultations: ${response.statusCode}',
    );
  }
}