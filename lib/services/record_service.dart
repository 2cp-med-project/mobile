import '../config/api_client.dart';
import '../config/storage_helper.dart';

class RecordService {
  static Future<List<Map<String, dynamic>>> getConsultations() async {
    try {
      final patientId = await StorageHelper.getUserId();

      print('📤 GET CONSULTATIONS');
      print('PATIENT ID: $patientId');

      if (patientId == null || patientId.isEmpty) {
        print('❌ PATIENT ID EMPTY');
        return [];
      }

      // Get consultations
      final res = await ApiClient.get('/records/$patientId');

      print('📥 CONSULTATIONS RESPONSE:');
      print(res.data);

      if (!res.success || res.data == null) {
        print('❌ ERROR: ${res.error}');
        return [];
      }

      final consultations =
          List<Map<String, dynamic>>.from(res.data);

      // Fetch doctor name for every consultation
      for (var consultation in consultations) {
        try {
          final doctorId =
              consultation['doctorId']?.toString();

          if (doctorId == null || doctorId.isEmpty) {
            consultation['doctorName'] = 'Médecin';
            continue;
          }

          print('📤 GET DOCTOR: $doctorId');

          final doctorRes =
              await ApiClient.get('/users/doctor/$doctorId');

          if (doctorRes.success &&
              doctorRes.data != null) {
            final doctor = doctorRes.data;

            final firstName =
                doctor['firstName']?.toString() ?? '';

            final lastName =
                doctor['lastName']?.toString() ?? '';

            consultation['doctorName'] =
                'Dr. $firstName $lastName';
          } else {
            consultation['doctorName'] = 'Médecin';
          }
        } catch (e) {
          print('❌ GET DOCTOR ERROR: $e');
          consultation['doctorName'] = 'Médecin';
        }
      }

//AI Summary 

      return consultations;
    } catch (e) {
      print('❌ GET CONSULTATIONS EXCEPTION: $e');
      return [];
    }
  }
}
