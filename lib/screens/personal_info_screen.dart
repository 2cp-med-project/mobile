// screens/personal_info_screen.dart
// Editable personal info — reads from SharedPreferences keys written during sign-up
// Save writes back to the same keys so profile_screen always stays in sync
// BACKEND TODO: replace _save() body with PATCH /api/patient/profile

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_colors.dart';
import '../config/storage_helper.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  KEY REFERENCE  (single source of truth — matches sign_up_step*.dart)
// ─────────────────────────────────────────────────────────────────────────────
//  'nom'                 → StorageHelper  (step 1)
//  'prenom'              → StorageHelper  (step 1)
//  'date_naissance'      → step 2  "06 / 10 / 2000"
//  'lieu_naissance'      → step 2
//  'genre'               → step 2
//  'adresse'             → step 3  (full address string)
//  'phone'               → StorageHelper  (step 3)
//  'email'               → StorageHelper  (step 3)
//  'patient_id'          → step 4
//  'emergency_contacts'  → step 4  JSON: [{name, phone}, ...]
//  'profile_image_path'  → this screen  (gallery pick)
//  'groupe_sanguin'      → this screen  (not in sign-up)
//  'allergies'           → this screen
//  'maladies_chroniques' → this screen
//  'medicaments'         → this screen
// ─────────────────────────────────────────────────────────────────────────────

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _prenomCtrl     = TextEditingController();
  final _nomCtrl        = TextEditingController();
  final _dobCtrl        = TextEditingController();
  final _lieuCtrl       = TextEditingController();
  final _genreCtrl      = TextEditingController();
  final _bloodCtrl      = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _adresseCtrl    = TextEditingController();
  final _allergiesCtrl  = TextEditingController();
  final _chronicCtrl    = TextEditingController();
  final _medsCtrl       = TextEditingController();

  // Emergency contacts loaded dynamically from JSON stored in step 4
  List<Map<String, TextEditingController>> _ecControllers = [];

  String? _profileImagePath;
  bool _saving      = false;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    // StorageHelper keys
    _prenomCtrl.text = prefs.getString('prenom') ?? '';
    _nomCtrl.text    = prefs.getString('nom')    ?? '';
    _phoneCtrl.text  = prefs.getString('phone')  ?? '';
    _emailCtrl.text  = prefs.getString('email')  ?? '';

    // Step 2 keys
    _dobCtrl.text   = prefs.getString('date_naissance') ?? '';
    _lieuCtrl.text  = prefs.getString('lieu_naissance') ?? '';
    _genreCtrl.text = prefs.getString('genre')          ?? '';

    // Step 3 key
    _adresseCtrl.text = prefs.getString('adresse') ?? '';

    // Medical — only set from this screen
    _bloodCtrl.text    = prefs.getString('groupe_sanguin')       ?? '';
    _allergiesCtrl.text = prefs.getString('allergies')            ?? '';
    _chronicCtrl.text  = prefs.getString('maladies_chroniques')  ?? '';
    _medsCtrl.text     = prefs.getString('medicaments')          ?? '';

    // Step 4 emergency contacts JSON: [{name, phone}, ...]
    final raw = prefs.getString('emergency_contacts');
    if (raw != null) {
      final list = List<Map<String, dynamic>>.from(jsonDecode(raw));
      _ecControllers = list.map((e) => {
        'name':  TextEditingController(text: e['name']  as String? ?? ''),
        'phone': TextEditingController(text: e['phone'] as String? ?? ''),
      }).toList();
    }
    if (_ecControllers.isEmpty) {
      _ecControllers = [
        {'name': TextEditingController(), 'phone': TextEditingController()},
      ];
    }

    _profileImagePath = prefs.getString('profile_image_path');
    setState(() {});
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', picked.path);
    setState(() => _profileImagePath = picked.path);
  }

  // ── Date of birth picker ────────────────────────────────────────────────
  Future<void> _pickDOB() async {
    final now = DateTime.now();
    // Parse existing value if any (format: "06 / 10 / 2000")
    DateTime initial = DateTime(now.year - 25, 1, 1);
    try {
      final parts = _dobCtrl.text.split('/').map((s) => int.parse(s.trim())).toList();
      if (parts.length == 3) initial = DateTime(parts[2], parts[1], parts[0]);
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 1, 12, 31),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dobCtrl.text =
            '${picked.day.toString().padLeft(2, '0')} / '
            '${picked.month.toString().padLeft(2, '0')} / '
            '${picked.year}';
      });
    }
  }

  // ── Gender picker (bottom sheet) ────────────────────────────────────────
  void _pickGender() {
    final options = ['Homme', 'Femme'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text('Genre',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 14),
            ...options.map((opt) {
              final selected = _genreCtrl.text == opt;
              return GestureDetector(
                onTap: () {
                  setState(() => _genreCtrl.text = opt);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : const Color(0xFFF4FBF8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(children: [
                    Text(opt,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textDark)),
                    const Spacer(),
                    if (selected)
                      const Icon(Icons.check_circle,
                          color: AppColors.primary, size: 18),
                  ]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();

    await StorageHelper.saveUser(
      nom:    _nomCtrl.text.trim(),
      prenom: _prenomCtrl.text.trim(),
      phone:  _phoneCtrl.text.trim(),
      email:  _emailCtrl.text.trim(),
    );

    await Future.wait([
      prefs.setString('date_naissance',      _dobCtrl.text.trim()),
      prefs.setString('lieu_naissance',      _lieuCtrl.text.trim()),
      prefs.setString('genre',               _genreCtrl.text.trim()),
      prefs.setString('adresse',             _adresseCtrl.text.trim()),
      prefs.setString('groupe_sanguin',      _bloodCtrl.text.trim()),
      prefs.setString('allergies',           _allergiesCtrl.text.trim()),
      prefs.setString('maladies_chroniques', _chronicCtrl.text.trim()),
      prefs.setString('medicaments',         _medsCtrl.text.trim()),
    ]);

    final contacts = _ecControllers.map((e) => {
      'name':  e['name']!.text.trim(),
      'phone': e['phone']!.text.trim(),
    }).toList();
    await prefs.setString('emergency_contacts', jsonEncode(contacts));

    // BACKEND TODO:
    // final token = await StorageHelper.getToken();
    // await ApiClient.patch('/patient/profile', token: token, body: {
    //   'nom': _nomCtrl.text, 'prenom': _prenomCtrl.text,
    //   'phone': _phoneCtrl.text, 'email': _emailCtrl.text,
    //   'date_naissance': _dobCtrl.text, 'lieu_naissance': _lieuCtrl.text,
    //   'genre': _genreCtrl.text, 'adresse': _adresseCtrl.text,
    //   'groupe_sanguin': _bloodCtrl.text, 'allergies': _allergiesCtrl.text,
    //   'maladies_chroniques': _chronicCtrl.text, 'medicaments': _medsCtrl.text,
    //   'emergency_contacts': contacts,
    // });

    setState(() { _saving = false; _showSuccess = true; });
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _showSuccess = false);
  }

  @override
  void dispose() {
    for (final c in [
      _prenomCtrl, _nomCtrl, _dobCtrl, _lieuCtrl, _genreCtrl, _bloodCtrl,
      _emailCtrl, _phoneCtrl, _adresseCtrl, _allergiesCtrl, _chronicCtrl,
      _medsCtrl,
    ]) c.dispose();
    for (final ec in _ecControllers) {
      ec['name']!.dispose();
      ec['phone']!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF8),
      appBar: _appBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _avatarPicker(),
                const SizedBox(height: 28),

                _section(Icons.person_outline_rounded, 'Identité'),
                _row2(_field('PRÉNOM', _prenomCtrl),
                      _field('NOM', _nomCtrl)),
                // DATE — taps to open native DatePicker
                _tappableField(
                  label: 'DATE DE NAISSANCE',
                  controller: _dobCtrl,
                  hint: 'JJ / MM / AAAA',
                  icon: Icons.calendar_today_outlined,
                  onTap: _pickDOB,
                ),
                _field('LIEU DE NAISSANCE', _lieuCtrl,
                    prefix: Icons.location_city_outlined),
                _row2(
                  // GENRE — taps to open bottom sheet picker
                  _tappableField(
                    label: 'GENRE',
                    controller: _genreCtrl,
                    hint: 'Sélectionner',
                    icon: Icons.person_outline,
                    onTap: _pickGender,
                  ),
                  _field('GROUPE SANGUIN', _bloodCtrl),
                ),

                _section(Icons.phone_outlined, 'Contact'),
                _field('ADRESSE EMAIL', _emailCtrl,
                    prefix: Icons.email_outlined),
                _field('NUMÉRO DE TÉLÉPHONE', _phoneCtrl,
                    prefix: Icons.phone_outlined),
                _field('ADRESSE', _adresseCtrl,
                    prefix: Icons.home_outlined),

                _section(Icons.emergency_outlined, 'Contacts d\'urgence'),
                ..._ecControllers.asMap().entries.map((entry) {
                  final i  = entry.key;
                  final ec = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact label + remove button (if more than 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4, top: 4),
                        child: Row(
                          children: [
                            Text('Contact ${i + 1}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textGrey)),
                            const Spacer(),
                            if (_ecControllers.length > 1)
                              GestureDetector(
                                onTap: () => setState(() {
                                  ec['name']!.dispose();
                                  ec['phone']!.dispose();
                                  _ecControllers.removeAt(i);
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.error
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.remove_circle_outline,
                                          color: AppColors.error, size: 12),
                                      SizedBox(width: 3),
                                      Text('Supprimer',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: AppColors.error,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      _row2(_field('NOM', ec['name']!),
                            _field('TÉLÉPHONE', ec['phone']!)),
                    ],
                  );
                }),

                // Add contact button (max 4)
                if (_ecControllers.length < 4)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _ecControllers.add({
                          'name':  TextEditingController(),
                          'phone': TextEditingController(),
                        });
                      }),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.primary.withValues(alpha: 0.04),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline,
                                color: AppColors.primary, size: 18),
                            SizedBox(width: 8),
                            Text('Ajouter un contact d\'urgence',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),

                _section(Icons.monitor_heart_outlined,
                    'Informations médicales'),
                _field('ALLERGIES', _allergiesCtrl),
                _field('MALADIES CHRONIQUES', _chronicCtrl),
                _field('MÉDICAMENTS ACTUELS', _medsCtrl),
              ],
            ),
          ),

          // ── Success toast ──────────────────────────────────────────────
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            bottom: _showSuccess ? 100 : -80,
            left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('✅', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  Text('Vos informations ont été mises à jour !',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ],
              ),
            ),
          ),

          // ── Save button ────────────────────────────────────────────────
          Positioned(
            bottom: 20, left: 20, right: 20,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              icon: _saving
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save_alt_rounded,
                      color: Colors.white, size: 20),
              label: Text(
                _saving
                    ? 'Enregistrement...'
                    : 'Enregistrer les Modifications',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar() => AppBar(
        backgroundColor: const Color(0xFFF4FBF8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Informations Personnelles',
                style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 17)),
            Text('Modifier les détails de votre profil',
                style: TextStyle(color: AppColors.primary, fontSize: 11)),
          ],
        ),
      );

  Widget _avatarPicker() => GestureDetector(
        onTap: _pickImage,
        child: Column(
          children: [
            Stack(children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 14, spreadRadius: 2)
                  ],
                ),
                child: ClipOval(
                  child: _profileImagePath != null &&
                          File(_profileImagePath!).existsSync()
                      ? Image.file(File(_profileImagePath!),
                          fit: BoxFit.cover)
                      : Container(
                          color: AppColors.primaryLight,
                          child: const Icon(Icons.person,
                              size: 50, color: AppColors.primary)),
                ),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 15),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            const Text('Appuyez pour changer de photo',
                style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
          ],
        ),
      );

  Widget _section(IconData icon, String title) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 12),
        child: Row(children: [
          Icon(icon, color: AppColors.primary, size: 17),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(width: 10),
          Expanded(
              child: Divider(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  thickness: 1)),
        ]),
      );

  Widget _field(String label, TextEditingController ctrl,
          {IconData? prefix}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey,
                    letterSpacing: 0.4)),
            const SizedBox(height: 5),
            _GreenFocusField(controller: ctrl, prefixIcon: prefix),
          ],
        ),
      );

  Widget _row2(Widget a, Widget b) =>
      Row(children: [Expanded(child: a), const SizedBox(width: 10), Expanded(child: b)]);

  // Tappable read-only field (calendar / picker)
  Widget _tappableField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey,
                    letterSpacing: 0.4)),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: onTap,
              child: AbsorbPointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: hint,
                      hintStyle: const TextStyle(
                          color: AppColors.textGrey, fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 13),
                      border: InputBorder.none,
                      prefixIcon:
                          Icon(icon, color: AppColors.textGrey, size: 16),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 36, minHeight: 0),
                      suffixIcon: const Icon(Icons.arrow_drop_down,
                          color: AppColors.border, size: 20),
                      suffixIconConstraints:
                          const BoxConstraints(minWidth: 36, minHeight: 0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
class _GreenFocusField extends StatefulWidget {
  final TextEditingController controller;
  final IconData? prefixIcon;
  const _GreenFocusField({required this.controller, this.prefixIcon});

  @override
  State<_GreenFocusField> createState() => _GreenFocusFieldState();
}

class _GreenFocusFieldState extends State<_GreenFocusField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _focused
              ? AppColors.primary.withValues(alpha: 0.07)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _focused
                ? AppColors.primary
                : AppColors.border.withValues(alpha: 0.5),
            width: _focused ? 1.5 : 1.0,
          ),
        ),
        child: TextField(
          controller: widget.controller,
          style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: InputBorder.none,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon,
                    color: AppColors.textGrey, size: 16)
                : null,
            prefixIconConstraints:
                const BoxConstraints(minWidth: 36, minHeight: 0),
            suffixIcon: const Icon(Icons.edit_outlined,
                color: AppColors.border, size: 15),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 36, minHeight: 0),
          ),
        ),
      ),
    );
  }
}