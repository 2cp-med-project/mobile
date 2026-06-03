// screens/health_card_screen.dart
// Medical card — portrait card rotated 90° to appear landscape in screen
// Tap or swipe horizontally to flip recto/verso


import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HealthCardScreen extends StatefulWidget {
  const HealthCardScreen({super.key});
  @override
  State<HealthCardScreen> createState() => _HealthCardScreenState();
}

class _HealthCardScreenState extends State<HealthCardScreen>
    with SingleTickerProviderStateMixin {
  // ── Patient data ──────────────────────────────────────────────────────
  String _nom = '';
  String _prenom = '';
  String _dob = '';
  String _lieu = '';
  String _adresse = '';
  String _phone = '';
  String _groupe = '';
  String _patientId = ''; 
  String? _qrCodeUrl; 
  String? _imagePath; 
  String? _imageUrl; 

  // ── Flip animation ────────────────────────────────────────────────────
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _flipped = false;
  double _dragStartX = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _anim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    // BACKEND TODO: call PatientService.getProfile() here to refresh
    // final profile = await PatientService.getProfile();

    setState(() {
      _prenom = prefs.getString('prenom') ?? '';
      _nom = prefs.getString('nom') ?? '';
      _dob = prefs.getString('date_naissance') ?? '';
      _lieu = prefs.getString('lieu_naissance') ?? '';
      _adresse = prefs.getString('adresse') ?? '';
      _phone = prefs.getString('phone') ?? '';
      _groupe = prefs.getString('groupe_sanguin') ?? '';
      _patientId = prefs.getString('patient_id') ?? '';
      _imagePath = prefs.getString('profile_image_path');
      _imageUrl = prefs.getString('profile_image_url');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _flip() {
    _flipped ? _ctrl.reverse() : _ctrl.forward();
    setState(() => _flipped = !_flipped);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF7),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 28),
            const Text(
              'Ma Carte Médicale',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Glissez ou appuyez pour retourner',
              style: TextStyle(fontSize: 12, color: Color(0xFFC0DDD5)),
            ),
            const SizedBox(height: 30),

            // ── Card area — rotated 90° so portrait card reads landscape ──
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: _flip,
                  onHorizontalDragStart: (d) =>
                      _dragStartX = d.globalPosition.dx,
                  onHorizontalDragEnd: (d) {
                    final delta = d.globalPosition.dx - _dragStartX;
                    if (delta < -40 && !_flipped) _flip();
                    if (delta > 40 && _flipped) _flip();
                  },
                  // Rotate the whole flip container 90°
                  child: RotatedBox(
                    quarterTurns: 3, // rotate 270° = same as -90°
                    child: SizedBox(
                      // Card dimensions: portrait A4-ish card
                      width: MediaQuery.of(context).size.width * (342 / 272),
                      height: MediaQuery.of(context).size.height * (141 / 428),
                      child: AnimatedBuilder(
                        animation: _anim,
                        builder: (_, __) {
                          final angle = _anim.value * math.pi;
                          final front = angle <= math.pi / 2;
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(angle),
                            child: front
                                ? _CardFront(
                                    nom: '$_nom $_prenom '.trim(),
                                    dob: _dob,
                                    lieu: _lieu,
                                    adresse: _adresse,
                                    phone: _phone,
                                    groupe: _groupe,
                                    patientId: _patientId,
                                    imagePath: _imagePath,
                                    imageUrl: _imageUrl,
                                  )
                                : Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..rotateY(math.pi),
                                    child: _CardBack(
                                      patientId: _patientId,
                                      qrCodeUrl: _qrCodeUrl,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Dots
            AnimatedBuilder(
              animation: _anim,
              builder: (_, __) {
                final back = _anim.value > 0.5;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_dot(!back), const SizedBox(width: 8), _dot(back)],
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _dot(bool active) => AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    width: active ? 16 : 8,
    height: 8,
    decoration: BoxDecoration(
      color: active
          ? AppColors.primary
          : AppColors.primary.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}

//  CARD FRONT (recto)
class _CardFront extends StatelessWidget {
  final String nom, dob, lieu, adresse, phone, groupe, patientId;
  final String? imagePath, imageUrl;

  const _CardFront({
    required this.nom,
    required this.dob,
    required this.lieu,
    required this.adresse,
    required this.phone,
    required this.groupe,
    required this.patientId,
    this.imagePath,
    this.imageUrl,
  });

  String get _dobLine {
    if (dob.isEmpty && lieu.isEmpty) return '—';
    final parts = dob.replaceAll(' ', '').split('/');
    final dateStr = parts.length == 3
        ? '${parts[0]}/${parts[1]}/${parts[2]}'
        : dob;
    return lieu.isEmpty ? '$dateStr' : '$dateStr · $lieu';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Light gradient bg
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF8FFFE), Color(0xFFEAF9F4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Background watermark logo (top-right area)
          Positioned(
            right: -10,
            bottom: -10,
            child: Opacity(
              opacity: 0.10,
              child: SvgPicture.asset(
                'assets/images/backgroundLogo.svg',
                width: 140,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),

          // Left green accent stripe
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 5,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1FAF87), Color(0xFF17C99E)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 14, 24, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top: logo + name ──────────────────────────────────
                Row(
                  children: [
                    _LogoMark(),
                    const SizedBox(width: 8),
                    const Text(
                      'Healio',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Middle: photo + info ──────────────────────────────
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Photo 80×100
                      _PatientPhoto(imagePath: imagePath, imageUrl: imageUrl),
                      const SizedBox(width: 28),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              nom.isEmpty ? 'Nom Prénom' : nom,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            _InfoRow(
                              label: 'DATE DE NAISSANCE',
                              color: const Color(0xFFC0DDD5),
                              value: _dobLine,
                            ),
                            const SizedBox(height: 4),
                            _InfoRow(
                              label: 'ADRESSE',
                              color: const Color(0xFFC0DDD5),
                              value: adresse.isEmpty ? '—' : adresse,
                            ),
                            const SizedBox(height: 4),
                            _InfoRow(
                              label: 'NUMÉRO DE TÉLÉPHONE',
                              color: const Color(0xFFC0DDD5),
                              value: phone.isEmpty ? '—' : phone,
                            ),
                            if (groupe.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              _InfoRow(
                                label: 'GROUPE SANGUIN',
                                color: const Color(0xFFC0DDD5),
                                value: groupe,
                              ),
                              const SizedBox(height: 7),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//  CARD BACK (verso)
class _CardBack extends StatelessWidget {
  final String patientId;
  final String? qrCodeUrl;

  const _CardBack({required this.patientId, this.qrCodeUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // bg gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF8FFFE), Color(0xFFEAF9F4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Big background logo watermark — centred, like in the screenshot
          Center(
            child: Opacity(
              opacity: 0.12,
              child: SvgPicture.asset(
                'assets/images/logo.svg',
                width: 200,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),

          // Left green stripe
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 5,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1FAF87), Color(0xFF17C99E)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(28, 14, 24, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top: logo + badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _LogoMark(),
                        const SizedBox(width: 8),
                        const Text(
                          'Healio',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'CARTE MÉDICALE DU PATIENT',
                        style: TextStyle(
                          fontSize: 7,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),

                // QR code centred
                // QR code centred
                Expanded(
                  child: Center(
                    child: QrImageView(
                      data: 'https://healio.foo/p/$patientId',
                      version: QrVersions.auto,
                      size: 110,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),

                // Bottom: site + ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'www.healio.foo',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      patientId,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//  PATIENT PHOTO
class _PatientPhoto extends StatelessWidget {
  final String? imagePath, imageUrl;
  const _PatientPhoto({this.imagePath, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    Widget img;

    // 1. Local file (picked from gallery / personal_info_screen)
    if (imagePath != null && File(imagePath!).existsSync()) {
      img = Image.file(File(imagePath!), fit: BoxFit.cover);
    }
    // 2. URL from backend (after upload)
    else if (imageUrl != null && imageUrl!.isNotEmpty) {
      img = Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    // 3. Placeholder
    else {
      img = _placeholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 100,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: img,
      ),
    );
  }

  Widget _placeholder() => const Center(
    child: Icon(Icons.person, color: AppColors.primary, size: 38),
  );
}

//  HEALIO LOGO MARK (small icon)
class _LogoMark extends StatelessWidget {
  const _LogoMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      padding: const EdgeInsets.all(4),
      child: Image.asset('assets/images/healio.png', fit: BoxFit.contain),
    );
  }
}

//  INFO ROW
class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color? color;
  const _InfoRow({required this.label, required this.value, this.color});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.textGrey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
