// lib/services/doctor_service.dart
import '../config/api_client.dart';
import '../config/api_endpoints.dart';

class DoctorService {
  static Future<List<DoctorData>> getAllDoctors() async {
  try {
    final response = await ApiClient.get(Endpoints.doctors);
    print('🔍 Status: ${response.statusCode}');
    print('🔍 Success: ${response.success}');
    print('🔍 Data: ${response.data}');
    print('🔍 Data type: ${response.data.runtimeType}');
    
    if (response.success && response.data != null) {
      if (response.data is List) {
        final List<dynamic> doctorsList = response.data as List<dynamic>;
        print('🔍 List length: ${doctorsList.length}');
        return doctorsList.map((json) {
          print('🔍 Mapping doctor: $json');
          return DoctorData.fromJson(json);
        }).toList();
      } else if (response.data is Map) {
        // Maybe the backend returns an object like { doctors: [...] }
        final doctorsData = response.data['doctors'] ?? response.data['data'];
        if (doctorsData is List) {
          print('🔍 Found doctors list inside map, length: ${doctorsData.length}');
          return doctorsData.map((json) => DoctorData.fromJson(json)).toList();
        }
      }
    }
    return [];
  } catch (e) {
    print('❌ Error loading doctors: $e');
    return [];
  }
}
}

class DoctorData {
  final String id;
  final String firstName;
  final String lastName;
  final String name;
  final String email;
  final String specialization;
  final String phone;
  final String address;
  final double averageRating;
  final int totalReviews;
  final List<String> patients;

  DoctorData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.email,
    required this.specialization,
    required this.phone,
    required this.address,
    required this.averageRating,
    required this.totalReviews,
    this.patients = const [],
  });

  // Getter to match widget expectations
  double get rating => averageRating;
  int get reviewCount => totalReviews;

  factory DoctorData.fromJson(Map<String, dynamic> json) {
    return DoctorData(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      name: '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      email: json['email'] ?? '',
      specialization: json['specialization'] ?? '',
      phone: json['phone'] ?? '',
      address: json['Address'] ?? '',
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      patients: (json['patients'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'specialization': specialization,
    'phone': phone,
    'Address': address,
    'averageRating': averageRating,
    'totalReviews': totalReviews,
    'patients': patients,
  };
}