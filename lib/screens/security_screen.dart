// screens/security_screen.dart
// Confidentialité et Sécurité screen
// BACKEND TODO: biometric/2FA toggles → PATCH /api/patient/security-settings
// BACKEND TODO: change password → POST /api/auth/change-password
// BACKEND TODO: delete account → DELETE /api/patient/account

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_colors.dart';
import '../config/storage_helper.dart';
import 'sign_in_screen.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _biometric = false;
  bool _twoFactor = false;

  // Change password controllers
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl     = TextEditingController();
  final _confirmPwCtrl = TextEditingController();

  bool _showCurrentPw = false;
  bool _showNewPw     = false;
  bool _showConfirmPw = false;
  bool _savingPw      = false;
  bool _pwSuccess     = false;
  String? _pwError;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometric  = prefs.getBool('security_biometric')  ?? false;
      _twoFactor  = prefs.getBool('security_2fa')        ?? false;
    });
  }

  Future<void> _saveToggle(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    // BACKEND TODO: PATCH /api/patient/security-settings {key: value}
  }

  Future<void> _changePassword() async {
    setState(() {
      _pwError  = null;
      _pwSuccess = false;
    });

    if (_currentPwCtrl.text.isEmpty ||
        _newPwCtrl.text.isEmpty ||
        _confirmPwCtrl.text.isEmpty) {
      setState(() => _pwError = 'Veuillez remplir tous les champs.');
      return;
    }
    if (_newPwCtrl.text.length < 8) {
      setState(() =>
          _pwError = 'Le nouveau mot de passe doit contenir au moins 8 caractères.');
      return;
    }
    if (_newPwCtrl.text != _confirmPwCtrl.text) {
      setState(
          () => _pwError = 'Les mots de passe ne correspondent pas.');
      return;
    }

    setState(() => _savingPw = true);

    // BACKEND TODO: POST /api/auth/change-password
    // {current_password, new_password}
    await Future.delayed(const Duration(seconds: 1)); // remove when API ready

    setState(() {
      _savingPw  = false;
      _pwSuccess  = true;
    });
    _currentPwCtrl.clear();
    _newPwCtrl.clear();
    _confirmPwCtrl.clear();

    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _pwSuccess = false);
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer le compte',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: AppColors.textDark)),
        content: const Text(
          'Cette action est irréversible. Toutes vos données seront supprimées définitivement.',
          style: TextStyle(color: AppColors.textGrey, height: 1.5),
        ),
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
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // BACKEND TODO: DELETE /api/patient/account
      await StorageHelper.clear();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBF8),
      appBar: AppBar(
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
            Text('Confidentialité et Sécurité',
                style: TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 17)),
            Text('Gérez votre sécurité',
                style: TextStyle(
                    color: AppColors.primary, fontSize: 11)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Section: Sécurité du compte ──
            _sectionLabel('🔐  Sécurité du compte'),
            _card(children: [
              _toggleTile(
                icon: Icons.fingerprint_rounded,
                label: 'Authentification biométrique',
                subtitle: 'Face ID ou empreinte digitale',
                value: _biometric,
                onChanged: (v) {
                  setState(() => _biometric = v);
                  _saveToggle('security_biometric', v);
                },
              ),
              _cardDivider(),
              _toggleTile(
                icon: Icons.verified_user_outlined,
                label: 'Double authentification (2FA)',
                subtitle: 'Code de vérification par SMS',
                value: _twoFactor,
                onChanged: (v) {
                  setState(() => _twoFactor = v);
                  _saveToggle('security_2fa', v);
                },
              ),
            ]),

            const SizedBox(height: 24),

            // ── Section: Changer mot de passe ──
            _sectionLabel('🔑  Changer le mot de passe'),
            _card(children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _pwField(
                      label: 'MOT DE PASSE ACTUEL',
                      ctrl: _currentPwCtrl,
                      show: _showCurrentPw,
                      onToggle: () => setState(
                          () => _showCurrentPw = !_showCurrentPw),
                    ),
                    const SizedBox(height: 12),
                    _pwField(
                      label: 'NOUVEAU MOT DE PASSE',
                      ctrl: _newPwCtrl,
                      show: _showNewPw,
                      onToggle: () =>
                          setState(() => _showNewPw = !_showNewPw),
                    ),
                    const SizedBox(height: 12),
                    _pwField(
                      label: 'CONFIRMER LE MOT DE PASSE',
                      ctrl: _confirmPwCtrl,
                      show: _showConfirmPw,
                      onToggle: () => setState(
                          () => _showConfirmPw = !_showConfirmPw),
                    ),

                    if (_pwError != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.error, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_pwError!,
                                  style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (_pwSuccess) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Text('✅', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 8),
                            Text(
                              'Mot de passe mis à jour !',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _savingPw ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.5),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _savingPw
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Mettre à jour',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 24),

            // ── Section: Confidentialité ──
            _sectionLabel('🛡️  Confidentialité'),
            _card(children: [
              _actionTile(
                icon: Icons.description_outlined,
                label: 'Politique de confidentialité',
                onTap: () {
                  // BACKEND TODO: open webview with privacy policy URL
                },
              ),
              _cardDivider(),
              _actionTile(
                icon: Icons.article_outlined,
                label: 'Conditions d\'utilisation',
                onTap: () {
                  // BACKEND TODO: open webview with terms URL
                },
              ),
            ]),

            const SizedBox(height: 24),

            // ── Danger zone ──
            _sectionLabel('⚠️  Zone dangereuse'),
            _card(children: [
              _actionTile(
                icon: Icons.delete_forever_outlined,
                label: 'Supprimer mon compte',
                isDestructive: true,
                onTap: _deleteAccount,
              ),
            ]),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  BUILDERS
  // ─────────────────────────────────────────
  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
      );

  Widget _card({required List<Widget> children}) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(children: children),
      );

  Widget _cardDivider() => Divider(
      height: 1,
      indent: 54,
      endIndent: 16,
      color: const Color(0xFFF4FBF8));

  Widget _toggleTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _iconBox(icon, AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.textDark;
    final iconColor =
        isDestructive ? AppColors.error : AppColors.primary;
    final iconBg = isDestructive
        ? AppColors.error.withValues(alpha: 0.1)
        : AppColors.primaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            _iconBox(icon, iconColor, bg: iconBg),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: color)),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.border, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon, Color iconColor,
          {Color? bg}) =>
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bg ?? AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      );

  Widget _pwField({
    required String label,
    required TextEditingController ctrl,
    required bool show,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
                letterSpacing: 0.4)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: TextField(
            controller: ctrl,
            obscureText: !show,
            style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 13),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.lock_outline,
                  color: AppColors.textGrey, size: 16),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 36, minHeight: 0),
              suffixIcon: IconButton(
                onPressed: onToggle,
                icon: Icon(
                  show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textGrey,
                  size: 18,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}