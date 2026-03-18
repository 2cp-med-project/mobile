import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class DemandesScreen extends StatefulWidget {
  const DemandesScreen({super.key});

  @override
  State<DemandesScreen> createState() => _DemandesScreenState();
}

class _DemandesScreenState extends State<DemandesScreen> {
  // Pending access requests
  final List<_AccessRequest> _pendingRequests = [
    _AccessRequest(
      name: 'Dr.Merazi',
      specialty: 'Cardiologue',
      hospital: 'EPH-SBA',
      time: 'Il y a 2 minutes',
    ),
  ];

  // Recent requests
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

  void _acceptRequest(int index) {
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
      const SnackBar(
        content: Text('Demande acceptée'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _refuseRequest(int index) {
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
      const SnackBar(
        content: Text('Demande refusée'),
        backgroundColor: AppColors.error,
        duration: Duration(seconds: 2),
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

// ─── Pending Request Tile ─────────────────────────────────────────────────────
class _PendingRequestTile extends StatelessWidget {
  final _AccessRequest request;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;

  const _PendingRequestTile({
    required this.request,
    required this.onAccept,
    required this.onRefuse,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 11, color: AppColors.primary),
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
          const SizedBox(height: 12),
          // Action buttons
          Row(
            children: [
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
              const SizedBox(width: 12),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusInfo.icon, size: 14, color: statusInfo.color),
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
  final String specialty;
  final String hospital;
  final String time;

  const _AccessRequest({
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.time,
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