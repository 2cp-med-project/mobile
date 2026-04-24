// screens/profile_screen.dart
// Profile main screen — reads from SharedPreferences keys set during sign-up
// BACKEND TODO: replace _loadUser() with GET /api/patient/profile

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_colors.dart';
import '../config/storage_helper.dart';
import '../widgets/background.dart';
import 'personal_info_screen.dart';
import 'security_screen.dart';
import 'sign_in_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _nom         = '';
  String _prenom      = '';
  String _patientId   = '';
  String? _imagePath;
  List<Map<String, String>> _emergencyContacts = [];

  // BACKEND TODO: load from API
  final int _rapports     = 4;
  final int _rdvEffectues = 2;
  final int _medecins     = 3;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    // Core — StorageHelper keys
    final nom    = await StorageHelper.getNom()    ?? '';
    final prenom = await StorageHelper.getPrenom() ?? '';

    // Step 4 key
    final patientId = prefs.getString('patient_id') ?? '';

    // Step 4 emergency contacts JSON
    final raw = prefs.getString('emergency_contacts');
    List<Map<String, String>> contacts = [];
    if (raw != null) {
      final list = List<Map<String, dynamic>>.from(jsonDecode(raw));
      contacts = list.map((e) => {
        'name':  e['name']  as String? ?? '',
        'phone': e['phone'] as String? ?? '',
      }).toList();
    }

    // Profile image — set from personal_info_screen
    final imagePath = prefs.getString('profile_image_path');

    setState(() {
      _nom               = nom;
      _prenom            = prenom;
      _patientId         = patientId;
      _emergencyContacts = contacts;
      _imagePath         = imagePath;
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Se déconnecter',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: AppColors.textDark)),
        content: const Text('Voulez-vous vraiment vous déconnecter ?',
            style: TextStyle(color: AppColors.textGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnecter',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await StorageHelper.clear();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.transparent,
    body: Stack(
      children: [
        // 🌍 FULL SCREEN BACKGROUND (your background.dart)
        const Positioned.fill(
          child: Background(),
        ),

        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                _buildStatsCard(),
                const SizedBox(height: 24),
                _buildEmergencySection(),
                const SizedBox(height: 24),
                _buildParametresSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
  return SizedBox(
    height: 280,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 24),

        // Avatar stays
        _avatar(),

        const SizedBox(height: 12),

        Text(
          '$_nom $_prenom'.trim().isEmpty
              ? 'Mon Profil'
              : '$_nom $_prenom',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),

        const SizedBox(height: 4),

        if (_patientId.isNotEmpty)
          Text(
            _patientId,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textGrey,
            ),
          ),
      ],
    ),
  );
}

  Widget _avatar() {
    return Container(
      width: 96, height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 3),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 16, spreadRadius: 2)
        ],
      ),
      child: ClipOval(
        child: _imagePath != null && File(_imagePath!).existsSync()
            ? Image.file(File(_imagePath!), fit: BoxFit.cover)
            : Container(
                color: AppColors.primaryLight,
                child: const Icon(Icons.person,
                    size: 48, color: AppColors.primary)),
      ),
    );
  }

  // ── Stats ─────────────────────────────────────────────────────────────────
  Widget _buildStatsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10, offset: const Offset(0, 3))
          ],
        ),
        child: Row(children: [
          _statCell(_rapports.toString(),     'Rapports'),
          _statDivider(),
          _statCell(_rdvEffectues.toString(), 'RDV effectué'),
          _statDivider(),
          _statCell(_medecins.toString(),     'Médecins'),
        ]),
      ),
    );
  }

  Widget _statCell(String value, String label) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
            const SizedBox(height: 3),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: AppColors.textGrey)),
          ]),
        ),
      );

  Widget _statDivider() =>
    Container(width: 1, height: 36, color: Colors.transparent);
    
  // ── Emergency contacts ────────────────────────────────────────────────────
  Widget _buildEmergencySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Text('🚨', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text('Contacts d\'urgence',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
          ]),
          const SizedBox(height: 12),
          if (_emergencyContacts.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12)),
              child: const Text('Aucun contact d\'urgence ajouté.',
                  style: TextStyle(color: AppColors.textGrey)),
            )
          else
            ..._emergencyContacts.map(_contactCard),
        ],
      ),
    );
  }

  Widget _contactCard(Map<String, String> contact) {
    final name    = contact['name']  ?? '';
    final phone   = contact['phone'] ?? '';
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((w) => w[0].toUpperCase()).take(2).join()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.error.withValues(alpha: 0.14),
          child: Text(initials,
              style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      fontSize: 14)),
              const SizedBox(height: 2),
              Text(phone,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textGrey)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle),
          child: const Icon(Icons.phone, color: AppColors.error, size: 18),
        ),
      ]),
    );
  }

  // ── Paramètres ────────────────────────────────────────────────────────────
  Widget _buildParametresSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Paramètres',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8, offset: const Offset(0, 2))
              ],
            ),
            child: Column(children: [
              _settingTile(
                icon: Icons.person_outline_rounded,
                label: 'Informations Personnelles',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PersonalInfoScreen()),
                  );
                  _loadUser(); // refresh name / avatar if changed
                },
              ),
              _settingDivider(),
              _settingTile(
                icon: Icons.lock_outline_rounded,
                label: 'Confidentialité et Sécurité',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SecurityScreen()),
                ),
              ),
              _settingDivider(),
              _settingTile(
                icon: Icons.logout_rounded,
                label: 'Se déconnecter',
                isDestructive: true,
                onTap: _logout,
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final textColor  = isDestructive ? AppColors.error : AppColors.textDark;
    final iconColor  = isDestructive ? AppColors.error : AppColors.primary;
    final iconBg     = isDestructive
        ? AppColors.error.withValues(alpha: 0.1)
        : AppColors.primaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor))),
          Icon(Icons.chevron_right_rounded, color: AppColors.border, size: 20),
        ]),
      ),
    );
  }

  Widget _settingDivider() => Divider(
      height: 1,
      indent: 54,
      endIndent: 16,
      color: const Color(0xFFF4FBF8));
}