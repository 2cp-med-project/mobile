import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'doctor_review_screen.dart';

class ExperiencesScreen extends StatefulWidget {
  const ExperiencesScreen({super.key});

  @override
  State<ExperiencesScreen> createState() => _ExperiencesScreenState();
}

class _ExperiencesScreenState extends State<ExperiencesScreen> {
  int _selectedFilter = 0;
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _filters = [
    'Tout',
    'Général',
    'Cardiologie',
    'Neurologie',
    'Dermatologie',
  ];

  final List<_DoctorData> _doctors = const [
    _DoctorData(
      name: 'Dr.Merazi',
      specialty: 'Cardiologue',
      hospital: 'EPH-SBA',
      rating: 4.8,
      reviewCount: 234,
      category: 'Cardiologie',
    ),
    _DoctorData(
      name: 'Dr.Belsoumati',
      specialty: 'Généraliste',
      hospital: 'Sidi El Djilali-SBA',
      rating: 4.8,
      reviewCount: 108,
      category: 'Général',
    ),
    _DoctorData(
      name: 'Dr.Merazi',
      specialty: 'Cardiologue',
      hospital: 'EPH-SBA',
      rating: 4.8,
      reviewCount: 340,
      category: 'Cardiologie',
    ),
    _DoctorData(
      name: 'Dr.Belsoumati',
      specialty: 'Généraliste',
      hospital: 'Sidi El Djilali-SBA',
      rating: 4.2,
      reviewCount: 102,
      category: 'Général',
    ),
    _DoctorData(
      name: 'Dr.Merazi',
      specialty: 'Cardiologue',
      hospital: 'EPH-SBA',
      rating: 4.8,
      reviewCount: 234,
      category: 'Cardiologie',
    ),
    _DoctorData(
      name: 'Dr.Belsoumati',
      specialty: 'Généraliste',
      hospital: 'Sidi El Djilali-SBA',
      rating: 4.5,
      reviewCount: 95,
      category: 'Général',
    ),
  ];

  List<_DoctorData> get _filtered {
    final query = _searchCtrl.text.toLowerCase();
    return _doctors.where((d) {
      final matchesSearch =
          query.isEmpty || d.name.toLowerCase().contains(query);
      final matchesFilter =
          _selectedFilter == 0 || d.category == _filters[_selectedFilter];
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
              color: Color(0xFF1FAF87),
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
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Search bar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Recherche',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // ── Filter chips ──────────────────────────────────────────────
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, i) {
                final selected = i == _selectedFilter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      _filters[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: selected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // ── Doctor list ───────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                return _DoctorCard(
                  doctor: _filtered[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DoctorReviewScreen(doctor: _filtered[i]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Doctor Card ──────────────────────────────────────────────────────────────
class _DoctorCard extends StatelessWidget {
  final _DoctorData doctor;
  final VoidCallback onTap;

  const _DoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryLight,
            child: const Icon(Icons.person, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  doctor.specialty,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 11,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      doctor.hospital,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ..._buildStars(doctor.rating),
                    const SizedBox(width: 6),
                    Text(
                      '${doctor.rating} (${doctor.reviewCount})',
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

          // Rate button
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Rate',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStars(double rating) {
    return List.generate(5, (i) {
      return Icon(
        i < rating.floor()
            ? Icons.star_rounded
            : (i < rating ? Icons.star_half_rounded : Icons.star_outline_rounded),
        color: const Color(0xFFFFB800),
        size: 14,
      );
    });
  }
}

// ─── Data Model ───────────────────────────────────────────────────────────────
class _DoctorData {
  final String name;
  final String specialty;
  final String hospital;
  final double rating;
  final int reviewCount;
  final String category;

  const _DoctorData({
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.rating,
    required this.reviewCount,
    required this.category,
  });
}