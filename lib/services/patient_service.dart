import '../config/api_client.dart';
import '../config/api_endpoints.dart';

class PatientService {

  // ── UPDATE PROFILE ─────────────────────────────
  static Future<String?> updateProfile(Map<String, dynamic> data) async {
    print("📤 UPDATE PROFILE REQUEST:");
    print(data);

    final res = await ApiClient.patch(
      Endpoints.me, // should be '/users/me'
      data,
    );

    print("📥 UPDATE PROFILE RESPONSE:");
    print(res.data);

    if (!res.success) {
      print("❌ ERROR: ${res.error}");
      return res.error ?? 'Erreur mise à jour profil';
    }

    return null;
  }

  // ── UPLOAD AVATAR (optional endpoint) ──────────
  static Future<String?> uploadAvatar(String path) async {
    print("📤 UPLOAD AVATAR: $path");

    final res = await ApiClient.uploadFile(
      '/users/upload-avatar', // ⚠️ make sure backend has this route
      path,
      'avatar',
    );

    print("📥 AVATAR RESPONSE:");
    print(res.data);

    if (!res.success) {
      print("❌ ERROR: ${res.error}");
      return res.error ?? 'Erreur upload image';
    }

    return null;
  }
}