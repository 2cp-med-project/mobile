// screens/dossier_screen.dart
// Medical files screen — list, search, filter, view PDF, info panel

import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../services/record_service.dart';

class MedicalFile {
  final String id;
  final String name;
  final String doctorName;
  final String date;
  final String type;

  final String? pdfUrl;
  final String? aiSummary;

  // consultation fields
  final String? motive;
  final String? symptoms;
  final String? severity;
  final String? diagnosis;
  final String? treatmentPlan;
  final String? doctorNote;

  final String? bloodPressure;
  final String? heartRate;
  final String? respiratoryRate;
  final String? temperature;
  final String? weight;

  final String? systemReview;
  final String? additionalTests;
  final String? status;
  final String? followUpDate;

  const MedicalFile({
    required this.id,
    required this.name,
    required this.doctorName,
    required this.date,
    required this.type,

    this.pdfUrl,
    this.aiSummary,

    this.motive,
    this.symptoms,
    this.severity,
    this.diagnosis,
    this.treatmentPlan,
    this.doctorNote,

    this.bloodPressure,
    this.heartRate,
    this.respiratoryRate,
    this.temperature,
    this.weight,

    this.systemReview,
    this.additionalTests,
    this.status,
    this.followUpDate,
  });
}

class DossierScreen extends StatefulWidget {
  const DossierScreen({super.key});

  @override
  State<DossierScreen> createState() => _DossierScreenState();
}

class _DossierScreenState extends State<DossierScreen> {
  final _searchCtrl = TextEditingController();
  List<MedicalFile> _files = [];
  bool _loading = true;
  String _query = '';

  String? _filterType;
  String? _filterMedecin;
  // 'asc' | 'desc'
  String _sortModifie = 'desc';

  final _types = ['Consultation', 'Analyse', 'Ordonnance', 'Radiologie'];
  final _medecins = ['Dr.Merazi', 'Dr.Belsoumati', 'Dr.xxxxx'];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _loading = true);

    try {
      final records = await RecordService.getConsultations();

      print('📦 RAW RECORDS:');
      print(records);

      final mapped = records.map<MedicalFile>((r) {
        return MedicalFile(
          id: r['_id']?.toString() ?? '',

          // title shown in list
          name: r['motive']?.toString().isNotEmpty == true
              ? r['motive'].toString()
              : 'Consultation médicale',

          doctorName: 'Médecin',

          date: r['date'] != null ? r['date'].toString().split('T')[0] : '',

          type: r['typeofvisit']?.toString() ?? 'Consultation',

          doctorNote: r['notes']?.toString(),

          // consultation details
          motive: r['motive']?.toString(),
          symptoms: r['symptoms']?.toString(),
          severity: r['severity']?.toString(),
          diagnosis: r['diagnosis']?.toString(),
          treatmentPlan: r['treatmentPlan']?.toString(),

          // vitals
          bloodPressure: r['bloodPressure']?.toString(),
          heartRate: r['heartRate']?.toString(),
          respiratoryRate: r['respiratoryRate']?.toString(),
          temperature: r['temperature']?.toString(),
          weight: r['weight']?.toString(),

          // extra medical info
          systemReview: r['systemReview']?.toString(),
          additionalTests: r['additionalTests']?.toString(),

          status: r['status']?.toString(),

          followUpDate: r['followUpDate'] != null
              ? r['followUpDate'].toString().split('T')[0]
              : null,

          aiSummary: r['resume']?.toString(),
        );
      }).toList();

      setState(() {
        _files = mapped;
        _loading = false;
      });

      print('✅ MAPPED FILES: ${_files.length}');
    } catch (e) {
      print('❌ LOAD RECORDS ERROR: $e');

      setState(() {
        _loading = false;
      });
    }
  }

  List<MedicalFile> get _filtered {
    var list = _files.where((f) {
      final q = _query.toLowerCase();
      if (q.isNotEmpty &&
          !f.name.toLowerCase().contains(q) &&
          !f.doctorName.toLowerCase().contains(q))
        return false;
      if (_filterType != null && f.type != _filterType) return false;
      if (_filterMedecin != null && f.doctorName != _filterMedecin)
        return false;
      return true;
    }).toList();

    list.sort(
      (a, b) => _sortModifie == 'asc'
          ? a.date.compareTo(b.date)
          : b.date.compareTo(a.date),
    );
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
            Expanded(child: _buildFileList()),
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

  // ── Filter chips
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

  // ── Column headers
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

  // ── File list
  Widget _buildFileList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final files = _filtered;

    if (files.isEmpty) {
      return const Center(
        child: Text(
          'Aucun dossier médical',
          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecords,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        itemCount: files.length,
        itemBuilder: (_, i) =>
            _FileRow(file: files[i], onTap: () => _openFile(files[i])),
      ),
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

  late List<List<Widget>> _pages;

  @override
  void initState() {
    super.initState();
    _buildPages();
  }

  // ─────────────────────────────────────────────
  // PDF PAGE GENERATION
  // ─────────────────────────────────────────────
  void _buildPages() {
    final file = widget.file;

    final sections = <Widget>[
      _pdfTitle('DOSSIER MÉDICAL'),

      _pdfRow('Date', file.date),
      _pdfRow('Médecin', file.doctorName),
      _pdfRow('Type', file.type),
      _pdfRow('Statut', file.status ?? '-'),

      _divider(),

      _pdfSection('Motif de consultation', file.motive),
      _pdfSection('Symptômes', file.symptoms),
      _pdfSection('Diagnostic', file.diagnosis),
      _pdfSection('Traitement', file.treatmentPlan),
      _pdfSection('Notes du médecin', file.doctorNote),

      _divider(),

      _pdfTitle('SIGNES VITAUX'),

      _pdfRow('Tension artérielle', file.bloodPressure ?? '-'),
      _pdfRow('Fréquence cardiaque', file.heartRate ?? '-'),
      _pdfRow('Respiration', file.respiratoryRate ?? '-'),
      _pdfRow('Température', file.temperature ?? '-'),
      _pdfRow('Poids', file.weight ?? '-'),

      _divider(),

      _pdfSection('Examen du système', file.systemReview),
      _pdfSection('Tests additionnels', file.additionalTests),

      _pdfRow('Suivi prévu', file.followUpDate ?? '-'),
    ];

    _pages = [];
    List<Widget> currentPage = [];

    int sectionCounter = 0;

    for (final section in sections) {
      currentPage.add(section);

      sectionCounter++;

      // split page every 7 blocks
      if (sectionCounter >= 7) {
        _pages.add(List.from(currentPage));
        currentPage.clear();
        sectionCounter = 0;
      }
    }

    if (currentPage.isNotEmpty) {
      _pages.add(currentPage);
    }

    if (_pages.isEmpty) {
      _pages.add([
        const Center(
          child: Text('Aucune donnée disponible'),
        ),
      ]);
    }
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(),
    );
  }

  Widget _pdfTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _pdfRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label :',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _pdfSection(String title, String? content) {
    if (content == null || content.trim().isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.grid_view_rounded,
                color: AppColors.textGrey,
                size: 18,
              ),

              const Spacer(),

              IconButton(
                icon: const Icon(Icons.zoom_out),
                onPressed: () {
                  setState(() {
                    _zoom = (_zoom - 0.25).clamp(0.5, 3.0);
                  });
                },
              ),

              Text('${(_zoom * 100).round()}%'),

              IconButton(
                icon: const Icon(Icons.zoom_in),
                onPressed: () {
                  setState(() {
                    _zoom = (_zoom + 0.25).clamp(0.5, 3.0);
                  });
                },
              ),
            ],
          ),
        ),

        Expanded(
          child: Row(
            children: [
              // Left thumbnails
              Container(
                width: 72,
                color: const Color(0xFFE8F5F1),
                child: ListView.builder(
                  padding: const EdgeInsets.all(6),
                  itemCount: _pages.length,
                  itemBuilder: (_, i) {
                    final selected = i == _selPage;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selPage = i;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Page ${i + 1}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // PDF page
              Expanded(
                child: Container(
                  color: const Color(0xFFF0FAF7),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3,
                    child: Center(
                      child: Transform.scale(
                        scale: _zoom,
                        child: _buildMainPage(_selPage),
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

  // ─────────────────────────────────────────────
  // PDF PAGE VIEW
  // ─────────────────────────────────────────────
  Widget _buildMainPage(int page) {
    return Container(
      width: 330,
      height: 650,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._pages[page],

            const SizedBox(height: 20),

            Center(
              child: Text(
                'Page ${page + 1}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//  INFO PANEL
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
              ],
            ),
          ),

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
