// lib/services/review_service.dart
import '../config/api_client.dart';
import '../config/api_endpoints.dart';

class ReviewResult {
  final bool success;
  final String? error;
  ReviewResult({required this.success, this.error});
}

class ReviewService {
  static Future<ReviewResult> submitReview({
    required String doctorId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await ApiClient.post(
        Endpoints.addReview(doctorId),
        {'rating': rating, 'comment': comment},
        auth: true,
      );
      if (response.success) {
        return ReviewResult(success: true);
      } else {
        final message = response.error ?? response.data?['message'] ?? 'Erreur inconnue';
        // Ensure message is String
        return ReviewResult(success: false, error: message.toString());
      }
    } catch (e) {
      return ReviewResult(success: false, error: e.toString());
    }
  }
}