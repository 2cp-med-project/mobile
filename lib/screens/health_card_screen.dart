// lib/screens/health_card_screen.dart

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_colors.dart';
import '../widgets/logo.dart';

class HealthCardScreen extends StatefulWidget {
  const HealthCardScreen({super.key});

  @override
  State<HealthCardScreen> createState() => _HealthCardScreenState();
}

class _HealthCardScreenState extends State<HealthCardScreen>
    with SingleTickerProviderStateMixin {
  String _nom = '';
  String _prenom = '';
  String _dob = '';
  String _lieu = '';
  String _adresse = '';
  String _phone = '';
  String _patientId = 'R-XXXX XX';
  String? _imagePath;

  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _isBack = false;
  double _dragStart = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _anim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _prenom = prefs.getString('prenom') ?? '';
      _nom = prefs.getString('nom') ?? '';
      _dob = prefs.getString('date_naissance') ?? '';
      _lieu = prefs.getString('lieu_naissance') ?? '';
      _adresse = prefs.getString('adresse') ?? '';
      _phone = prefs.getString('phone') ?? '';
      _patientId = prefs.getString('patient_id') ?? 'R-XXXX XX';
      _imagePath = prefs.getString('profile_image_path');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _flip() {
    _isBack ? _ctrl.reverse() : _ctrl.forward();
    _isBack = !_isBack;
  }

  void _onDragStart(DragStartDetails d) {
    _dragStart = d.globalPosition.dx;
  }

  void _onDragEnd(DragEndDetails d) {
    final delta = d.velocity.pixelsPerSecond.dx;
    if (delta < -40 && !_isBack) _flip();
    if (delta > 40 && _isBack) _flip();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF7),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: _flip,
                  onHorizontalDragStart: _onDragStart,
                  onHorizontalDragEnd: _onDragEnd,
                  child: AnimatedBuilder(
                    animation: _anim,
                    builder: (_, __) {
                      final angle = _anim.value * math.pi;
                      final isFront = angle <= math.pi / 2;

                      return Transform.rotate(
                        angle: -math.pi / 2, // horizontal card
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: 600,
                              height: 400,
                              child: isFront
                                  ? _CardFront(
                                      nom: '$_prenom $_nom',
                                      dob: _dob,
                                      lieu: _lieu,
                                      adresse: _adresse,
                                      phone: _phone,
                                      patientId: _patientId,
                                      imagePath: _imagePath,
                                    )
                                  : Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..rotateY(math.pi),
                                      child: _CardBack(patientId: _patientId),
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            AnimatedBuilder(
              animation: _anim,
              builder: (_, __) {
                final back = _anim.value > 0.5;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dot(!back),
                    const SizedBox(width: 10),
                    _dot(back),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _dot(bool active) => AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    width: active ? 14 : 8,
    height: 6,
    decoration: BoxDecoration(
      color: active ? AppColors.primary : AppColors.primary.withOpacity(0.3),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}

// =======================
// CARD FRONT
// =======================
class _CardFront extends StatelessWidget {
  final String nom, dob, lieu, adresse, phone, patientId;
  final String? imagePath;

  const _CardFront({
    required this.nom,
    required this.dob,
    required this.lieu,
    required this.adresse,
    required this.phone,
    required this.patientId,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _WaveDecoration(height: 100),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 20, 0, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 70, //force proper alignment
                        child: Center(
                          child: Transform.scale(
                            scale: 0.6,
                            child: const Logo(),
                          ),
                        ),
                      ),


                      const Text(
                        'Healio',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.primaryLight,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child:
                              imagePath != null && File(imagePath!).existsSync()
                              ? Image.file(File(imagePath!), fit: BoxFit.cover)
                              : const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                  size: 36,
                                ),
                        ),
                        const SizedBox(width: 14),
                        SizedBox(
                          height: 100, // same as picture
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment
                                .spaceBetween, // spreads items evenly
                            children: [
                              Text(
                                nom.trim().isEmpty ? 'Nom Prénom' : nom,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              _infoLine(
                                label: 'DATE ET LIEU DE NAISSANCE',
                                value: _formatDOB(dob, lieu),
                              ),
                              _infoLine(
                                label: 'ADRESSE',
                                value: adresse.isEmpty ? '—' : adresse,
                              ),
                              _infoLine(
                                label: 'NUMÉRO DE TÉLÉPHONE',
                                value: phone.isEmpty ? '—' : phone,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    patientId,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDOB(String dob, String lieu) {
    if (dob.isEmpty && lieu.isEmpty) return '—';
    final parts = dob.split('/').map((s) => s.trim()).toList();
    String dateStr = dob;
    if (parts.length == 3) dateStr = '${parts[0]}/${parts[1]}/${parts[2]}';
    return lieu.isEmpty ? ' $dateStr' : '$dateStr · $lieu';
  }

  Widget _infoLine({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textDark,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// =======================
// CARD BACK
// =======================
class _CardBack extends StatelessWidget {
  final String patientId;

  const _CardBack({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _WaveDecoration(height: 60),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_hospital_outlined,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Healio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: const Text(
                          'CARTE MÉDICALE DU PATIENT',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(child: Center(child: _QrPlaceholder())),
                  Row(
                    children: [
                      const Text(
                        'www.healio.dz',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        patientId,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================
// QR PLACEHOLDER
// =======================
class _QrPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(130, 130), painter: _QrPainter());
  }
}

class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;
    final cell = size.width / 21;

    void sq(double x, double y, double w, double h) {
      canvas.drawRect(
        Rect.fromLTWH(x * cell, y * cell, w * cell, h * cell),
        paint,
      );
    }

    void finder(double ox, double oy) {
      sq(ox, oy, 7, 7);
      final white = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH((ox + 1) * cell, (oy + 1) * cell, 5 * cell, 5 * cell),
        white,
      );
      sq(ox + 2, oy + 2, 3, 3);
    }

    finder(0, 0);
    finder(14, 0);
    finder(0, 14);

    for (int i = 8; i < 13; i += 2) {
      sq(i.toDouble(), 6, 1, 1);
      sq(6, i.toDouble(), 1, 1);
    }

    final rng = math.Random(42);
    for (int r = 0; r < 21; r++) {
      for (int c = 0; c < 21; c++) {
        if ((r < 8 && c < 8) || (r < 8 && c > 12) || (r > 12 && c < 8))
          continue;
        if (rng.nextBool()) sq(c.toDouble(), r.toDouble(), 1, 1);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// =======================
// WAVE DECORATION
// =======================
class _WaveDecoration extends StatelessWidget {
  final double height;
  const _WaveDecoration({required this.height});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _WavePainter(),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.2,
      size.width * 0.5,
      size.height * 0.9,
      size.width * 0.75,
      size.height * 0.4,
    );
    path.cubicTo(
      size.width * 0.88,
      size.height * 0.1,
      size.width,
      size.height * 0.5,
      size.width,
      size.height * 0.5,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    final paint2 = Paint()
      ..color = AppColors.primary.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.8);
    path2.cubicTo(
      size.width * 0.3,
      size.height * 0.4,
      size.width * 0.6,
      size.height,
      size.width,
      size.height * 0.6,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_) => false;
}
