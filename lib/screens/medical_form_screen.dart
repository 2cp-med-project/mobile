// screens/medical_form_screen.dart — BACKEND INTEGRATED
// Changes (UI untouched):
//   • _onSubmit() saves to SharedPreferences AND backend
//   • Allergies + maladies: optional (no validation)
//   • Groupe sanguin + opéré/médicaments answers: required before submit
//   • After submit → marks 'medical_form_completed' = true → WelcomeScreen

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_colors.dart';
import '../config/api_client.dart';
import '../config/api_endpoints.dart';
import 'welcome_screen.dart';

class MedicalFormScreen extends StatefulWidget {
  const MedicalFormScreen({super.key});

  @override
  State<MedicalFormScreen> createState() => _MedicalFormScreenState();
}

class _MedicalFormScreenState extends State<MedicalFormScreen> {
  // ── Groupe sanguin ────────────────────────────────────────────────────
  String? _selectedBloodType;
  final _bloodTypes = ['A⁺', 'A⁻', 'B⁺', 'B⁻', 'O⁺', 'O⁻', 'AB⁺', 'AB⁻'];

  // ── Allergies (optional) ──────────────────────────────────────────────
  final _allergies = ['Médicaments', 'Aliments', 'Pollen / Animaux', 'Autre'];
  final _selectedAllergies = <String>{};
  final _allergieAutreController = TextEditingController();

  // ── Maladies chroniques (optional) ───────────────────────────────────
  final _maladies = [
    'Diabète', 'Hypertension', 'Asthme',
    'Maladies cardiaques', 'Autre',
  ];
  final _selectedMaladies = <String>{};
  final _maladieAutreController = TextEditingController();

  // ── Antécédents chirurgicaux (required) ───────────────────────────────
  bool? _aEteOpere;
  final _operationController = TextEditingController();

  // ── Médicaments (required) ────────────────────────────────────────────
  bool? _prendMedicaments;
  final _medicamentsController = TextEditingController();

  bool _loading = false;
  String? _submitError;

  @override
  void dispose() {
    _allergieAutreController.dispose();
    _maladieAutreController.dispose();
    _operationController.dispose();
    _medicamentsController.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────
  String? _validate() {
    if (_selectedBloodType == null) {
      return 'Veuillez sélectionner votre groupe sanguin.';
    }
    if (_aEteOpere == null) {
      return 'Veuillez répondre à la question sur les antécédents chirurgicaux.';
    }
    if (_aEteOpere == true && _operationController.text.trim().isEmpty) {
      return 'Veuillez décrire vos opérations.';
    }
    if (_prendMedicaments == null) {
      return 'Veuillez répondre à la question sur les médicaments.';
    }
    if (_prendMedicaments == true && _medicamentsController.text.trim().isEmpty) {
      return 'Veuillez lister vos médicaments actuels.';
    }
    return null;
  }

  // ── Build full allergies string ───────────────────────────────────────
  String _allergiesText() {
    final list = _selectedAllergies.toList();
    if (list.contains('Autre') && _allergieAutreController.text.trim().isNotEmpty) {
      list.remove('Autre');
      list.add(_allergieAutreController.text.trim());
    } else {
      list.remove('Autre');
    }
    if (list.isEmpty) return 'Aucune';
    return list.join(', ');
  }

  // ── Build maladies string ─────────────────────────────────────────────
  String _maladiesText() {
    final list = _selectedMaladies.toList();
    if (list.contains('Autre') && _maladieAutreController.text.trim().isNotEmpty) {
      list.remove('Autre');
      list.add(_maladieAutreController.text.trim());
    } else {
      list.remove('Autre');
    }
    if (list.isEmpty) return 'Aucune';
    return list.join(', ');
  }

  // ── Submit ────────────────────────────────────────────────────────────
  Future<void> _onSubmit() async {
    final error = _validate();
    if (error != null) {
      setState(() => _submitError = error);
      return;
    }
    setState(() { _loading = true; _submitError = null; });

    final allergiesText   = _allergiesText();
    final maladiesText    = _maladiesText();
    final medicamentsText = _prendMedicaments == true
        ? _medicamentsController.text.trim()
        : 'Aucun';
    final operationsText  = _aEteOpere == true
        ? _operationController.text.trim()
        : 'Aucun';

    // ── 1. Save locally (SharedPreferences) ───────────────────────
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('groupe_sanguin',      _selectedBloodType ?? '');
    await prefs.setString('allergies',           allergiesText);
    await prefs.setString('maladies_chroniques', maladiesText);
    await prefs.setString('antecedents_chir',    operationsText);
    await prefs.setString('medicaments',         medicamentsText);
    await prefs.setBool('medical_form_completed', true);

    // ── 2. Send to backend ─────────────────────────────────────────
    // BACKEND TODO: confirm exact field names with your backend team
    // Endpoint: PATCH /users/me  (or your patient profile update route)
    final body = {
      'bloodType':              _selectedBloodType,
      'allergies':              allergiesText,
      'chronicDiseases':        maladiesText,
      'surgicalHistory':        operationsText,
      'currentMedications':     medicamentsText,
    };

    try {
      final res = await ApiClient.patch(Endpoints.me, body);
      if (!res.success) {
        // Non-blocking: if backend fails, we already saved locally
        // Patient can still proceed — data will sync on next profile update
        debugPrint('Medical form backend error: ' + (res.error ?? ''));
      }
    } catch (e) {
      debugPrint('Medical form network error: ' + e.toString());
    }
    // ─────────────────────────────────────────────────────────────────

    setState(() => _loading = false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEFBF7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black87, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Informations Générales',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('INFORMATIONS DE BASE'),
                  _sectionCard(children: [
                    _itemHeader(Icons.water_drop_outlined, 'Groupe sanguin',
                        'Choisissez une réponse'),
                    const SizedBox(height: 12),
                    _bloodTypeGrid(),
                  ]),

                  _sectionLabel('ALLERGIES'),
                  _sectionCard(children: [
                    _itemHeader(Icons.eco_outlined,
                        'Avez-vous des allergies ?', 'Citez-les toutes'),
                    const SizedBox(height: 4),
                    // Optional hint
                    const Text('(Facultatif — laissez vide si aucune)',
                        style: TextStyle(fontSize: 10, color: Colors.black38)),
                    const SizedBox(height: 8),
                    ..._allergies.map((a) => _checkboxTile(
                          label: a,
                          selected: _selectedAllergies.contains(a),
                          onTap: () => setState(() {
                            _selectedAllergies.contains(a)
                                ? _selectedAllergies.remove(a)
                                : _selectedAllergies.add(a);
                          }),
                        )),
                    if (_selectedAllergies.contains('Autre'))
                      _autreTextField(_allergieAutreController),
                  ]),

                  _sectionLabel('MALADIES CHRONIQUES'),
                  _sectionCard(children: [
                    _itemHeader(Icons.monitor_heart_outlined,
                        'Souffrez-vous de maladies chroniques ?',
                        'Citez-les toutes'),
                    const SizedBox(height: 4),
                    const Text('(Facultatif — laissez vide si aucune)',
                        style: TextStyle(fontSize: 10, color: Colors.black38)),
                    const SizedBox(height: 8),
                    ..._maladies.map((m) => _checkboxTile(
                          label: m,
                          selected: _selectedMaladies.contains(m),
                          onTap: () => setState(() {
                            _selectedMaladies.contains(m)
                                ? _selectedMaladies.remove(m)
                                : _selectedMaladies.add(m);
                          }),
                        )),
                    if (_selectedMaladies.contains('Autre'))
                      _autreTextField(_maladieAutreController),
                  ]),

                  _sectionLabel('ANTÉCÉDENTS CHIRURGICAUX'),
                  _sectionCard(children: [
                    _itemHeader(Icons.medical_services_outlined,
                        'Avez-vous déjà été opéré(e) ?', 'Si oui, citez-les'),
                    const SizedBox(height: 12),
                    _ouiNonRow(
                      value: _aEteOpere,
                      onChanged: (v) => setState(() => _aEteOpere = v),
                    ),
                    if (_aEteOpere == true) ...[
                      const SizedBox(height: 10),
                      _autreTextField(_operationController,
                          hint: 'Décrivez vos opérations'),
                    ],
                  ]),

                  _sectionLabel('TRAITEMENT EN COURS'),
                  _sectionCard(children: [
                    _itemHeader(Icons.medication_outlined,
                        'Prise de médicaments actuelle ?',
                        'Si oui, citez-les'),
                    const SizedBox(height: 12),
                    _ouiNonRow(
                      value: _prendMedicaments,
                      onChanged: (v) =>
                          setState(() => _prendMedicaments = v),
                    ),
                    if (_prendMedicaments == true) ...[
                      const SizedBox(height: 10),
                      _autreTextField(_medicamentsController,
                          hint: 'Listez vos médicaments'),
                    ],
                  ]),

                  // Validation error
                  if (_submitError != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color:
                                AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_submitError!,
                                style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: GestureDetector(
          onTap: _loading ? null : _onSubmit,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.75),
                  AppColors.primary,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_outlined,
                          color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Soumettre le formulaire',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ── UI helpers (unchanged) ────────────────────────────────────────────
  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 0, 8),
        child: Text(label,
            style: TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2)),
      );

  Widget _sectionCard({required List<Widget> children}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children),
      );

  Widget _itemHeader(IconData icon, String title, String subtitle) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(
                color: Color(0xFFE8FAF5), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black45)),
              ],
            ),
          ),
        ],
      );

  Widget _bloodTypeGrid() => GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.2,
        children: _bloodTypes.map((bt) {
          final sel = _selectedBloodType == bt;
          return GestureDetector(
            onTap: () => setState(() => _selectedBloodType = bt),
            child: Container(
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : Colors.white,
                border: Border.all(
                    color: sel ? AppColors.primary : AppColors.border,
                    width: 1.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(bt,
                    style: TextStyle(
                        color: sel ? Colors.white : Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          );
        }).toList(),
      );

  Widget _checkboxTile(
          {required String label,
          required bool selected,
          required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8FAF5) : Colors.white,
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: 1.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      color: selected
                          ? AppColors.primary
                          : Colors.black87)),
              if (selected)
                Icon(Icons.check, color: AppColors.primary, size: 18),
            ],
          ),
        ),
      );

  Widget _ouiNonRow(
          {required bool? value,
          required ValueChanged<bool> onChanged}) =>
      Row(children: [
        Expanded(
            child: _ouiNonButton(
                'Oui', value == true, () => onChanged(true))),
        const SizedBox(width: 10),
        Expanded(
            child: _ouiNonButton(
                'Non', value == false, () => onChanged(false))),
      ]);

  Widget _ouiNonButton(
          String label, bool selected, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: 1.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: selected ? Colors.white : Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      );

  Widget _autreTextField(TextEditingController ctrl,
          {String hint = 'Votre réponse'}) =>
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: TextField(
          controller: ctrl,
          style:
              const TextStyle(fontSize: 13, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: Colors.black38, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: AppColors.border, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      );
}