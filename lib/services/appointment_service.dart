// services/appointment_service.dart
/*import '../config/api_client.dart';
import '../config/api_endpoints.dart';
import '../screens/appointments_screen.dart';*/

/*class AppointmentService {
  
  // GET /api/appointments/my - Fetch all appointments
  static Future<List<Appointment>> getMyAppointments() async {
    try {
      final response = await ApiClient.get(Endpoints.myAppointments);
      
      if (!response.success) {
        throw Exception(response.error ?? 'Erreur de chargement');
      }
      
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => Appointment.fromJson(json)).toList();
      
    } catch (e) {
      print('Error fetching appointments: $e');
      throw Exception('Impossible de charger les rendez-vous');
    }
  }

  // POST /api/appointments/add - Create new appointment
  static Future<Appointment> addAppointment({
    required String doctorName,
    required String type,
    required String time,
    required DateTime date,
    required String note,
    required bool remind,
  }) async {
    try {
      final requestBody = {
        'type': type,
        'date': date.toIso8601String(),
        'time': time,
        'location': doctorName,
        'appointmentnotes': note,
        'reminders': remind,  // Matches your backend schema
      };
      
      final response = await ApiClient.post(
        Endpoints.addAppointment,
        requestBody,
      );
      
      if (!response.success) {
        throw Exception(response.error ?? 'Erreur de création');
      }
      
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      return Appointment.fromJson(data);
      
    } catch (e) {
      print('Error creating appointment: $e');
      throw Exception('Impossible de créer le rendez-vous');
    }
  }
}*/
// services/appointment_service.dart
import '../config/api_client.dart';
import '../config/api_endpoints.dart';
import '../screens/appointments_screen.dart';

class AppointmentService {
  
  // GET /api/appointments/my - Fetch all appointments
  static Future<List<Appointment>> getMyAppointments() async {
    try {
      print('🔵 Attempting to fetch appointments from: ${Endpoints.myAppointments}');
      
      final response = await ApiClient.get(Endpoints.myAppointments);
      
      print('🔵 Response status code: ${response.statusCode}');
      print('🔵 Response success: ${response.success}');
      print('🔵 Response error: ${response.error}');
      print('🔵 Response data: ${response.data}');
      
      if (!response.success) {
        throw Exception(response.error ?? 'Erreur de chargement');
      }
      
      // If response.data is null or not a list
      if (response.data == null) {
        print('🔵 Response data is null, returning empty list');
        return [];
      }
      
      final List<dynamic> data = response.data as List<dynamic>;
      print('🔵 Found ${data.length} appointments');
      
      return data.map((json) => Appointment.fromJson(json)).toList();
      
    } catch (e) {
      print('❌ Error fetching appointments: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      throw Exception('Impossible de charger les rendez-vous');
    }
  }

  // POST /api/appointments/add - Create new appointment
  static Future<Appointment> addAppointment({
    required String doctername,
    required String type,
    required String time,
    required DateTime date,
    required String note,
    required bool remind,
  }) async {
    try {
      final requestBody = {
        'type': type,
         'date': date.toIso8601String().split('T')[0], // 👈 Extract just YYYY-MM-DD
  'time': time.replaceAll('h', ':'), 
        'doctername': doctername,
        'appointmentnotes': note,
        'reminders': remind,
      };
      
      print('🟢 Sending POST to: ${Endpoints.addAppointment}');
      print('🟢 Request body: $requestBody');
      
      final response = await ApiClient.post(
        Endpoints.addAppointment,
        requestBody,
      );
      
      print('🟢 Response status: ${response.statusCode}');
      print('🟢 Response success: ${response.success}');
      print('🟢 Response error: ${response.error}');
      print('🟢 Response data: ${response.data}');
      
      if (!response.success) {
        throw Exception(response.error ?? 'Erreur de création');
      }
      
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      return Appointment.fromJson(data);
      
    } catch (e) {
      print('❌ Error creating appointment: $e');
      throw Exception('Impossible de créer le rendez-vous');
    }
  }
}