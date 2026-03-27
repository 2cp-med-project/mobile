import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

// ─── Background message handler (must be top-level function) ──────────────────
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.messageId}');
}

// ─── Notification Service ─────────────────────────────────────────────────────
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // ── Global navigator key — allows showing modal from anywhere in the app ──
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // ── Initialize ────────────────────────────────────────────────────────────
  static Future<void> init() async {
    // 1. Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Ask user permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Permission: ${settings.authorizationStatus}');

    // 3. Get FCM token → give to backend
    final token = await _messaging.getToken();
    debugPrint('✅ FCM Token: $token');
    // TODO: await ApiService.saveFcmToken(token);

    // 4. Token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 Token refreshed: $newToken');
      // TODO: await ApiService.saveFcmToken(newToken);
    });

    // 5. App OPEN → notification arrives
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('📩 Foreground: ${message.notification?.title}');
      _handleIncomingRequest(message);
    });

    // 6. App BACKGROUND → user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('📲 From background: ${message.notification?.title}');
      _handleIncomingRequest(message);
    });

    // 7. App TERMINATED → user taps notification
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      debugPrint('🚀 From terminated: ${initial.notification?.title}');
      _handleIncomingRequest(initial);
    }
  }

  // ── Parse notification data and show modal ────────────────────────────────
  static void _handleIncomingRequest(RemoteMessage message) {
    final data = message.data;

    final doctorName     = data['doctor_name']     ?? 'Médecin';
    final doctorFullName = data['doctor_full_name'] ?? 'Médecin';
    final specialty      = data['specialty']        ?? '';
    final hospital       = data['hospital']         ?? '';
    final date           = data['date']             ?? '';
    final time           = data['time']             ?? '';
    final isVerified     = data['is_verified']      == 'true';
    final requestId      = data['request_id']       ?? '';

    final context = navigatorKey.currentContext;
    if (context == null) return;

    _showAuthorizationModal(
      context,
      doctorName:     doctorName,
      doctorFullName: doctorFullName,
      specialty:      specialty,
      hospital:       hospital,
      date:           date,
      time:           time,
      isVerified:     isVerified,
      requestId:      requestId,
    );
  }

  // ── Show blur modal on top of any screen ──────────────────────────────────
  static void _showAuthorizationModal(
    BuildContext context, {
    required String doctorName,
    required String doctorFullName,
    required String specialty,
    required String hospital,
    required String date,
    required String time,
    required bool isVerified,
    required String requestId,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, animation, _, __) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: animation.value * 5,
                sigmaY: animation.value * 5,
              ),
              child: Container(
                color: Colors.black.withValues(alpha: animation.value * 0.4),
              ),
            ),
            FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Material(
                      color: Colors.transparent,
                      child: _NotificationModal(
                        doctorFullName: doctorFullName,
                        specialty:      specialty,
                        hospital:       hospital,
                        date:           date,
                        time:           time,
                        isVerified:     isVerified,
                        onAccept: () {
                          Navigator.pop(ctx);
                          // TODO: await DossierService.acceptRequest(requestId);
                          _showSnackbar(context,
                            '✅  Autorisation accordée',
                            const Color(0xFF1FAF87),
                          );
                        },
                        onRefuse: () {
                          Navigator.pop(ctx);
                          // TODO: await DossierService.refuseRequest(requestId);
                          _showSnackbar(context,
                            '❌  Demande refusée',
                            const Color(0xFFE53935),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static void _showSnackbar(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─── Modal Widget ─────────────────────────────────────────────────────────────
class _NotificationModal extends StatelessWidget {
  final String doctorFullName;
  final String specialty;
  final String hospital;
  final String date;
  final String time;
  final bool isVerified;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;

  const _NotificationModal({
    required this.doctorFullName,
    required this.specialty,
    required this.hospital,
    required this.date,
    required this.time,
    required this.isVerified,
    required this.onAccept,
    required this.onRefuse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Demander une autorisation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('De :  ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(doctorFullName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1FAF87).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Professionnel vérifié',
                          style: TextStyle(
                            color: Color(0xFF1FAF87),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text('$specialty - $hospital',
                      style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text('Date : $date',
                      style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 2),
                    Text(time,
                      style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 34,
                backgroundColor:
                    const Color(0xFF1FAF87).withValues(alpha: 0.15),
                child: const Icon(Icons.person,
                  color: Color(0xFF1FAF87), size: 34),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onRefuse,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFE53935).withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Text('Refuser',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onAccept,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1FAF87).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF1FAF87).withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Text('Accorder l\'autorisation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1FAF87),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── BACKEND TODO ─────────────────────────────────────────────────────────────
// - saveFcmToken(token)  → POST token to backend so they know your device
// - onAccept             → await DossierService.acceptRequest(requestId)
// - onRefuse             → await DossierService.refuseRequest(requestId)
// - Backend notification data payload must include:
//   {
//     "doctor_name":     "Dr.Merazi",
//     "doctor_full_name":"Dr.Merazi Jeo",
//     "specialty":       "Cardiologue",
//     "hospital":        "EPH SBA",
//     "date":            "19/03/2026",
//     "time":            "Il y a 2 minutes",
//     "is_verified":     "true",
//     "request_id":      "123"
//   }