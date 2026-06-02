// config/api_endpoints.dart
// Every route from the Swagger doc — single source of truth
// Base: http://10.0.2.2:5000/api

class Endpoints {
  // ── Auth ──────────────────────────────────────────────────────────────────
  static const signin         = '/auth/signin';           // POST — register
  static const login          = '/auth/login';            // POST — login
  static const logout         = '/auth/logout';           // POST — logout (Bearer)
  static const refreshToken   = '/auth/refresh-token';    // POST
  static const requestOtp     = '/auth/request-otp';      // POST
  static const verifyOtp      = '/auth/verify-otp';       // POST
  static const changePassword = '/auth/change-password';  // POST

  // ── Notifications ─────────────────────────────────────────────────────────
  static const registerFcmToken    = '/notifications/register-fcmtoken';   // POST (Bearer)
  static const sendPatientResponse = '/notifications/patient-response';    // POST (Bearer)

  // ── Users ─────────────────────────────────────────────────────────────────
  static const me          = '/users/me';                   // GET / PATCH (Bearer)
  static String patient(String id) => '/users/patient/$id'; // GET (doctor)
  static String doctor(String id)  => '/users/doctor/$id';  // GET
  static const doctors     = '/users/doctors';              // GET paginated

  // ── Records (consultations = medical files) ───────────────────────────────
  // Note: using '/records' (plural) as in the incoming branch; adjust if backend expects '/record'
  static const consultation            = '/records/consultation';           // POST
  static String consultationById(String id) => '/records/consultation/$id'; // GET / PATCH
  static String recordsByPatient(String id) => '/records/$id';              // GET paginated

  // ── Access (doctor ↔ patient permissions) ────────────────────────────────
  static const accessRequest          = '/access/request';            // POST (doctor)
  static const accessPatientRequests  = '/access/patient/requests';   // GET  (patient)
  static String accessRespond(String id) => '/access/$id/respond';    // PUT  (patient)
  static const accessDoctorPatients   = '/access/doctor/patients';    // GET  (doctor)
  static const accessPatientDoctors   = '/access/patient/doctors';    // GET  (patient)
  static String accessDelete(String id) => '/access/$id';             // DELETE (patient) – from HEAD

  // ── Chatbot ───────────────────────────────────────────────────────────────
  static const chatbot = '/chatbot';                         // from HEAD
  static String chatbotById(String id) => '/chatbot/$id';    // from HEAD

  // ── Appointment ───────────────────────────────────────────────────────────
  static const myAppointments = '/appointment/my';   // GET
  static const addAppointment = '/appointment/add';  // POST

  // ── Review ────────────────────────────────────────────────────────────────
  static String addReview(String doctorId) => '/review/doctor/$doctorId/submit-review';
  static String getDoctorReviews(String doctorId) => '/review/doctor/$doctorId/get-reviews';
}