// lib/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../screens/demandes_screen.dart';
import '../config/app_routes.dart';
import '../config/storage_helper.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // ─── Initialisation ───────────────────────────────────────────────────────
  static Future<void> init() async {
    // Handler pour le background (app fermée ou en arrière-plan)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Demander la permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    debugPrint('📱 Permission status: ${settings.authorizationStatus}');
    
    // Récupérer le token FCM
    final token = await _messaging.getToken();
    debugPrint('✅ FCM Token: $token');
    
    // Écouter le rafraîchissement du token
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 Token refreshed: $newToken');
      // TODO: Envoyer le nouveau token à ton backend
    });

    // ─── Gestion des messages ─────────────────────────────────────────────
    
    // 1. Message reçu quand l'app est au premier plan (foreground)
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('📩 Foreground message: ${message.notification?.title}');
      _showInAppNotification(message.notification?.title, message.notification?.body);
    });

    // 2. Message ouvert depuis le background (app en arrière-plan)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('📲 Opened from background: ${message.notification?.title}');
      _navigateToDemandesScreen();
    });

    // 3. Message ouvert quand l'app était complètement fermée (terminated)
    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('🚀 Opened from terminated: ${initialMessage.notification?.title}');
      _navigateToDemandesScreen();
    }
  }

  // ─── Navigation simple vers DemandesScreen ────────────────────────────────
  static void _navigateToDemandesScreen() async {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  final isLoggedIn = await StorageHelper.isLoggedIn();

  if (!isLoggedIn) {
    Navigator.pushNamed(
      context,
      AppRoutes.signIn,
      arguments: AppRoutes.request, // 👈 IMPORTANT
    );
    return;
  }

  Navigator.pushNamed(context, AppRoutes.request);
}
  // ─── Notification in-app (quand l'app est ouverte) ────────────────────────
  static void _showInAppNotification(String? title, String? body) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title ?? 'Nouvelle demande',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (body != null)
              Text(
                body,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        backgroundColor: const Color(0xFF1FAF87),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Voir',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DemandesScreen()),
            );
          },
        ),
      ),
    );
  }

  // ─── Méthode utilitaire pour obtenir le token ─────────────────────────────
  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  // ─── Méthode pour supprimer le token (déconnexion) ────────────────────────
  static Future<void> deleteToken() async {
    await _messaging.deleteToken();
    debugPrint('🗑️ FCM Token deleted');
  }
}

// ─── Background Handler (app fermée ou en arrière-plan) ─────────────────────
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🌙 Background message: ${message.messageId}');
  debugPrint('📦 Background data: ${message.data}');
}