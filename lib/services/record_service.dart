// services/record_service.dart
// Maps to /api/record/* routes — medical consultations = dossier files

import '../config/api_client.dart';
import '../config/api_endpoints.dart';

class RecordService {

  // ────────────────────────────────────────────────────────────────────────
  //  GET CONSULTATIONS FOR PATIENT
  //  GET /api/record/{patientId}?page=0&limit=10&order=desc&sortBy=date
  // ────────────────────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getRecords({
    required String patientId,
    int    page    = 0,
    int    limit   = 20,
    String order   = 'desc',
    String sortBy  = 'date',
  }) async {
    final path = '${Endpoints.recordsByPatient(patientId)}'
        '?page=$page&limit=$limit&order=$order&sortBy=$sortBy';
    final res = await ApiClient.get(path);
    if (!res.success) return [];

    // Response may be { data: [...], total: N } or just [...]
    final body = res.data;
    if (body is List) return body.cast<Map<String, dynamic>>();
    if (body is Map && body['data'] is List) {
      return (body['data'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  // ────────────────────────────────────────────────────────────────────────
  //  GET SINGLE CONSULTATION
  //  GET /api/record/consultation/{consultationId}
  // ────────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getConsultation(String id) async {
    final res = await ApiClient.get(Endpoints.consultationById(id));
    if (!res.success) return null;
    return res.data as Map<String, dynamic>;
  }
}