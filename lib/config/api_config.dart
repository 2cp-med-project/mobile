class ApiConfig {
  // CHANGE THIS TO YOUR BACKEND IP
  static const String baseUrl =
      'http://10.58.114.26:5000/api';

  // Endpoints
  static const consultation = '/records/consultation';

  static String consultationById(String id) =>
      '/records/consultation/$id';

  static String recordsByPatient(String id) =>
      '/records/$id';
}