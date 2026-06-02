import '../config/api_client.dart';
import '../config/api_endpoints.dart';
import '../config/storage_helper.dart';

class PatientService {
  // ─────────────────────────────────────────────
  // UPDATE PROFILE
  // PATCH /users/me
  // ─────────────────────────────────────────────
  static Future<String?> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      print(data);

      final res = await ApiClient.patch(
        Endpoints.me, // '/users/me'
        data,
      );

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


static Future<Map<String, dynamic>?> getProfile() async {
  try {
    print('📤 GET PROFILE REQUEST');

    final res = await ApiClient.get(
      Endpoints.me,
    );

    print(res.data);

    if (!res.success || res.data == null) {
      print('❌ ERROR: ${res.error}');
      return null;
    }

    final profile = Map<String, dynamic>.from(res.data);

    // SAVE PROFILE LOCALLY
    await StorageHelper.saveUser(
      nom: profile['lastName']?.toString() ?? '',
      prenom: profile['firstName']?.toString() ?? '',
      phone: profile['phone']?.toString() ?? '',
      email: profile['email']?.toString() ?? '',
      userId: profile['_id']?.toString() ?? '',
      patientId: profile['_id']?.toString() ?? '',
    );

  
    return profile;
  } catch (e) {
    print('❌ EXCEPTION: $e');
    return null;
  }
} }
