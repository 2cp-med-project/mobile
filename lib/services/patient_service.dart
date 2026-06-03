import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_client.dart';
import '../config/api_endpoints.dart';
import '../config/storage_helper.dart';

class PatientService {
  // UPDATE PROFILE
  // PATCH /users/me
  static Future<String?> updateProfile(Map<String, dynamic> data) async {
    try {
      print('📤 UPDATE PROFILE');
      print(data);

      final res = await ApiClient.patch(Endpoints.me, data);

      print('UPDATE RESPONSE: ${res.data}');

      if (!res.success) {
        print('❌ ERROR: ${res.error}');
        return res.error ?? 'Erreur mise à jour profil';
      }

      // Refresh local profile after update
      await getProfile();

      return null;
    } catch (e) {
      print('❌ EXCEPTION: $e');
      return 'Erreur de connexion au serveur';
    }
  }

  // GET PROFILE
  // GET /users/me

  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      print('📤 GET PROFILE REQUEST');

      final res = await ApiClient.get(Endpoints.me);

      print('PROFILE RESPONSE: ${res.data}');

      if (!res.success || res.data == null) {
        print('❌ ERROR: ${res.error}');
        return null;
      }

      final profile = Map<String, dynamic>.from(res.data);

      // ---------------- DATE FIX ----------------
      String dob = profile['dateOfBirth']?.toString() ?? '';

      // remove T00:00:00.000Z
      if (dob.contains('T')) {
        dob = dob.split('T').first;
      }

      // yyyy-MM-dd -> dd/MM/yyyy
      if (dob.contains('-')) {
        final parts = dob.split('-');
        if (parts.length == 3) {
          dob = '${parts[2]}/${parts[1]}/${parts[0]}';
        }
      }

      // ---------------- BLOOD TYPE FIX ----------------
      final medicalResume = profile['medicalResume']?.toString() ?? '';

      String bloodType = '';

      final regex = RegExp(
        r'Groupe sanguin:\s*([^\n\r]+)',
        caseSensitive: false,
      );

      final match = regex.firstMatch(medicalResume);

      if (match != null) {
        bloodType = (match.group(1) ?? '').trim();
      }

      // ---------------- SAVE USER ----------------
      await StorageHelper.saveUser(
        nom: profile['lastName']?.toString() ?? '',
        prenom: profile['firstName']?.toString() ?? '',
        phone:
            profile['phone']?.toString() ??
            profile['phoneNumber']?.toString() ??
            '',
        email: profile['email']?.toString() ?? '',
        userId: profile['_id']?.toString() ?? '',
        patientId: profile['_id']?.toString() ?? '',
      );

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('date_naissance', dob);

      await prefs.setString(
        'lieu_naissance',
        profile['placeOfBirth']?.toString() ?? '',
      );

      await prefs.setString('adresse', profile['address']?.toString() ?? '');

      await prefs.setString('groupe_sanguin', bloodType);

      await prefs.setString(
        'profile_image_url',
        profile['profileImage']?.toString() ?? '',
      );

      print('✅ PROFILE SAVED');
      print('NAME: ${profile['firstName']} ${profile['lastName']}');
      print('PHONE: ${profile['phone']}');
      print('BLOOD TYPE: $bloodType');
      print('DATE: $dob');

      return profile;
    } catch (e) {
      print('❌ EXCEPTION: $e');
      return null;
    }
  }
}
