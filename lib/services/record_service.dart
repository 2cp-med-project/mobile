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

      final res = await ApiClient.get(
        '/records/$patientId',
      );

      print('📥 CONSULTATIONS RESPONSE:');
      print(res.data);

      if (!res.success || res.data == null) {
        print('❌ ERROR: ${res.error}');
        return [];
      }

      return List<Map<String, dynamic>>.from(res.data);
    } catch (e) {
      print('❌ GET CONSULTATIONS EXCEPTION: $e');
      return [];
    }
  }
}