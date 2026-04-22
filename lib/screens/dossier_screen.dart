// screens/dossier_screen.dart — INTEGRATED
// Records = consultations from /api/record/{patientId}
// GET /api/record/{patientId}?page=0&limit=20&order=desc&sortBy=date
// GET /api/record/consultation/{id}  — single consultation detail

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_colors.dart';
import '../services/record_service.dart';

// ── Model updated to map from API ────────────────────────────────────────────
class MedicalFile {
  final String  id;
  final String  name;
  final String  doctorName;
  final String  date;
  final String  type;
  final String? doctorNote;

  const MedicalFile({
    required this.id,
    required this.name,
    required this.doctorName,
    required this.date,
    required this.type,
    this.doctorNote,
  });

  // Maps from API consultation object
  factory MedicalFile.fromApi(Map<String, dynamic> j) {
    final doctor = j['doctor'] as Map<String, dynamic>? ?? {};
    final firstName = doctor['firstName'] as String? ?? '';
    final lastName  = doctor['lastName']  as String? ?? '';
    final doctorName = firstName.isNotEmpty || lastName.isNotEmpty
        ? 'Dr. $firstName $lastName'.trim()
        : j['doctorId']?.toString() ?? '';

    return MedicalFile(
      id:         j['_id']         as String? ?? j['id'] as String? ?? '',
      name:       j['typeofvisit'] as String? ??
                  j['motive']      as String? ?? 'Consultation',
      doctorName: doctorName,
      date:       _formatDate(j['date'] as String? ?? ''),
      type:       j['typeofvisit'] as String? ?? 'Consultation',
      doctorNote: j['notes']       as String?,
    );
  }

  static String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2,'0')}/'
             '${dt.month.toString().padLeft(2,'0')}/'
             '${dt.year}';
    } catch (_) { return raw; }
  }
}

// ── Main screen ──────────────────────────────────────────────────────────────
class DossierScreen extends StatefulWidget {
  const DossierScreen({super.key});
  @override
  State<DossierScreen> createState() => _DossierScreenState();
}

class _DossierScreenState extends State<DossierScreen> {
  final _searchCtrl = TextEditingController();
  String _query     = '';
  String? _filterType;
  String  _sortModifie = 'desc';
  final _types = ['Consultation', 'Analyse', 'Ordonnance', 'Radiologie'];

  List<MedicalFile> _files   = [];
  bool              _loading = true;
  String?           _error;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _loadFiles() async {
    setState(() { _loading = true; _error = null; });

    // Get patient ID from local storage
    final prefs     = await SharedPreferences.getInstance();
    final patientId = prefs.getString('patient_id') ?? '';

    if (patientId.isEmpty) {
      setState(() { _loading = false; _error = 'ID patient introuvable'; });
      return;
    }

    // GET /api/record/{patientId}
    final list = await RecordService.getRecords(
      patientId: patientId,
      order:     _sortModifie,
      sortBy:    'date',
    );

    setState(() {
      _files   = list.map(MedicalFile.fromApi).toList();
      _loading = false;
    });
  }

  List<MedicalFile> get _filtered {
    return _files.where((f) {
      final q = _query.toLowerCase();
      if (q.isNotEmpty &&
          !f.name.toLowerCase().contains(q) &&
          !f.doctorName.toLowerCase().contains(q)) return false;
      if (_filterType != null && f.type != _filterType) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ Keep your existing build() — only replace the data source
    // _filtered now comes from API instead of _demoFiles
    // Add a refresh button or pull-to-refresh:
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF7),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!,
                          style: const TextStyle(color: AppColors.textGrey)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadFiles,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary),
                        child: const Text('Réessayer',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadFiles,
                  child: Column(children: [
                    // ← your existing search bar, filter chips, headers
                    // ← replace _demoFiles with _filtered
                    Expanded(
                      child: _filtered.isEmpty
                          ? const Center(
                              child: Text('Aucun fichier',
                                  style: TextStyle(
                                      color: AppColors.textGrey)))
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) => _FileRow(
                                file: _filtered[i],
                                onTap: () => _openFile(_filtered[i]),
                              ),
                            ),
                    ),
                  ]),
                ),
    );
  }

  void _openFile(MedicalFile file) {
    // Push to your existing _FileViewerScreen
  }
}

// Keep your existing _FileRow, _FileViewerScreen, _InfoPanel, _PdfPreview widgets
// Only the data source (_demoFiles → _files from API) changes
class _FileRow extends StatelessWidget {
  final MedicalFile file;
  final VoidCallback onTap;
  const _FileRow({required this.file, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEF5F3))),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.folder_outlined,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
                Text('${file.doctorName} · ${file.date}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textGrey)),
              ],
            ),
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryLight,
            child: const Icon(Icons.person,
                color: AppColors.primary, size: 16),
          ),
        ]),
      ),
    );
  }
}