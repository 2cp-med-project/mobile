import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class DoctorReviewScreen extends StatefulWidget {
  final dynamic doctor; // _DoctorData from experiences_screen

  const DoctorReviewScreen({super.key, required this.doctor});

  @override
  State<DoctorReviewScreen> createState() => _DoctorReviewScreenState();
}

class _DoctorReviewScreenState extends State<DoctorReviewScreen> {
  int _globalRating = 0;
  int _ponctualiteRating = 0;
  int _communicationRating = 0;
  int _expertiseRating = 0;
  final TextEditingController _commentCtrl = TextEditingController();
  bool _submitted = false;

  final List<_PatientReview> _reviews = const [
    _PatientReview(
      name: 'Amina Haley',
      date: '4 Janv 2026',
      rating: 5,
      comment:
          'Dr.Merazi prend le temps d\'expliquer clairement chaque détail et ne bâcle jamais la consultation. Son diagnostic était précis. Je le recommande vivement pour les soins cardiaques.',
    ),
    _PatientReview(
      name: 'Amina Haley',
      date: '4 Janv 2026',
      rating: 5,
      comment:
          'Dr.Merazi prend le temps d\'expliquer clairement chaque détail et ne bâcle jamais la consultation. Son diagnostic était précis. Je le recommande vivement pour les soins cardiaques.',
    ),
    _PatientReview(
      name: 'Amina Haley',
      date: '4 Janv 2026',
      rating: 4,
      comment:
          'Dr.Merazi prend le temps d\'expliquer clairement chaque détail et ne bâcle jamais la consultation. Son diagnostic était précis. Je le recommande vivement pour les soins cardiaques.',
    ),
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_globalRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez attribuer une note globale'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _submitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Évaluation soumise avec succès !'),
        backgroundColor: AppColors.primary,
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expériences des Patients',
              style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Évaluations et avis de la communauté',
              style: TextStyle(color: AppColors.textGrey, fontSize: 11),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Doctor Info Card ────────────────────────────────────────
            _buildDoctorCard(),
            const SizedBox(height: 20),

            // ── Your Evaluation ─────────────────────────────────────────
            _buildSectionTitle('Votre évaluation'),
            const SizedBox(height: 12),
            _buildEvaluationForm(),
            const SizedBox(height: 24),

            // ── Patient Reviews ──────────────────────────────────────────
            _buildSectionTitle('Avis des patients'),
            const SizedBox(height: 12),
            ..._reviews.map((r) => _ReviewCard(review: r)),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Doctor Info Card ────────────────────────────────────────────────────────
  Widget _buildDoctorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryLight,
                child: const Icon(Icons.person, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.doctor.name ?? 'Dr.Merazi',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      widget.doctor.specialty ?? 'Cardiologue',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 12, color: AppColors.primary),
                        const SizedBox(width: 2),
                        Text(
                          widget.doctor.hospital ?? 'EPH-SBA',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ..._buildStars(widget.doctor.rating ?? 4.8, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.doctor.rating} (${widget.doctor.reviewCount})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bars
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _ProgressRow(label: 'Ponctualité', value: 0.9),
                    const SizedBox(height: 10),
                    _ProgressRow(label: 'Expertise', value: 0.75),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _ProgressRow(label: 'Communication', value: 0.85),
                    const SizedBox(height: 10),
                    _ProgressRow(label: 'Écoute', value: 0.8),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Evaluation Form ─────────────────────────────────────────────────────────
  Widget _buildEvaluationForm() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Global rating
          _RatingRow(
            label: 'NOTE GLOBALE',
            isLabel: true,
            rating: _globalRating,
            onRating: (v) => setState(() => _globalRating = v),
          ),
          const SizedBox(height: 12),
          _RatingRow(
            label: 'Ponctualité',
            rating: _ponctualiteRating,
            onRating: (v) => setState(() => _ponctualiteRating = v),
          ),
          const SizedBox(height: 8),
          _RatingRow(
            label: 'Communication',
            rating: _communicationRating,
            onRating: (v) => setState(() => _communicationRating = v),
          ),
          const SizedBox(height: 8),
          _RatingRow(
            label: 'Expertise médicale',
            rating: _expertiseRating,
            onRating: (v) => setState(() => _expertiseRating = v),
          ),
          const SizedBox(height: 14),

          // Comment field
          const Text(
            'Commentaires',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: TextField(
              controller: _commentCtrl,
              maxLines: 4,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Décrivez votre expérience de consultation',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _submitted ? null : _submit,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _submitted
                        ? [Colors.grey.shade300, Colors.grey.shade400]
                        : [
                            AppColors.primary.withValues(alpha: 0.85),
                            AppColors.primary,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _submitted ? 'Évaluation soumise ✓' : 'Soumettre l\'évaluation',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStars(double rating, {double size = 16}) {
    return List.generate(5, (i) {
      return Icon(
        i < rating.floor()
            ? Icons.star_rounded
            : (i < rating
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded),
        color: const Color(0xFFFFB800),
        size: size,
      );
    });
  }
}

// ─── Rating Row ───────────────────────────────────────────────────────────────
class _RatingRow extends StatelessWidget {
  final String label;
  final int rating;
  final ValueChanged<int> onRating;
  final bool isLabel;

  const _RatingRow({
    required this.label,
    required this.rating,
    required this.onRating,
    this.isLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isLabel ? 12 : 13,
              fontWeight: isLabel ? FontWeight.w700 : FontWeight.w500,
              color: isLabel
                  ? Colors.grey.shade500
                  : const Color(0xFF1A1A2E),
              letterSpacing: isLabel ? 0.5 : 0,
            ),
          ),
        ),
        Row(
          children: List.generate(5, (i) {
            return GestureDetector(
              onTap: () => onRating(i + 1),
              child: Icon(
                i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: i < rating
                    ? const Color(0xFFFFB800)
                    : Colors.grey.shade300,
                size: 22,
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─── Progress Row ─────────────────────────────────────────────────────────────
class _ProgressRow extends StatelessWidget {
  final String label;
  final double value;

  const _ProgressRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ─── Review Card ──────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final _PatientReview review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryLight,
                child: const Icon(Icons.person, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: const Color(0xFFFFB800),
                          size: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        review.date,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data Model ───────────────────────────────────────────────────────────────
class _PatientReview {
  final String name;
  final String date;
  final int rating;
  final String comment;

  const _PatientReview({
    required this.name,
    required this.date,
    required this.rating,
    required this.comment,
  });
}