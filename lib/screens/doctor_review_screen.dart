import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/review_service.dart';

class DoctorReviewScreen extends StatefulWidget {
  final dynamic doctor;
  final String doctorId;

  const DoctorReviewScreen({
    super.key,
    required this.doctor,
    required this.doctorId,
  });

  @override
  State<DoctorReviewScreen> createState() => _DoctorReviewScreenState();
}

class _DoctorReviewScreenState extends State<DoctorReviewScreen> {
  int _globalRating = 0;
  int _ponctualiteRating = 0;
  int _communicationRating = 0;
  int _expertiseRating = 0;
  final TextEditingController _commentCtrl = TextEditingController();
  bool _isSubmitting = false;

  List<Review> _reviews = [];
  bool _isLoadingReviews = true;
  String? _reviewsError;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchReviews() async {
    setState(() {
      _isLoadingReviews = true;
      _reviewsError = null;
    });
    try {
      final reviews = await ReviewService.getDoctorReviews(widget.doctorId);
      setState(() {
        _reviews = reviews;
        _isLoadingReviews = false;
      });
    } catch (e) {
      setState(() {
        _reviewsError = 'Impossible de charger les avis.';
        _isLoadingReviews = false;
      });
    }
  }

  Future<void> _submit() async {
    // Validate all four ratings are selected (value between 1 and 5)
    if (_ponctualiteRating == 0 ||
        _communicationRating == 0 ||
        _expertiseRating == 0 ||
        _globalRating == 0) {
      _showSnackBar('Veuillez attribuer toutes les notes', isError: true);
      return;
    }
    if (_commentCtrl.text.trim().isEmpty) {
      _showSnackBar('Veuillez écrire un commentaire', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    // Send all four ratings to the service
    final result = await ReviewService.submitReview(
      doctorId: widget.doctorId,
      punctuality: _ponctualiteRating,
      communication: _communicationRating,
      expertise: _expertiseRating,
      listening: _globalRating,   // using global note as "listening"
      comment: _commentCtrl.text,
    );

    setState(() => _isSubmitting = false);

    if (result.success) {
      _showSnackBar('✅ Avis envoyé avec succès ! Merci !');
      // Clear form
      setState(() {
        _globalRating = 0;
        _ponctualiteRating = 0;
        _communicationRating = 0;
        _expertiseRating = 0;
        _commentCtrl.clear();
      });
      _fetchReviews();
    } else {
      String errorMsg = result.error ?? 'Une erreur est survenue.';
      if (result.statusCode == 403) {
        errorMsg = 'Vous ne pouvez pas noter ce médecin (pas d\'accès actif).';
      }
      _showSnackBar('❌ $errorMsg', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? AppColors.error : const Color(0xFF1A2E2A),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ----------------------------------------------------------------------
  //  UI BUILDERS (unchanged from your original)
  // ----------------------------------------------------------------------
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
            child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 18),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expériences des Patients', style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 17, fontWeight: FontWeight.bold)),
            Text('Évaluations et avis de la communauté', style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDoctorCard(),
            const SizedBox(height: 20),
            _buildSectionTitle('Votre évaluation'),
            const SizedBox(height: 12),
            _buildEvaluationForm(),
            const SizedBox(height: 24),
            _buildSectionTitle('Avis des patients'),
            const SizedBox(height: 12),
            _buildReviewsList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(radius: 30, backgroundColor: AppColors.primaryLight, child: const Icon(Icons.person, color: AppColors.primary, size: 30)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.doctor['name'] ?? 'Dr.Merazi', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1A2E))),
                    Text(widget.doctor['specialty'] ?? 'Cardiologue', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                    const SizedBox(height: 4),
                    Row(children: [const Icon(Icons.location_on_rounded, size: 12, color: AppColors.primary), const SizedBox(width: 2), Text(widget.doctor['hospital'] ?? 'EPH-SBA', style: const TextStyle(fontSize: 12, color: AppColors.primary))]),
                    const SizedBox(height: 6),
                    Row(children: [..._buildStars(widget.doctor['rating'] ?? 4.8, size: 14), const SizedBox(width: 6), Text('${widget.doctor['rating']} (${widget.doctor['reviewCount']})', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: Column(children: [_ProgressRow(label: 'Ponctualité', value: 0.9), const SizedBox(height: 10), _ProgressRow(label: 'Expertise', value: 0.75)])),
              const SizedBox(width: 16),
              Expanded(child: Column(children: [_ProgressRow(label: 'Communication', value: 0.85), const SizedBox(height: 10), _ProgressRow(label: 'Écoute', value: 0.8)])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RatingRow(label: 'NOTE GLOBALE', isLabel: true, rating: _globalRating, onRating: (v) => setState(() => _globalRating = v)),
          const SizedBox(height: 12),
          _RatingRow(label: 'Ponctualité', rating: _ponctualiteRating, onRating: (v) => setState(() => _ponctualiteRating = v)),
          const SizedBox(height: 8),
          _RatingRow(label: 'Communication', rating: _communicationRating, onRating: (v) => setState(() => _communicationRating = v)),
          const SizedBox(height: 8),
          _RatingRow(label: 'Expertise médicale', rating: _expertiseRating, onRating: (v) => setState(() => _expertiseRating = v)),
          const SizedBox(height: 14),
          const Text('Commentaires', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE8E8E8))),
            child: TextField(
              controller: _commentCtrl,
              maxLines: 4,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(hintText: 'Décrivez votre expérience de consultation', hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13), border: InputBorder.none, contentPadding: const EdgeInsets.all(12)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _isSubmitting ? null : _submit,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isSubmitting ? [Colors.grey.shade300, Colors.grey.shade400] : [AppColors.primary.withValues(alpha: 0.85), AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_isSubmitting ? 'Envoi...' : 'Soumettre l\'évaluation', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(children: [Container(width: 4, height: 18, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)))]);
  }

  Widget _buildReviewsList() {
    if (_isLoadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_reviewsError != null) {
      return Center(child: Column(children: [Text(_reviewsError!, style: const TextStyle(color: Colors.red)), const SizedBox(height: 8), TextButton(onPressed: _fetchReviews, child: const Text('Réessayer'))]));
    }
    if (_reviews.isEmpty) {
      return Container(padding: const EdgeInsets.all(24), alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: const Text('Aucun avis pour le moment. Soyez le premier à donner votre avis !', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)));
    }
    return Column(children: _reviews.map((review) => _ReviewCard(review: review)).toList());
  }

  List<Widget> _buildStars(double rating, {double size = 16}) {
    return List.generate(5, (i) => Icon(i < rating.floor() ? Icons.star_rounded : (i < rating ? Icons.star_half_rounded : Icons.star_outline_rounded), color: const Color(0xFFFFB800), size: size));
  }
}

// ----------------------------------------------------------------------
//  Reusable Widgets (exactly as you had)
// ----------------------------------------------------------------------
class _RatingRow extends StatelessWidget {
  final String label;
  final int rating;
  final ValueChanged<int> onRating;
  final bool isLabel;
  const _RatingRow({required this.label, required this.rating, required this.onRating, this.isLabel = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: isLabel ? 12 : 13, fontWeight: isLabel ? FontWeight.w700 : FontWeight.w500, color: isLabel ? Colors.grey.shade500 : const Color(0xFF1A1A2E), letterSpacing: isLabel ? 0.5 : 0))),
        Row(children: List.generate(5, (i) => GestureDetector(onTap: () => onRating(i + 1), child: Icon(i < rating ? Icons.star_rounded : Icons.star_outline_rounded, color: i < rating ? const Color(0xFFFFB800) : Colors.grey.shade300, size: 22)))),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double value;
  const _ProgressRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        const SizedBox(height: 4),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: value, backgroundColor: Colors.grey.shade200, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary), minHeight: 6)),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 18, backgroundColor: AppColors.primaryLight, child: const Icon(Icons.person, color: AppColors.primary, size: 18)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.patientName ?? 'Patient', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1A1A2E))),
                  Row(children: [
                    ...List.generate(5, (i) => Icon(i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded, color: const Color(0xFFFFB800), size: 12)),
                    const SizedBox(width: 6),
                    Text(_formatDate(review.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                  ]),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.comment, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays < 7) {
      if (diff.inDays == 0) return "Aujourd'hui";
      if (diff.inDays == 1) return "Hier";
      return "Il y a ${diff.inDays} jours";
    }
    return "${date.day} ${_monthAbbr(date.month)} ${date.year}";
  }

  String _monthAbbr(int month) {
    const months = ['Janv', 'Fév', 'Mars', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc'];
    return months[month - 1];
  }
}