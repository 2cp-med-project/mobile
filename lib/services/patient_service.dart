import '../config/api_client.dart';
import '../config/api_endpoints.dart';

class PatientService {
  // ─────────────────────────────────────────────
  // UPDATE PROFILE
  // PATCH /users/me
  // ─────────────────────────────────────────────
  static Future<String?> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      print('📤 UPDATE PROFILE REQUEST:');
      print(data);

      final res = await ApiClient.patch(
        Endpoints.me, // '/users/me'
        data,
      );

      print('📥 UPDATE PROFILE RESPONSE:');
      print(res.data);

      if (!res.success) {
        print('❌ ERROR: ${res.error}');
        return res.error ?? 'Erreur mise à jour profil';
      }

      return null;
    } catch (e) {
      print('❌ EXCEPTION: $e');
      return 'Erreur de connexion au serveur';
    }
  }

  // ─────────────────────────────────────────────
  // GET PROFILE
  // GET /users/me
  // ─────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      print('📤 GET PROFILE REQUEST');

      final res = await ApiClient.get(
        Endpoints.me, // '/users/me'
      );

      print('📥 GET PROFILE RESPONSE:');
      print(res.data);

      if (!res.success || res.data == null) {
        print('❌ ERROR: ${res.error}');
        return null;
      }

      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      print('❌ EXCEPTION: $e');
      return null;
    }
  }
}