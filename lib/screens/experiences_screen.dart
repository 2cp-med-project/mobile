import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/doctor_service.dart';
import 'doctor_review_screen.dart';

class ExperiencesScreen extends StatefulWidget {
  const ExperiencesScreen({super.key});

  @override
  State<ExperiencesScreen> createState() => _ExperiencesScreenState();
}

class _ExperiencesScreenState extends State<ExperiencesScreen> {
  int _selectedFilter = 0;
  final TextEditingController _searchCtrl = TextEditingController();
  
  List<DoctorData> _doctors = [];
  bool _isLoading = true;
  String? _error;

  final List<String> _filters = [
    'Tout', 'Général', 'Cardiologie', 'Neurologie', 'Dermatologie',
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final doctors = await DoctorService.getAllDoctors(); 
      print('✅ Loaded ${doctors.length} doctors');
      setState(() {
        _doctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<DoctorData> get _filtered {
    final query = _searchCtrl.text.toLowerCase();
    return _doctors.where((d) {
      final matchesSearch = query.isEmpty ||
          d.name.toLowerCase().contains(query) ||
          d.specialization.toLowerCase().contains(query);
      final matchesFilter = _selectedFilter == 0 ||
          d.specialization == _filters[_selectedFilter];
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
            child: Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1FAF87), size: 18),
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
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8)]),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Recherche',
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          // Filters
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade300),
                    ),
                    child: Text(_filters[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: selected ? Colors.white : Colors.grey.shade600)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Doctor list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Erreur: $_error'))
                    : _filtered.isEmpty
                        ? const Center(child: Text('Aucun médecin trouvé'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filtered.length,
                            itemBuilder: (context, i) => _DoctorCard(
                              doctor: _filtered[i],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DoctorReviewScreen(
                                    doctor: _filtered[i].toJson(),
                                    doctorId: _filtered[i].id, // ✅ FIXED: pass doctorId
                                  ),
                                ),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

// Doctor card widget (unchanged)
class _DoctorCard extends StatelessWidget {
  final DoctorData doctor;
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
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 28, backgroundColor: AppColors.primaryLight, child: const Icon(Icons.person, color: AppColors.primary, size: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(doctor.specialization, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ..._buildStars(doctor.rating),
                    const SizedBox(width: 6),
                    Text('${doctor.rating} (${doctor.reviewCount})', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(border: Border.all(color: AppColors.primary), borderRadius: BorderRadius.circular(20)),
              child: const Text('Rate', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStars(double rating) {
    return List.generate(5, (i) {
      return Icon(
        i < rating.floor() ? Icons.star_rounded : (i < rating ? Icons.star_half_rounded : Icons.star_outline_rounded),
        color: const Color(0xFFFFB800),
        size: 14,
      );
    });
  }
}