// lib/screens/demandes_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/access_service.dart';

class DemandesScreen extends StatefulWidget {
  const DemandesScreen({super.key});

  @override
  State<DemandesScreen> createState() => _DemandesScreenState();
}

class _DemandesScreenState extends State<DemandesScreen> {
  List<_AccessRequest> _pendingRequests = [];
  List<_RecentRequest> _recentRequests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
    // Optional: load recent requests from SharedPreferences
    // _loadRecentRequestsFromPrefs();
  }

  // ----------------------------------------------------------------------
  //  API CALLS
  // ----------------------------------------------------------------------
  Future<void> _loadPendingRequests() async {
    setState(() => _isLoading = true);
    try {
      final List<Map<String, dynamic>> data = await AccessService.getPendingRequests();
      final mapped = data.map((item) => _AccessRequest(
        id: item['id'].toString(),
        name: item['doctorName'] ?? 'Dr. Inconnu',
        fullName: item['doctorFullName'] ?? 'Dr. Inconnu',
        specialty: item['specialty'] ?? '',
        hospital: item['hospital'] ?? '',
        time: _formatRelativeTime(item['createdAt']),
        date: _formatDate(item['createdAt']),
        isVerified: item['isVerified'] ?? false,
      )).toList();
      setState(() {
        _pendingRequests = mapped;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Erreur de chargement', isError: true);
    }
  }

  Future<void> _acceptRequest(int index) async {
    if (index < 0 || index >= _pendingRequests.length) return;
    final request = _pendingRequests[index];

    setState(() => _isLoading = true);

    final error = await AccessService.respondToRequest(request.id, true);
    if (error != null) {
      setState(() => _isLoading = false);
      _showSnackBar(error, isError: true);
      return;
    }

    setState(() {
      _pendingRequests.removeAt(index);
      _recentRequests.insert(
        0,
        _RecentRequest(
          name: request.name,
          subtitle: 'Le médecin a accès',
          time: 'À l\'instant',
          status: _RequestStatus.acceptee,
        ),
      );
      _isLoading = false;
    });
    _showSnackBar('✅ Autorisation accordée');
    // Optional: save recent requests to SharedPreferences
    // _saveRecentRequestsToPrefs();
  }

  Future<void> _refuseRequest(int index) async {
    if (index < 0 || index >= _pendingRequests.length) return;
    final request = _pendingRequests[index];

    setState(() => _isLoading = true);

    final error = await AccessService.respondToRequest(request.id, false);
    if (error != null) {
      setState(() => _isLoading = false);
      _showSnackBar(error, isError: true);
      return;
    }

    setState(() {
      _pendingRequests.removeAt(index);
      _recentRequests.insert(
        0,
        _RecentRequest(
          name: request.name,
          subtitle: 'Le médecin n\'a pas accès',
          time: 'À l\'instant',
          status: _RequestStatus.refusee,
        ),
      );
      _isLoading = false;
    });
    _showSnackBar('❌ Demande refusée', isError: true);
    // Optional: save recent requests to SharedPreferences
    // _saveRecentRequestsToPrefs();
  }

  // ----------------------------------------------------------------------
  //  HELPERS
  // ----------------------------------------------------------------------
  String _formatRelativeTime(String? isoString) {
    if (isoString == null) return 'Récemment';
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final diff = now.difference(dateTime);
      if (diff.inDays > 0) return 'Il y a ${diff.inDays} jour(s)';
      if (diff.inHours > 0) return 'Il y a ${diff.inHours} heure(s)';
      if (diff.inMinutes > 0) return 'Il y a ${diff.inMinutes} minute(s)';
      return 'À l\'instant';
    } catch (_) {
      return 'Récemment';
    }
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    try {
      final date = DateTime.parse(isoString);
      return '${date.day.toString().padLeft(2, '0')}/'
             '${date.month.toString().padLeft(2, '0')}/'
             '${date.year}';
    } catch (_) {
      return '';
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ----------------------------------------------------------------------
  //  MODAL & UI BUILDERS
  // ----------------------------------------------------------------------
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
                  CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Material(
                      color: Colors.transparent,
                      child: _AuthorizationModal(
                        request: request,
                        onAccept: () async {
                          Navigator.pop(ctx);
                          final i = _pendingRequests.indexOf(request);
                          await _acceptRequest(i);
                        },
                        onRefuse: () async {
                          Navigator.pop(ctx);
                          final i = _pendingRequests.indexOf(request);
                          await _refuseRequest(i);
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

  // ----------------------------------------------------------------------
  //  BUILD
  // ----------------------------------------------------------------------
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
            if (_pendingRequests.isNotEmpty) ...[
              _sectionTitle('Demandes d\'accès'),
              const SizedBox(height: 12),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
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
}

// ----------------------------------------------------------------------
//  MODAL WIDGET
// ----------------------------------------------------------------------
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
                        Text(
                          'De :  ',
                          style: TextStyle(color: Colors.grey.shade500),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date : ${request.date}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.time,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.primaryLight,
                child: const Icon(Icons.person, color: AppColors.primary, size: 34),
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
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
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
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
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

// ----------------------------------------------------------------------
//  PENDING REQUEST TILE
// ----------------------------------------------------------------------
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
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(Icons.person, color: AppColors.primary, size: 26),
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
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 11, color: AppColors.primary),
                          const SizedBox(width: 2),
                          Text(
                            request.hospital,
                            style: const TextStyle(fontSize: 11, color: AppColors.primary),
                          ),
                        ],
                      ),
                      Text(
                        request.time,
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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

// ----------------------------------------------------------------------
//  RECENT REQUEST TILE
// ----------------------------------------------------------------------
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

// ----------------------------------------------------------------------
//  DATA MODELS
// ----------------------------------------------------------------------
class _AccessRequest {
  final String id;
  final String name;
  final String fullName;
  final String specialty;
  final String hospital;
  final String time;
  final String date;
  final bool isVerified;

  const _AccessRequest({
    required this.id,
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
  const _StatusInfo({required this.label, required this.color, required this.icon});
}