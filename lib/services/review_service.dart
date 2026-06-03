// lib/services/review_service.dart
import '../config/api_client.dart';
import '../config/api_endpoints.dart';

// ============================================================
// 1. Result type
// ============================================================
class ReviewResult {
  final bool success;
  final String? error;
  final int? statusCode;

  ReviewResult({
    required this.success,
    this.error,
    this.statusCode,
  });
}

// ============================================================
// 2. Review model (matches backend response)
// ============================================================
class Review {
  final String id;
  final int rating;
  final String comment;
  final String patientId;
  final String? patientName;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.patientId,
    this.patientName,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? json['id'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      patientId: json['patientId'] ?? '',
      patientName: json['patientName'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'rating': rating,
    'comment': comment,
    'patientId': patientId,
    'patientName': patientName,
    'createdAt': createdAt.toIso8601String(),
  };
}

// ============================================================
// 3. Review service with full debugging
// ============================================================
class ReviewService {
  // Submit a review with four ratings
  static Future<ReviewResult> submitReview({
    required String doctorId,
    required int punctuality,
    required int communication,
    required int expertise,
    required int listening,
    required String comment,
  }) async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📤 SUBMIT REVIEW');
    print('   doctorId: "$doctorId"');
    print('   punctuality: $punctuality');
    print('   communication: $communication');
    print('   expertise: $expertise');
    print('   listening: $listening');
    print('   comment: "${comment.length > 50 ? comment.substring(0, 50) + "..." : comment}"');

    // Validation
    if ([punctuality, communication, expertise, listening].any((r) => r < 1 || r > 5)) {
      print('❌ Validation failed: ratings out of range (must be 1-5)');
      return ReviewResult(
        success: false,
        error: 'Chaque note doit être comprise entre 1 et 5.',
      );
    }
    if (comment.trim().isEmpty) {
      print('❌ Validation failed: comment empty');
      return ReviewResult(
        success: false,
        error: 'Veuillez écrire un commentaire.',
      );
    }

    // Build request body as expected by backend: { ratings: {...}, comment }
    final body = {
      'ratings': {
        'punctuality': punctuality,
        'communication': communication,
        'expertise': expertise,
        'listening': listening,
      },
      'comment': comment,
    };
    print('📦 Request body: ${body.toString()}');

    try {
      final endpoint = Endpoints.addReview(doctorId);
      print('🔗 Endpoint path: $endpoint');

      final response = await ApiClient.post(
        endpoint,
        body,
        auth: true,
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response success: ${response.success}');
      print('📡 Response data: ${response.data}');
      print('📡 Response error: ${response.error}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.success) {
        return ReviewResult(success: true);
      } else {
        final statusCode = response.statusCode;
        String errorMsg = response.error ??
            response.data?['message'] ??
            'Une erreur est survenue.';

        if (statusCode == 403) {
          errorMsg = "Vous ne pouvez pas noter ce médecin (pas d'accès actif).";
        }
        if (statusCode == 404) {
          errorMsg = "Endpoint introuvable (404). Vérifiez l'URL: $endpoint";
        }

        return ReviewResult(
          success: false,
          error: errorMsg,
          statusCode: statusCode,
        );
      }
    } catch (e) {
      print('❌ Exception in submitReview: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return ReviewResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  // Get all reviews for a doctor (with debugging)
  static Future<List<Review>> getDoctorReviews(String doctorId) async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📥 GET REVIEWS');
    print('   doctorId: "$doctorId"');

    try {
      final endpoint = Endpoints.getDoctorReviews(doctorId);
      print('🔗 GET endpoint: $endpoint');

      final response = await ApiClient.get(endpoint);

      print('📡 GET response status: ${response.statusCode}');
      print('📡 GET success: ${response.success}');

      if (response.success && response.data != null) {
        final List<dynamic> list = response.data['reviews'] ?? [];
        print('✅ Loaded ${list.length} reviews');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return list.map((json) => Review.fromJson(json)).toList();
      }
      print('⚠️ No reviews or error: ${response.error}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return [];
    } catch (e) {
      print('❌ Error fetching reviews: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      return [];
    }
  }
}