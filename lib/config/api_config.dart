class ApiConfig {
  // CHANGE THIS TO YOUR BACKEND IP
  static const String baseUrl =
      'https://backend.healio.foo/api';

  // Endpoints
  static const consultation = '/records/consultation';

  static String consultationById(String id) =>
      '/records/consultation/$id';

  static String recordsByPatient(String id) =>
      '/records/$id';
}