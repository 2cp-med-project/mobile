import '../config/api_client.dart';

class SummaryService {
  static Future<String?> generateSummary(
    String consultationId,
  ) async {
    try {
      print('📤 GENERATE SUMMARY: $consultationId');

      final res = await ApiClient.post(
        '/summary/$consultationId',
        {},
      );

      print('📥 SUMMARY RESPONSE');
      print(res.data);

      if (!res.success || res.data == null) {
        return null;
      }

      return res.data['resume']?.toString();
    } catch (e) {
      print('❌ SUMMARY ERROR: $e');
      return null;
    }
  }
}