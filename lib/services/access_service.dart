// services/access_service.dart
// Maps to /api/access/* routes — doctor ↔ patient permissions
// This powers demandes_screen.dart

import '../config/api_client.dart';
import '../config/api_endpoints.dart';

class AccessService {

  // ────────────────────────────────────────────────────────────────────────
  //  GET PENDING REQUESTS   GET /api/access/patient/requests
  //  Patient sees which doctors have asked for access
  // ────────────────────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getPendingRequests() async {
    final res = await ApiClient.get(Endpoints.accessPatientRequests);
    if (!res.success) return [];
    final list = res.data as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  // ────────────────────────────────────────────────────────────────────────
  //  RESPOND TO REQUEST   PUT /api/access/{id}/respond
  //  Body: { accepted: true/false }
  // ────────────────────────────────────────────────────────────────────────
  static Future<String?> respondToRequest(String id, bool accepted) async {
    final res = await ApiClient.put(
      Endpoints.accessRespond(id),
      {'accepted': accepted},
    );
    if (!res.success) return res.error ?? 'Échec de la réponse';
    return null;
  }

  // ────────────────────────────────────────────────────────────────────────
  //  GET APPROVED DOCTORS   GET /api/access/patient/doctors
  //  Patient sees approved doctors
  // ────────────────────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getApprovedDoctors() async {
    final res = await ApiClient.get(Endpoints.accessPatientDoctors);
    if (!res.success) return [];
    final list = res.data as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  // ────────────────────────────────────────────────────────────────────────
  //  REMOVE DOCTOR   DELETE /api/access/{id}
  // ────────────────────────────────────────────────────────────────────────
  static Future<String?> removeDoctor(String accessId) async {
    final res = await ApiClient.delete(Endpoints.accessDelete(accessId));
    if (!res.success) return res.error ?? 'Suppression échouée';
    return null;
  }
}