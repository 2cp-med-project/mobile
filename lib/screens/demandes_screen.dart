import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class DemandesScreen extends StatefulWidget {
  const DemandesScreen({super.key});

  @override
  State<DemandesScreen> createState() => _DemandesScreenState();
}

class _DemandesScreenState extends State<DemandesScreen> {
  final List<_AccessRequest> _pendingRequests = [
    _AccessRequest(
      name: 'Dr.Merazi',
      fullName: 'Dr.Merazi Jeo',
      specialty: 'Cardiologue',
      hospital: 'EPH SBA',
      time: 'Il y a 2 minutes',
      date: '19/03/2026',
      isVerified: true,
    ),
  ];

  final List<_RecentRequest> _recentRequests = [
    _RecentRequest(
      name: 'Dr.Merazi',
      subtitle: 'Le médecin attends l\'accès',
      time: 'Il y a 2 minutes',
      status: _RequestStatus.enAttente,
    ),
    _RecentRequest(
      name: 'Dr.Belsoumati',
      subtitle: 'Le médecin a accès',
      time: 'Il y a 5 heures',
      status: _RequestStatus.acceptee,
    ),
    _RecentRequest(
      name: 'Dr.Allal',
      subtitle: 'Le médecin n\'a pas accès',
      time: 'Il y a 1 jour',
      status: _RequestStatus.refusee,
    ),
    _RecentRequest(
      name: 'Dr.Ama',
      subtitle: 'La requête a expiré',
      time: 'Il y a 3 jours',
      status: _RequestStatus.echec,
    ),
  ];

  // ── Show modal with blur ───────────────────────────────────────────────────
  void _showAuthorizationModal(_AccessRequest request) {
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
            // ── Blurred + dimmed background ──────────────────────────
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: animation.value * 5,
                sigmaY: animation.value * 5,
              ),
              child: Container(
                color: Colors.black.withValues(alpha: animation.value * 0.4),
              ),
            ),
            // ── Modal ────────────────────────────────────────────────
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
                      child: _AuthorizationModal(
                        request: request,
                        onAccept: () {
                          Navigator.pop(ctx);
                          final i = _pendingRequests.indexOf(request);
                          _acceptRequest(i);
                        },
                        onRefuse: () {
                          Navigator.pop(ctx);
                          final i = _pendingRequests.indexOf(request);
                          _refuseRequest(i);
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

  void _acceptRequest(int index) {
    if (index < 0 || index >= _pendingRequests.length) return;
    setState(() {
      final req = _pendingRequests.removeAt(index);
      _recentRequests.insert(
        0,
        _RecentRequest(
          name: req.name,
          subtitle: 'Le médecin a accès',
          time: 'À l\'instant',
          status: _RequestStatus.acceptee,
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '✅  Autorisation accordée',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _refuseRequest(int index) {
    if (index < 0 || index >= _pendingRequests.length) return;
    setState(() {
      final req = _pendingRequests.removeAt(index);
      _recentRequests.insert(
        0,
        _RecentRequest(
          name: req.name,
          subtitle: 'Le médecin n\'a pas accès',
          time: 'À l\'instant',
          status: _RequestStatus.refusee,
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '❌  Demande refusée',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FBF8),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
        ),
        title: const Text(
          'Demandes',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Demandes d'accès ──────────────────────────────────────
            if (_pendingRequests.isNotEmpty) ...[
              _sectionTitle('Demandes d\'accès'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: _pendingRequests.asMap().entries.map((entry) {
                    final i = entry.key;
                    final req = entry.value;
                    return _PendingRequestTile(
                      request: req,
                      onTap: () => _showAuthorizationModal(req),
                      onAccept: () => _acceptRequest(i),
                      onRefuse: () => _refuseRequest(i),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Demandes récentes ─────────────────────────────────────
            _sectionTitle('Demandes récentes'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: _recentRequests.asMap().entries.map((entry) {
                  final i = entry.key;
                  final req = entry.value;
                  return Column(
                    children: [
                      _RecentRequestTile(request: req),
                      if (i < _recentRequests.length - 1)
                        Divider(
                          height: 1,
                          color: Colors.grey.withValues(alpha: 0.1),
                          indent: 16,
                          endIndent: 16,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A2E),
      ),
    );
  }
}

// ─── Authorization Modal ──────────────────────────────────────────────────────
class _AuthorizationModal extends StatelessWidget {
  final _AccessRequest request;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;

  const _AuthorizationModal({
    required this.request,
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
          // ── Title ─────────────────────────────────────────────────
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

          // ── Doctor info row ────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'De :  ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          request.fullName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (request.isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Professionnel vérifié',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      '${request.specialty} - ${request.hospital}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date : ${request.date}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.time,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              // ── Avatar ──────────────────────────────────────────────
              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.primaryLight,
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 34,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Buttons ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onRefuse,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Text(
                      'Refuser',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.error,
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
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Text(
                      'Accorder l\'autorisation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primary,
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

// ─── Pending Request Tile ─────────────────────────────────────────────────────
class _PendingRequestTile extends StatelessWidget {
  final _AccessRequest request;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;

  const _PendingRequestTile({
    required this.request,
    required this.onTap,
    required this.onAccept,
    required this.onRefuse,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Tap only the doctor info row → opens modal ─────────────
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        request.specialty,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 11,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            request.hospital,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        request.time,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Buttons stay separate — don't trigger modal ────────────
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onRefuse,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.error),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Refuser',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
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
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Accepter',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primary,
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

// ─── Recent Request Tile ──────────────────────────────────────────────────────
class _RecentRequestTile extends StatelessWidget {
  final _RecentRequest request;
  const _RecentRequestTile({required this.request});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusInfo(request.status);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryLight,
            child: const Icon(Icons.person, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  request.subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                Text(
                  request.time,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 90,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusInfo.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(statusInfo.icon, size: 12, color: statusInfo.color),
                  const SizedBox(width: 4),
                  Text(
                    statusInfo.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusInfo.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StatusInfo _statusInfo(_RequestStatus status) {
    switch (status) {
      case _RequestStatus.enAttente:
        return _StatusInfo(
          label: 'En attente',
          color: Colors.grey.shade600,
          icon: Icons.access_time_rounded,
        );
      case _RequestStatus.acceptee:
        return _StatusInfo(
          label: 'Acceptée',
          color: AppColors.primary,
          icon: Icons.check_circle_outline_rounded,
        );
      case _RequestStatus.refusee:
        return _StatusInfo(
          label: 'Refusée',
          color: AppColors.error,
          icon: Icons.cancel_outlined,
        );
      case _RequestStatus.echec:
        return _StatusInfo(
          label: 'Échec',
          color: const Color(0xFFFF9800),
          icon: Icons.warning_amber_rounded,
        );
    }
  }
}

// ─── Data Models ──────────────────────────────────────────────────────────────
class _AccessRequest {
  final String name;
  final String fullName;
  final String specialty;
  final String hospital;
  final String time;
  final String date;
  final bool isVerified;

  const _AccessRequest({
    required this.name,
    required this.fullName,
    required this.specialty,
    required this.hospital,
    required this.time,
    required this.date,
    required this.isVerified,
  });
}

class _RecentRequest {
  final String name;
  final String subtitle;
  final String time;
  final _RequestStatus status;

  const _RecentRequest({
    required this.name,
    required this.subtitle,
    required this.time,
    required this.status,
  });
}

enum _RequestStatus { enAttente, acceptee, refusee, echec }

class _StatusInfo {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusInfo({
    required this.label,
    required this.color,
    required this.icon,
  });
}

// ─── BACKEND TODO ─────────────────────────────────────────────────────────────
// - _pendingRequests  → replace with DossierService.getPendingRequests()
// - _recentRequests   → replace with DossierService.getRecentRequests()
// - _acceptRequest()  → call DossierService.acceptRequest(requestId)
// - _refuseRequest()  → call DossierService.refuseRequest(requestId)
// - REAL-TIME MODAL   → Firebase FCM: when backend sends new doctor request,
//                       call _showAuthorizationModal() using global navigator key