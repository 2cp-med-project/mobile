import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StatsService {

  // ───────── RAPPORTS ─────────
  static Future<int> getRapportsCount() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('rapports_list');
    if (raw == null) return 0;
    return (jsonDecode(raw) as List).length;
  }

  // ───────── RDV DONE ONLY ─────────
  static Future<int> getCompletedRdvCount() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('rdv_list');
    if (raw == null) return 0;

    final list = List<Map<String, dynamic>>.from(jsonDecode(raw));
    return list.where((e) => e['status'] == 'done').length;
  }

  // ───────── DOCTORS ─────────
  static Future<int> getDoctorsCount() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('doctors_list');
    if (raw == null) return 0;
    return (jsonDecode(raw) as List).length;
  }
}