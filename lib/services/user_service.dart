// services/user_service.dart
// Maps to /api/users/* routes from Swagger

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_client.dart';
import '../config/api_endpoints.dart';
import '../config/storage_helper.dart';

class UserService {

  
  //  GET CURRENT USER   GET /api/users/me
  //  Returns full patient profile — syncs to local cache
  
  static Future<Map<String, dynamic>?> getMe() async {
    final res = await ApiClient.get(Endpoints.me);
    if (!res.success) return null;

    final user  = res.data as Map<String, dynamic>;
    final prefs = await SharedPreferences.getInstance();

    // Map API field names → our local keys
    final firstName = user['firstName'] as String? ?? '';
    final lastName  = user['lastName']  as String? ?? '';
    final phone     = user['phone']     as String? ?? '';
    final email     = user['email']     as String? ?? '';

    await StorageHelper.saveUser(
      nom:    lastName,
      prenom: firstName,
      phone:  phone,
      email:  email,
    );

    // Save patient ID
    final id = user['_id'] as String? ?? user['id'] as String? ?? '';
    if (id.isNotEmpty) await prefs.setString('patient_id', id);

    // Extra fields (adjust field names to match your actual API response)
    final extras = <String, String?>{
      'date_naissance':      user['dateOfBirth']?.toString(),
      'lieu_naissance':      user['placeOfBirth']?.toString(),
      'genre':               user['gender']?.toString(),
      'adresse':             user['address']?.toString(),
      'groupe_sanguin':      user['bloodType']?.toString(),
      'allergies':           user['allergies']?.toString(),
      'maladies_chroniques': user['chronicDiseases']?.toString(),
      'medicaments':         user['medications']?.toString(),
      'profile_image_url':   user['profileImage']?.toString() ??
                              user['avatar']?.toString(),
    };
    for (final e in extras.entries) {
      if (e.value != null && e.value!.isNotEmpty) {
        await prefs.setString(e.key, e.value!);
      }
    }

    // Emergency contacts if present
    final contacts = user['emergencyContacts'] ?? user['emergency_contacts'];
    if (contacts != null) {
      await prefs.setString('emergency_contacts', jsonEncode(contacts));
    }

    return user;
  }

  // ────────────────────────────────────────────────────────────────────────
  //  UPDATE CURRENT USER   PATCH /api/users/me
  //  Called from personal_info_screen.dart on save
  // ────────────────────────────────────────────────────────────────────────
  static Future<String?> updateMe(Map<String, dynamic> body) async {
    final res = await ApiClient.patch(Endpoints.me, body);
    if (!res.success) return res.error ?? 'Mise à jour échouée';
    // Re-sync local cache
    await getMe();
    return null;
  }

  // ────────────────────────────────────────────────────────────────────────
  //  Helper: build PATCH body from local controllers
  //  Maps our local field names → API field names
  // ────────────────────────────────────────────────────────────────────────
  static Map<String, dynamic> buildUpdateBody({
    required String nom,
    required String prenom,
    required String phone,
    required String email,
    required String dateNaissance,
    required String lieuNaissance,
    required String genre,
    required String adresse,
    required String groupeSanguin,
    required String allergies,
    required String maladiesChroniques,
    required String medicaments,
    required List<Map<String, String>> emergencyContacts,
  }) {
    return {
      'firstName':         prenom,
      'lastName':          nom,
      'phone':             phone,
      'email':             email,
      'dateOfBirth':       dateNaissance,
      'placeOfBirth':      lieuNaissance,
      'gender':            genre,
      'address':           adresse,
      'bloodType':         groupeSanguin,
      'allergies':         allergies,
      'chronicDiseases':   maladiesChroniques,
      'medications':       medicaments,
      'emergencyContacts': emergencyContacts,
    };
  }
}