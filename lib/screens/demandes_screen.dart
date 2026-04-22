// screens/demandes_screen.dart — INTEGRATED WITH BACKEND
// GET  /api/access/patient/requests  — load pending requests
// PUT  /api/access/{id}/respond      — accept or reject
// GET  /api/access/patient/doctors   — load approved doctors
// DELETE /api/access/{id}            — remove a doctor

import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/access_service.dart';

class DemandesScreen extends StatefulWidget {
  const DemandesScreen({super.key});
  @override
  State<DemandesScreen> createState() => _DemandesScreenState();
}

class _DemandesScreenState extends State<DemandesScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabCtrl;

  List<Map<String, dynamic>> _pending  = [];
  List<Map<String, dynamic>> _approved = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadAll();
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  Future<void> _loadAll() async {
    setState(() { _loading = true; _error = null; });

    // GET /api/access/patient/requests
    final pending  = await AccessService.getPendingRequests();
    // GET /api/access/patient/doctors
    final approved = await AccessService.getApprovedDoctors();

    setState(() {
      _pending  = pending;
      _approved = approved;
      _loading  = false;
    });
  }

  // PUT /api/access/{id}/respond
  Future<void> _respond(String id, bool accepted) async {
    final error = await AccessService.respondToRequest(id, accepted);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    await _loadAll();
  }

  // DELETE /api/access/{id}
  Future<void> _remove(String id) async {
    final error = await AccessService.removeDoctor(id);
    if (error != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    await _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FAF7),
        elevation: 0,
        title: const Text('Demandes',
            style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textGrey,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'En attente (${_pending.length})'),
            Tab(text: 'Approuvés (${_approved.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _PendingTab(
                    requests: _pending, onRespond: _respond),
                _ApprovedTab(
                    doctors: _approved, onRemove: _remove),
              ],
            ),
    );
  }
}

// ── Pending requests tab ─────────────────────────────────────────────────────
class _PendingTab extends StatelessWidget {
  final List<Map<String, dynamic>> requests;
  final Future<void> Function(String id, bool accepted) onRespond;

  const _PendingTab({required this.requests, required this.onRespond});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const Center(
          child: Text('Aucune demande en attente',
              style: TextStyle(color: AppColors.textGrey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (_, i) {
        final r      = requests[i];
        final id     = r['_id'] as String? ?? r['id'] as String? ?? '';
        final doctor = r['doctor'] as Map<String, dynamic>? ?? r;
        final name   = '${doctor['firstName'] ?? ''} ${doctor['lastName'] ?? ''}'.trim();
        final spec   = doctor['speciality'] as String? ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryLight,
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name.isEmpty ? 'Médecin' : 'Dr. $name',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  if (spec.isNotEmpty)
                    Text(spec,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textGrey)),
                ],
              ),
            ),
            // Reject
            GestureDetector(
              onTap: () => onRespond(id, false),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: AppColors.error, size: 18),
              ),
            ),
            const SizedBox(width: 8),
            // Accept
            GestureDetector(
              onTap: () => onRespond(id, true),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.primary, size: 18),
              ),
            ),
          ]),
        );
      },
    );
  }
}

// ── Approved doctors tab ─────────────────────────────────────────────────────
class _ApprovedTab extends StatelessWidget {
  final List<Map<String, dynamic>> doctors;
  final Future<void> Function(String id) onRemove;

  const _ApprovedTab({required this.doctors, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      return const Center(
          child: Text('Aucun médecin approuvé',
              style: TextStyle(color: AppColors.textGrey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: doctors.length,
      itemBuilder: (_, i) {
        final d      = doctors[i];
        final id     = d['_id'] as String? ?? d['id'] as String? ?? '';
        final doctor = d['doctor'] as Map<String, dynamic>? ?? d;
        final name   = '${doctor['firstName'] ?? ''} ${doctor['lastName'] ?? ''}'.trim();
        final spec   = doctor['speciality'] as String? ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryLight,
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name.isEmpty ? 'Médecin' : 'Dr. $name',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  if (spec.isNotEmpty)
                    Text(spec,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textGrey)),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Accès approuvé',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            // Remove doctor access
            GestureDetector(
              onTap: () => onRemove(id),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_remove_outlined,
                    color: AppColors.error, size: 18),
              ),
            ),
          ]),
        );
      },
    );
  }
}