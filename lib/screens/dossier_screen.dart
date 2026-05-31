// screens/dossier_screen.dart
// Medical files screen — list, search, filter, view PDF, info panel
// BACKEND TODO: replace all local demo data with GET /api/dossier/files

import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/consultation_service.dart';
import '../config/storage_helper.dart';

class MedicalFile {
  final String id;
  final String name;
  final String doctorName;
  final String date;
  final String type;

  final String? diagnosis;
  final String? treatmentPlan;
  final String? doctorNote;
  final String? status;
  final String? severity;

  const MedicalFile({
    required this.id,
    required this.name,
    required this.doctorName,
    required this.date,
    required this.type,
    this.diagnosis,
    this.treatmentPlan,
    this.doctorNote,
    this.status,
    this.severity,
  });
}

class DossierScreen extends StatefulWidget {
  const DossierScreen({super.key});

  @override
  State<DossierScreen> createState() => _DossierScreenState();
}

class _DossierScreenState extends State<DossierScreen> {
  final _searchCtrl = TextEditingController();

  String _query = '';
  String? _filterType;
  String? _filterMedecin;
  String _sortModifie = 'desc';

  // Backend consultations converted to MedicalFile
  List<MedicalFile> _consultations = [];

  bool _loading = true;

  // Dynamic doctors list
  List<String> get _medecins {
    final doctors = _consultations
        .map((e) => e.doctorName)
        .where((e) => e.trim().isNotEmpty)
        .toSet()
        .toList();

    doctors.sort();
    return doctors;
  }

  final _types = [
    'Consultation',
    'Analyse',
    'Ordonnance',
    'Radiologie',
  ];

  @override
  void initState() {
    super.initState();
      debugPrint('DOSSIER SCREEN OPENED');

    _loadConsultations();
  }

Future<void> _loadConsultations() async {
    debugPrint('LOAD CONSULTATIONS CALLED');

  try {
    final patientId = await StorageHelper.getPatientId();

    debugPrint('PATIENT ID: $patientId');

    if (patientId == null || patientId.isEmpty) {
      throw Exception('Patient ID not found');
    }

    final data = await ConsultationService.getConsultations(
      patientId: patientId,
      order: _sortModifie,
      sortBy: 'date',
    );

    debugPrint('RAW DATA: $data');


    final files = data.map<MedicalFile>((c) {
      debugPrint('ONE CONSULTATION: $c');

      return MedicalFile(
        id: c['_id'] ?? '',

        name: c['typeofvisit']
                    ?.toString()
                    .trim()
                    .isNotEmpty ==
                true
            ? c['typeofvisit']
            : 'Consultation',

        doctorName:
            c['doctorId']?['fullName'] ??
            c['doctorId']?['name'] ??
            'Médecin',

        date: c['date'] ?? '',

        type: 'Consultation',

        diagnosis: c['diagnosis'],
        treatmentPlan: c['treatmentPlan'],
        doctorNote: c['notes'],
        status: c['status'],
        severity: c['severity'],
      );
    }).toList();

    debugPrint('FILES LENGTH: ${files.length}');

    setState(() {
      _consultations = files;
      _loading = false;
    });

    debugPrint(
      'STATE UPDATED → consultations: ${_consultations.length}',
    );
  } catch (e) {
    debugPrint('Consultations error: $e');

    setState(() {
      _loading = false;
    });
  }
}

  // FILTERED LIST
  List<MedicalFile> get _filtered {
    var list = _consultations.where((f) {
      final q = _query.toLowerCase();

      if (q.isNotEmpty &&
          !f.name.toLowerCase().contains(q) &&
          !f.doctorName.toLowerCase().contains(q)) {
        return false;
      }

      if (_filterType != null && f.type != _filterType) {
        return false;
      }

      if (_filterMedecin != null &&
          f.doctorName != _filterMedecin) {
        return false;
      }

      return true;
    }).toList();

    list.sort((a, b) {
      final da =
          DateTime.tryParse(a.date) ?? DateTime.now();

      final db =
          DateTime.tryParse(b.date) ?? DateTime.now();

      return _sortModifie == 'asc'
          ? da.compareTo(db)
          : db.compareTo(da);
    });

    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF7),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildFilterRow(),
            _buildColumnHeaders(),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _buildFileList(),
            ),
          ],
        ),
      ),
    );
  }


  // ── Search bar 
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          decoration: const InputDecoration(
            hintText: 'Recherche',
            hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: AppColors.textGrey, size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          ),
        ),
      ),
    );
  }

  // ── Filter chips ──────────────────────────────────────────────────────────
  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _filterChip(
            label: 'Type',
            value: _filterType,
            options: _types,
            onSelect: (v) => setState(() => _filterType = v),
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: 'Modifié',
            value: _sortModifie == 'asc' ? '↑' : '↓',
            options: const ['↑ Croissant', '↓ Décroissant'],
            onSelect: (v) => setState(
              () => _sortModifie = v.startsWith('↑') ? 'asc' : 'desc',
            ),
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: 'Médecin',
            value: _filterMedecin,
            options: _medecins,
            onSelect: (v) => setState(() => _filterMedecin = v),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required String? value,
    required List<String> options,
    required void Function(String) onSelect,
  }) {
    final active =
        value != null &&
        value != '↓' && // default sort doesn't count as active
        value != '↑';
    return GestureDetector(
      onTap: () => _showFilterSheet(
        label,
        options,
        onSelect,
        current: value,
        onClear: label == 'Type'
            ? () => setState(() => _filterType = null)
            : label == 'Médecin'
            ? () => setState(() => _filterMedecin = null)
            : null,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? AppColors.primary
                : AppColors.border.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              active ? value! : label,
              style: TextStyle(
                fontSize: 12,
                color: active ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 14,
              color: active ? Colors.white : AppColors.textGrey,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(
    String title,
    List<String> options,
    void Function(String) onSelect, {
    String? current,
    VoidCallback? onClear,
  }) {
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
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                if (onClear != null)
                  GestureDetector(
                    onTap: () {
                      onClear();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Réinitialiser',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            ...options.map((opt) {
              final sel =
                  current == opt ||
                  (opt.startsWith('↑') && current == '↑') ||
                  (opt.startsWith('↓') && current == '↓');
              return GestureDetector(
                onTap: () {
                  onSelect(opt);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : const Color(0xFFF4FBF8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel ? AppColors.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        opt,
                        style: TextStyle(
                          fontSize: 14,
                          color: sel ? AppColors.primary : AppColors.textDark,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      const Spacer(),
                      if (sel)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 18,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Column headers ────────────────────────────────────────────────────────
  Widget _buildColumnHeaders() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          const Text(
            'NOM',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(
              () => _sortModifie = _sortModifie == 'asc' ? 'desc' : 'asc',
            ),
            child: Row(
              children: [
                const Text(
                  'Modifié',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGrey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  _sortModifie == 'asc'
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 10,
                  color: AppColors.textGrey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── File list ─────────────────────────────────────────────────────────────
  Widget _buildFileList() {
    final files = _filtered;
    if (files.isEmpty) {
      return const Center(
        child: Text(
          'Aucun fichier trouvé',
          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      itemCount: files.length,
      itemBuilder: (_, i) =>
          _FileRow(file: files[i], onTap: () => _openFile(files[i])),
    );
  }

  void _openFile(MedicalFile file) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _FileViewerScreen(file: file)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FILE ROW WIDGET
// ─────────────────────────────────────────────────────────────────────────────
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
          border: Border(
            bottom: BorderSide(color: Color(0xFFEEF5F3), width: 1),
          ),
        ),
        child: Row(
          children: [
            // Folder icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.folder_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Name + doctor
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${file.doctorName} · ${file.date}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            // Avatar placeholder
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryLight,
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FILE VIEWER SCREEN  (PDF preview + Info/Share tabs)
// ─────────────────────────────────────────────────────────────────────────────
class _FileViewerScreen extends StatefulWidget {
  final MedicalFile file;
  const _FileViewerScreen({required this.file});

  @override
  State<_FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<_FileViewerScreen> {
  bool _showInfo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textDark,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.file.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            Text(
              _showInfo
                  ? 'Informations sur le fichier'
                  : '${widget.file.date} · ${widget.file.doctorName}',
              style: TextStyle(
                fontSize: 11,
                color: _showInfo ? AppColors.primary : AppColors.textGrey,
              ),
            ),
          ],
        ),
        actions: [
          // Info tab — green when info panel is active
          GestureDetector(
            onTap: () => setState(() => _showInfo = !_showInfo),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _showInfo ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _showInfo
                      ? AppColors.primary
                      : AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 13,
                    color: _showInfo ? Colors.white : AppColors.textGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Info',
                    style: TextStyle(
                      fontSize: 12,
                      color: _showInfo ? Colors.white : AppColors.textGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Share tab
          GestureDetector(
            onTap: () {
              // BACKEND TODO: POST /api/dossier/share/{id}
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.share_outlined,
                    size: 13,
                    color: AppColors.textGrey,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Partager',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _showInfo
          ? _InfoPanel(file: widget.file)
          : _PdfPreview(file: widget.file),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PDF PREVIEW  — pages panel (left) + main view (right)
// ─────────────────────────────────────────────────────────────────────────────
class _PdfPreview extends StatefulWidget {
  final MedicalFile file;
  const _PdfPreview({required this.file});

  @override
  State<_PdfPreview> createState() => _PdfPreviewState();
}

class _PdfPreviewState extends State<_PdfPreview> {
  double _zoom = 1.0;
  int _selPage = 0;

  // Demo: 3 simulated pages
  static const _pageCount = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Toolbar ─────────────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              // Pages icon (left of zoom)
              const Icon(
                Icons.grid_view_rounded,
                color: AppColors.textGrey,
                size: 18,
              ),
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.zoom_out,
                  color: AppColors.textGrey,
                  size: 18,
                ),
                onPressed: () =>
                    setState(() => _zoom = (_zoom - 0.25).clamp(0.5, 3.0)),
              ),
              const SizedBox(width: 8),
              Text(
                '${(_zoom * 100).round()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.zoom_in,
                  color: AppColors.textGrey,
                  size: 18,
                ),
                onPressed: () =>
                    setState(() => _zoom = (_zoom + 0.25).clamp(0.5, 3.0)),
              ),
              const Spacer(),
              const Icon(Icons.more_horiz, color: AppColors.textGrey, size: 18),
            ],
          ),
        ),

        // ── Body: pages panel + main view ───────────────────────────────
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Left: pages panel ──────────────────────────────────
              Container(
                width: 72,
                color: const Color(0xFFE8F5F1),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'PAGES',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textGrey.withValues(alpha: 0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        itemCount: _pageCount,
                        itemBuilder: (_, i) {
                          final selected = i == _selPage;
                          return GestureDetector(
                            onTap: () => setState(() => _selPage = i),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: _buildPageThumb(i),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ── Right: main PDF view ────────────────────────────────
              Expanded(
                child: Container(
                  color: const Color(0xFFF0FAF7),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Transform.scale(
                          scale: _zoom,
                          child: _buildMainPage(_selPage),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Small thumbnail for the pages panel
  Widget _buildPageThumb(int page) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // green header bar
          Container(
            height: 4,
            color: AppColors.primary,
            margin: const EdgeInsets.only(bottom: 4),
          ),
          // text lines
          ...List.generate(
            page == 0 ? 3 : 2,
            (_) => Container(
              height: 3,
              margin: const EdgeInsets.only(bottom: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFD6EEE8),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          if (page == 0) ...[
            const SizedBox(height: 2),
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6F2),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Full-size page for the main viewer
 Widget _buildMainPage(int page) {
  return Container(
    width: 240,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 6,
          color: AppColors.primary,
          margin: const EdgeInsets.only(bottom: 16),
        ),

        Text(
          widget.file.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text('Médecin: ${widget.file.doctorName}'),
        Text('Date: ${widget.file.date}'),

        const Divider(height: 30),

        const Text(
          'Diagnostic',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(widget.file.diagnosis ?? 'Non renseigné'),

        const SizedBox(height: 16),

        const Text(
          'Traitement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(widget.file.treatmentPlan ?? 'Non renseigné'),

        const SizedBox(height: 16),

        const Text(
          'Notes du médecin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(widget.file.doctorNote ?? 'Aucune note'),

        const SizedBox(height: 16),

        Text('Statut: ${widget.file.status ?? 'N/A'}'),
        Text('Sévérité: ${widget.file.severity ?? 'N/A'}'),
      ],
    ),
  );
}}

// ─────────────────────────────────────────────────────────────────────────────
//  INFO PANEL
// ─────────────────────────────────────────────────────────────────────────────
class _InfoPanel extends StatefulWidget {
  final MedicalFile file;
  const _InfoPanel({required this.file});

  @override
  State<_InfoPanel> createState() => _InfoPanelState();
}

class _InfoPanelState extends State<_InfoPanel> {
  bool _generatingSummary = false;
  String? _summary;

  Future<void> _generateSummary() async {
    setState(() => _generatingSummary = true);
    // BACKEND TODO: POST /api/dossier/ai-summary/{id}
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _generatingSummary = false;
      _summary =
          'Le patient présente une légère hypertension artérielle '
          'stabilisée sous traitement. Aucune complication détectée '
          'lors de cette consultation. Suivi recommandé dans 4 semaines.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),

          // ── AI Summary ──────────────────────────────────────────────
          _sectionHeader(
            icon: Icons.auto_awesome_outlined,
            title: 'RÉSUMÉ DE L\'IA',
            action: ElevatedButton(
              onPressed: _generatingSummary ? null : _generateSummary,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _generatingSummary
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Générer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 100),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.4),
              ),
            ),
            child: _summary != null
                ? Text(
                    _summary!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textDark,
                      height: 1.5,
                    ),
                  )
                : const Text(
                    'Résumé par IA',
                    style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                  ),
          ),

          const SizedBox(height: 24),

          // ── Remarques ───────────────────────────────────────────────
          _sectionHeader(icon: Icons.comment_outlined, title: 'REMARQUES'),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 100),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.file.doctorName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.file.doctorNote ??
                      'Notes du médecin concernant le patient',
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.file.doctorNote != null
                        ? AppColors.textDark
                        : AppColors.textGrey,
                    height: 1.5,
                  ),
                ),

    if (widget.file.diagnosis != null) ...[
      const SizedBox(height: 12),
      Text(
        'Diagnostic: ${widget.file.diagnosis}',
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textDark,
        ),
      ),
    ],

    if (widget.file.treatmentPlan != null) ...[
      const SizedBox(height: 12),
      Text(
        'Traitement: ${widget.file.treatmentPlan}',
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textDark,
        ),
      ),
    ],

    if (widget.file.status != null) ...[
      const SizedBox(height: 12),
      Text(
        'Statut: ${widget.file.status}',
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textDark,
        ),
      ),
    ],
  ],
),),

          const SizedBox(height: 24),

          // ── File properties ─────────────────────────────────────────
          _sectionHeader(
            icon: Icons.info_outline,
            title: 'PROPRIÉTÉS DU FICHIER',
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: [
                _propRow('Nom', widget.file.name),
                _propRow('Type', widget.file.type),
                _propRow('Médecin', widget.file.doctorName),
                _propRow('Date', widget.file.date),
                _propRow('Format', 'PDF'),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    Widget? action,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            letterSpacing: 0.5,
          ),
        ),
        const Spacer(),
        if (action != null) action,
      ],
    );
  }

  Widget _propRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            key,
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
