import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    // ── Ask user permission ──
    await _messaging.requestPermission();

    // ── Get FCM token → send to your backend ──
    final token = await _messaging.getToken();
    print('FCM Token: $token'); // ← give this to your backend friend
    // TODO: await ApiService.saveFcmToken(token);

    // ── Listen to notifications when app is open ──
    FirebaseMessaging.onMessage.listen((message) {
      // show the authorization modal here
    });
  }
}