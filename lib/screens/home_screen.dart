import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'experiences_screen.dart';
import 'demandes_screen.dart';
import '../config/app_colors.dart';
import '../config/storage_helper.dart';
import 'chatbot_screen.dart';
import 'appointments_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _prenom = '';
  String _nom = '';
  String? _profileImagePath;
  Appointment? _nextAppointment;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final nom    = await StorageHelper.getNom();
    final prenom = await StorageHelper.getPrenom();

    Appointment? next;
    String? imagePath;
    try {
      final prefs = await SharedPreferences.getInstance();

      // Profile image — written by personal_info_screen
      imagePath = prefs.getString('profile_image_path');

      // Next appointment
      final raw = prefs.getString('appointments');
      if (raw != null) {
        final list  = List<Map<String, dynamic>>.from(jsonDecode(raw));
        final appts = list.map(Appointment.fromJson).toList();
        final now   = DateTime.now();
        final upcoming = appts
            .where((a) =>
                a.status != 'termine' &&
                a.date.isAfter(now.subtract(const Duration(hours: 1))))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
        if (upcoming.isNotEmpty) next = upcoming.first;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _nom              = nom    ?? '';
        _prenom           = prenom ?? '';
        _profileImagePath = imagePath;
        _nextAppointment  = next;
      });
    }
  }

  void _goToAppointments() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
    );
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FBF8),
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.20,
            left: 0,
            child: SvgPicture.asset(
              'assets/images/loginIcon.svg',
              width: MediaQuery.of(context).size.width * 0.24,
              height: MediaQuery.of(context).size.height * 0.20,
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.40,
            right: -55,
            child: SvgPicture.asset(
              'assets/images/loginIcon2.svg',
              width: MediaQuery.of(context).size.width * 0.35,
              height: MediaQuery.of(context).size.height * 0.25,
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeaderCard()),
                SliverToBoxAdapter(child: _buildQuickCards(context)),
                SliverToBoxAdapter(child: _buildSectionTitle('Prochains rendez-vous')),
                SliverToBoxAdapter(child: _buildRdvList()),
                SliverToBoxAdapter(child: _buildSectionTitle('Demandes récentes')),
                SliverToBoxAdapter(child: _buildDemandesRecentes(context)),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header Card ──────────────────────────────────────────────────────────────
  Widget _buildHeaderCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: _goToAppointments,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1FAF87), Color(0xFF17C99E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              // ── Avatar — top right, no decorative circles ───────────
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.7), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _profileImagePath != null &&
                            File(_profileImagePath!).existsSync()
                        ? Image.file(File(_profileImagePath!),
                            fit: BoxFit.cover)
                        : Container(
                            color: Colors.white.withValues(alpha: 0.25),
                            child: const Icon(Icons.person,
                                color: Colors.white, size: 30),
                          ),
                  ),
                ),
              ),

              // ── Main content — exactly as original ──────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_nom $_prenom ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Prochain rendez-vous',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 11),
                                ),
                                Text(
                                  _nextAppointmentLabel(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              color: Colors.white70, size: 13),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _nextAppointmentLabel() {
    if (_nextAppointment == null) return 'Aucun rendez-vous à venir';
    final appt = _nextAppointment!;
    final now  = DateTime.now();
    final diff = DateTime(appt.date.year, appt.date.month, appt.date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    String dayLabel;
    if (diff == 0) {
      dayLabel = "Aujourd'hui";
    } else if (diff == 1) {
      dayLabel = 'Demain';
    } else if (diff <= 6) {
      dayLabel = 'Dans $diff jours';
    } else {
      dayLabel = '${appt.date.day.toString().padLeft(2, '0')}/'
          '${appt.date.month.toString().padLeft(2, '0')}/'
          '${appt.date.year}';
    }
    return '${appt.doctorName} - $dayLabel, ${appt.time}';
  }

  // ── Quick Access Cards ───────────────────────────────────────────────────────
  Widget _buildQuickCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _QuickCard(
                  svgAsset: 'assets/icons/message.svg',
                  title: 'Demandes',
                  subtitle: '3 demandes',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const DemandesScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickCard(
                  svgAsset: 'assets/icons/file.svg',
                  title: 'Dossier Médical',
                  subtitle: '2 nouveaux rapports',
                  iconWidth: 18,
                  iconHeight: 20,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickCard(
                  svgAsset: 'assets/icons/ai.svg',
                  title: 'Assistant AI',
                  subtitle: 'Demandez n\'importe quoi',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ChatbotScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickCard(
                  svgAsset: 'assets/icons/star.svg',
                  title: 'Expériences des Patients',
                  subtitle: 'Notes et Avis',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ExperiencesScreen())),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(title,
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E))),
    );
  }

  Widget _buildRdvList() {
    final rdvs = [
      _RdvData(name: 'Dr.Merazi',        specialty: 'Cardiologie · Suivi',         time: '10h00', dateLabel: 'Demain',   dateColor: const Color(0xFF1FAF87)),
      _RdvData(name: 'Dr.Belsoumati',    specialty: 'Généraliste · Consultation',  time: '09h00', dateLabel: '08 Mars',  dateColor: const Color(0xFF7B61FF)),
      _RdvData(name: 'Laboratoire Allal',specialty: 'Analyse en laboratoire',      time: '08h30', dateLabel: '22 Mars',  dateColor: const Color(0xFF00C3D0)),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: rdvs.asMap().entries.map((entry) {
            final i = entry.key; final rdv = entry.value;
            return Column(children: [
              _RdvTile(rdv: rdv),
              if (i < rdvs.length - 1) Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1), indent: 16, endIndent: 16),
            ]);
          }).toList(),
        ),
      ),
    );
    // BACKEND TODO: replace with AppointmentService.getUpcoming()
  }

  Widget _buildDemandesRecentes(BuildContext context) {
    final demandes = [
      _DemandeData(name: 'Dr.Merazi',    subtitle: 'Le médecin attends l\'accès', time: 'Il y a 2 minutes', status: 'En attente', statusColor: const Color(0xFF888888), statusIcon: Icons.access_time_rounded),
      _DemandeData(name: 'Dr.Belsoumati',subtitle: 'Le médecin a accès',          time: 'Il y a 5 heures',  status: 'Acceptée',   statusColor: const Color(0xFF1FAF87), statusIcon: Icons.check_circle_outline_rounded),
      _DemandeData(name: 'Dr.Allal',     subtitle: 'Le médecin n\'a pas accès',   time: 'Il y a 1 jour',    status: 'Refusée',    statusColor: const Color(0xFFE53935), statusIcon: Icons.cancel_outlined),
      _DemandeData(name: 'Dr.Ama',       subtitle: 'La requête a expiré',         time: 'Il y a 3 jours',   status: 'Échec',      statusColor: const Color(0xFFFF9800), statusIcon: Icons.warning_amber_rounded),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: demandes.asMap().entries.map((entry) {
            final i = entry.key; final d = entry.value;
            return Column(children: [
              _DemandeTile(data: d),
              if (i < demandes.length - 1) Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1), indent: 16, endIndent: 16),
            ]);
          }).toList(),
        ),
      ),
    );
    // BACKEND TODO: replace with DossierService.getRecentRequests()
  }
}

// ─── Quick Card ───────────────────────────────────────────────────────────────
class _QuickCard extends StatelessWidget {
  final String svgAsset; final String title; final String subtitle;
  final VoidCallback onTap; final double iconWidth; final double iconHeight;
  const _QuickCard({required this.svgAsset, required this.title, required this.subtitle, required this.onTap, this.iconWidth = 22, this.iconHeight = 22});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
            child: SvgPicture.asset(svgAsset, width: iconWidth, height: iconHeight, fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ]),
      ),
    );
  }
}

// ─── Models ───────────────────────────────────────────────────────────────────
class _RdvData {
  final String name, specialty, time, dateLabel; final Color dateColor;
  const _RdvData({required this.name, required this.specialty, required this.time, required this.dateLabel, required this.dateColor});
}
class _DemandeData {
  final String name, subtitle, time, status; final Color statusColor; final IconData statusIcon;
  const _DemandeData({required this.name, required this.subtitle, required this.time, required this.status, required this.statusColor, required this.statusIcon});
}

// ─── RDV Tile ─────────────────────────────────────────────────────────────────
class _RdvTile extends StatelessWidget {
  final _RdvData rdv; const _RdvTile({required this.rdv});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        CircleAvatar(radius: 24, backgroundColor: AppColors.primaryLight,
            child: const Icon(Icons.person, color: AppColors.primary, size: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(rdv.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 2),
          Text(rdv.specialty, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(rdv.time, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: rdv.dateColor)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: rdv.dateColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(rdv.dateLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: rdv.dateColor)),
          ),
        ]),
      ]),
    );
  }
}

// ─── Demande Tile ─────────────────────────────────────────────────────────────
class _DemandeTile extends StatelessWidget {
  final _DemandeData data; const _DemandeTile({required this.data});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        CircleAvatar(radius: 22, backgroundColor: AppColors.primaryLight,
            child: const Icon(Icons.person, color: AppColors.primary, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(data.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A2E))),
          Text(data.subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          Text(data.time, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
        ])),
        SizedBox(width: 90, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: data.statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(data.statusIcon, size: 12, color: data.statusColor),
            const SizedBox(width: 4),
            Text(data.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: data.statusColor)),
          ]),
        )),
      ]),
    );
  }
}

// ─── BACKEND TODO ─────────────────────────────────────────────────────────────
// - _loadUser()              → GET /api/patient/profile (nom, prenom, avatar URL)
// - _nextAppointmentLabel()  → GET /api/appointments/next
// - _buildRdvList()          → AppointmentService.getUpcoming()
// - _buildDemandesRecentes() → DossierService.getRecentRequests()