// screens/appointments_screen.dart
// Mes Rendez-vous — weekly strip, upcoming & past appointments
// + modal to add a new appointment (saved locally)
// BACKEND TODO: replace local list with GET /api/appointments
// BACKEND TODO: POST /api/appointments on save

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_colors.dart';
import '../widgets/top_bubbles.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  MODEL
// ─────────────────────────────────────────────────────────────────────────────
class Appointment {
  final String id;
  final String doctorName;
  final String type;
  final String time;
  final DateTime date;
  final String note;
  final bool remind;
  final String status; // 'confirmed' | 'pending' | 'termine'
  final String? avatarAsset; // optional local asset

  Appointment({
    required this.id,
    required this.doctorName,
    required this.type,
    required this.time,
    required this.date,
    this.note = '',
    this.remind = false,
    this.status = 'pending',
    this.avatarAsset,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'doctorName': doctorName,
        'type': type,
        'time': time,
        'date': date.toIso8601String(),
        'note': note,
        'remind': remind,
        'status': status,
        'avatarAsset': avatarAsset,
      };

  factory Appointment.fromJson(Map<String, dynamic> j) => Appointment(
        id: j['id'] ?? '',
        doctorName: j['doctorName'] ?? '',
        type: j['type'] ?? '',
        time: j['time'] ?? '',
        date: DateTime.parse(j['date']),
        note: j['note'] ?? '',
        remind: j['remind'] ?? false,
        status: j['status'] ?? 'pending',
        avatarAsset: j['avatarAsset'],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  STORAGE
// ─────────────────────────────────────────────────────────────────────────────
class _AppointmentStorage {
  static const _key = 'appointments';

  static Future<List<Appointment>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return _demoData();
    final list = List<Map<String, dynamic>>.from(jsonDecode(raw));
    return list.map(Appointment.fromJson).toList();
  }

  static Future<void> save(List<Appointment> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(list.map((a) => a.toJson()).toList()));
  }

  // Demo seed data (first launch only)
  static List<Appointment> _demoData() => [
        Appointment(
          id: '1',
          doctorName: 'Dr.Merazi',
          type: 'Cardiologie · Visite de suivi',
          time: '10h00',
          date: DateTime.now().add(const Duration(days: 2)),
          status: 'confirmed',
        ),
        Appointment(
          id: '2',
          doctorName: 'Dr.Belsoumati',
          type: 'Généraliste · Consultation',
          time: '09h00',
          date: DateTime(2025, 3, 8),
          status: 'pending',
        ),
        Appointment(
          id: '3',
          doctorName: 'Laboratoire Allal',
          type: 'Analyse en laboratoire',
          time: '08h30',
          date: DateTime(2025, 3, 22),
          status: 'pending',
        ),
        Appointment(
          id: '4',
          doctorName: 'Dr.Merazi',
          type: 'Cardiologie · Revue d\'ECG',
          time: '11h00',
          date: DateTime(2025, 3, 1),
          status: 'termine',
        ),
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Appointment> _appointments = [];
  bool _loading = true;
  bool _showSuccess = false;
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _AppointmentStorage.load();
    setState(() {
      _appointments = list;
      _loading = false;
    });
  }

  Future<void> _addAppointment(Appointment appt) async {
    setState(() => _appointments.insert(0, appt));
    await _AppointmentStorage.save(_appointments);
    setState(() => _showSuccess = true);
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _showSuccess = false);
  }

  List<Appointment> get _upcoming => _appointments
      .where((a) =>
          a.status != 'termine' &&
          (a.date.isAfter(DateTime.now().subtract(const Duration(days: 1)))))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  List<Appointment> get _past => _appointments
      .where((a) =>
          a.status == 'termine' ||
          a.date.isBefore(DateTime.now().subtract(const Duration(days: 1))))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF7),
      body: Stack(
        children: [
          // Background
          const Positioned.fill(child: TopBubbles()),

          SafeArea(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopRow(),
                        const SizedBox(height: 16),
                        _buildWeekStrip(),
                        const SizedBox(height: 28),
                        _sectionTitle('Prochains rendez-vous'),
                        const SizedBox(height: 12),
                        if (_upcoming.isEmpty)
                          _emptyCard('Aucun rendez-vous à venir')
                        else
                          ..._upcoming.map(_buildCard),
                        const SizedBox(height: 28),
                        _sectionTitle('Rendez-vous passé'),
                        const SizedBox(height: 12),
                        if (_past.isEmpty)
                          _emptyCard('Aucun rendez-vous passé')
                        else
                          ..._past.map(_buildCard),
                      ],
                    ),
                  ),
          ),

          // Success toast
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            bottom: _showSuccess ? 90 : -70,
            left: 20,
            right: 20,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('⚠️', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  Text(
                    'Votre rendez-vous médical a été ajouté !',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top row ─────────────────────────────────────────────────────────────
  Widget _buildTopRow() {
    return Row(
      children: [
        const Text(
          'Mes rendez-vous',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _openAddModal,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8)
              ],
            ),
            child: const Icon(Icons.add, color: AppColors.primary, size: 20),
          ),
        ),
      ],
    );
  }

  // ── Week strip ───────────────────────────────────────────────────────────
  Widget _buildWeekStrip() {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Strip always starts TODAY and shows the next 7 days
    final days  = List.generate(7, (i) => today.add(Duration(days: i)));
    const allDayLabels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final months = [
      '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${months[_selectedDay.month]} ${_selectedDay.year}',
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final d = days[i];
              final isSelected = d.day == _selectedDay.day &&
                  d.month == _selectedDay.month &&
                  d.year == _selectedDay.year;
              final isToday = d.day == now.day &&
                  d.month == now.month &&
                  d.year == now.year;
              // dot = has appointment on this day
              final hasDot = _appointments.any((a) =>
                  a.date.day == d.day &&
                  a.date.month == d.month &&
                  a.date.year == d.year);

              return GestureDetector(
                onTap: () => setState(() => _selectedDay = d),
                child: Column(
                  children: [
                    Text(allDayLabels[(d.weekday - 1) % 7],
                        style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textGrey,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${d.day}',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : isToday
                                      ? AppColors.primary
                                      : AppColors.textDark),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: hasDot ? AppColors.primary : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Section title ────────────────────────────────────────────────────────
  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark),
      );

  // ── Appointment card ─────────────────────────────────────────────────────
  Widget _buildCard(Appointment a) {
    final months = [
      '', 'Jan', 'Fév', 'Mars', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    final dateStr = '${a.date.day.toString().padLeft(2, '0')} '
        '${months[a.date.month]}';

    Color statusColor;
    String statusLabel;
    bool showDate = true;

    switch (a.status) {
      case 'confirmed':
        statusColor = AppColors.primary;
        statusLabel = '✓ Confirmed';
        showDate = false;
        break;
      case 'termine':
        statusColor = AppColors.primary;
        statusLabel = '✓ Terminé';
        break;
      default:
        statusColor = const Color(0xFFFF9800);
        statusLabel = '';
        showDate = true;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.doctorName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textDark)),
                const SizedBox(height: 3),
                Text(a.type,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textGrey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (a.status == 'confirmed') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(statusLabel,
                            style: TextStyle(
                                fontSize: 10,
                                color: statusColor,
                                fontWeight: FontWeight.w600)),
                      ),
                    ] else if (a.status == 'termine') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(statusLabel,
                            style: TextStyle(
                                fontSize: 10,
                                color: statusColor,
                                fontWeight: FontWeight.w600)),
                      ),
                    ] else if (showDate) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(dateStr,
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                    const SizedBox(width: 8),
                    const Icon(Icons.access_time,
                        size: 12, color: AppColors.textGrey),
                    const SizedBox(width: 3),
                    Text(a.time,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textGrey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Avatar placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String text) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Text(text,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13)),
      );

  // ── Open add modal ───────────────────────────────────────────────────────
  void _openAddModal() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.transparent, // we handle colour in transitionBuilder
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, anim, _, child) {
        // Blur + dark tint as barrier, slide+fade for the card
        return Stack(
          children: [
            // Blurred backdrop
            FadeTransition(
              opacity: anim,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: 4 * anim.value, sigmaY: 4 * anim.value),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35 * anim.value),
                ),
              ),
            ),
            // Modal card
            SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(0, 0.12), end: Offset.zero)
                  .animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: FadeTransition(opacity: anim, child: child),
            ),
          ],
        );
      },
      pageBuilder: (ctx, _, __) => _AddAppointmentModal(
        onSave: (appt) {
          Navigator.pop(ctx);
          _addAppointment(appt);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ADD APPOINTMENT MODAL
// ─────────────────────────────────────────────────────────────────────────────
class _AddAppointmentModal extends StatefulWidget {
  final void Function(Appointment) onSave;
  const _AddAppointmentModal({required this.onSave});

  @override
  State<_AddAppointmentModal> createState() => _AddAppointmentModalState();
}

class _AddAppointmentModalState extends State<_AddAppointmentModal> {
  final _doctorCtrl = TextEditingController();
  final _timeCtrl   = TextEditingController();
  final _noteCtrl   = TextEditingController();

  final List<String> _types = [
    'Consultation générale',
    'Consultation spécialisée',
    'Analyse en laboratoire',
  ];
  String? _selectedType;
  bool _typeDropdownOpen = false;

  DateTime _selectedDate = DateTime.now();
  bool _remind = false;

  // Validation errors
  String? _doctorError;
  String? _typeError;
  String? _timeError;

  @override
  void dispose() {
    _doctorCtrl.dispose();
    _timeCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _save() {
    setState(() {
      _doctorError =
          _doctorCtrl.text.trim().isEmpty ? 'Champ requis' : null;
      _typeError   = _selectedType == null ? 'Champ requis' : null;
      _timeError   = _timeCtrl.text.trim().isEmpty ? 'Champ requis' : null;
    });
    if (_doctorError != null || _typeError != null || _timeError != null) {
      return;
    }

    widget.onSave(Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      doctorName: _doctorCtrl.text.trim(),
      type: _selectedType!,
      time: _timeCtrl.text.trim(),
      date: _selectedDate,
      note: _noteCtrl.text.trim(),
      remind: _remind,
      status: 'pending',
    ));
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _timeCtrl.text =
            '${picked.hour.toString().padLeft(2, '0')}h${picked.minute.toString().padLeft(2, '0')}';
        _timeError = null;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + 20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.88,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close,
                            color: AppColors.error, size: 22),
                      ),
                      const Expanded(
                        child: Text(
                          'Nouveau rendez-vous',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark),
                        ),
                      ),
                      const SizedBox(width: 22),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Scrollable fields ─────────────────────────────────────
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Doctor name
                        _modalField(
                          controller: _doctorCtrl,
                          hint: 'Nom du Dr',
                          error: _doctorError,
                          onChanged: (_) =>
                              setState(() => _doctorError = null),
                        ),
                        const SizedBox(height: 12),

                        // Type dropdown
                        _TypeDropdown(
                          types: _types,
                          selected: _selectedType,
                          isOpen: _typeDropdownOpen,
                          error: _typeError,
                          onToggle: () => setState(
                              () => _typeDropdownOpen = !_typeDropdownOpen),
                          onSelect: (t) => setState(() {
                            _selectedType = t;
                            _typeDropdownOpen = false;
                            _typeError = null;
                          }),
                        ),
                        const SizedBox(height: 12),

                        // Time
                        GestureDetector(
                          onTap: _pickTime,
                          child: AbsorbPointer(
                            child: _modalField(
                              controller: _timeCtrl,
                              hint: 'Temps',
                              error: _timeError,
                              suffix: const Icon(Icons.access_time,
                                  color: AppColors.textGrey, size: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Date — taps to open native DatePicker
                        GestureDetector(
                          onTap: _pickDate,
                          child: AbsorbPointer(
                            child: _modalField(
                              controller: TextEditingController(
                                text: _selectedDate.day == DateTime.now().day &&
                                        _selectedDate.month == DateTime.now().month &&
                                        _selectedDate.year == DateTime.now().year
                                    ? ''
                                    : '${_selectedDate.day.toString().padLeft(2, '0')}/'
                                      '${_selectedDate.month.toString().padLeft(2, '0')}/'
                                      '${_selectedDate.year}',
                              ),
                              hint: 'Date',
                              suffix: const Icon(Icons.calendar_month_outlined,
                                  color: AppColors.textGrey, size: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // JJ/MM/AAAA hint + Rappelle-moi
                        Row(children: [
                          const Text('JJ/MM/AAAA',
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.textGrey)),
                          const Spacer(),
                          const Text('Rappelle-moi',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textGrey)),
                          const SizedBox(width: 4),
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: _remind,
                              onChanged: (v) => setState(() => _remind = v),
                              activeColor: AppColors.primary,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 12),

                        // Note
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.border
                                    .withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _noteCtrl,
                            maxLines: 3,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textDark),
                            decoration: const InputDecoration(
                              hintText: 'Note...',
                              hintStyle: TextStyle(
                                  color: AppColors.textGrey, fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Save
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _save,
                            child: const Text(
                              'Sauvegarder',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modalField({
    required TextEditingController controller,
    required String hint,
    String? error,
    Widget? suffix,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            border: Border.all(
              color: error != null
                  ? AppColors.error
                  : AppColors.border.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  color: AppColors.textGrey, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 13),
              suffixIcon: suffix,
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 40, minHeight: 0),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 4),
            child: Text(error,
                style: const TextStyle(
                    color: AppColors.error, fontSize: 10)),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TYPE DROPDOWN
// ─────────────────────────────────────────────────────────────────────────────
class _TypeDropdown extends StatelessWidget {
  final List<String> types;
  final String? selected;
  final bool isOpen;
  final String? error;
  final VoidCallback onToggle;
  final void Function(String) onSelect;

  const _TypeDropdown({
    required this.types,
    required this.selected,
    required this.isOpen,
    required this.error,
    required this.onToggle,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              border: Border.all(
                color: isOpen
                    ? AppColors.primary
                    : error != null
                        ? AppColors.error
                        : AppColors.border.withValues(alpha: 0.5),
                width: isOpen ? 1.5 : 1.0,
              ),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isOpen ? 0 : 12),
                bottomRight: Radius.circular(isOpen ? 0 : 12),
              ),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Text(
                  selected ?? 'Type',
                  style: TextStyle(
                      fontSize: 13,
                      color: selected != null
                          ? AppColors.textDark
                          : AppColors.textGrey),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down,
                      color: AppColors.textGrey, size: 18),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: isOpen
              ? Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 1.5),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    children: types.map((t) {
                      final isSelected = t == selected;
                      return GestureDetector(
                        onTap: () => onSelect(t),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 11),
                          color: isSelected
                              ? AppColors.primaryLight
                              : Colors.white,
                          child: Text(t,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textDark,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal)),
                        ),
                      );
                    }).toList(),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        if (error != null && !isOpen)
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 4),
            child: Text(error!,
                style: const TextStyle(
                    color: AppColors.error, fontSize: 10)),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  INLINE CALENDAR
// ─────────────────────────────────────────────────────────────────────────────
class _InlineCalendar extends StatefulWidget {
  final DateTime selected;
  final void Function(DateTime) onSelect;

  const _InlineCalendar({required this.selected, required this.onSelect});

  @override
  State<_InlineCalendar> createState() => _InlineCalendarState();
}

class _InlineCalendarState extends State<_InlineCalendar> {
  late DateTime _viewing; // month being viewed

  @override
  void initState() {
    super.initState();
    _viewing = DateTime(widget.selected.year, widget.selected.month);
  }

  void _prevMonth() =>
      setState(() => _viewing = DateTime(_viewing.year, _viewing.month - 1));
  void _nextMonth() =>
      setState(() => _viewing = DateTime(_viewing.year, _viewing.month + 1));

  @override
  Widget build(BuildContext context) {
    final months = [
      '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    final dayLabels = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];

    final firstDay = DateTime(_viewing.year, _viewing.month, 1);
    final daysInMonth =
        DateTime(_viewing.year, _viewing.month + 1, 0).day;
    // weekday: Mon=1 Sun=7 → offset 0-6
    final startOffset = firstDay.weekday - 1;
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Month navigation
          Row(
            children: [
              Text(
                '${months[_viewing.month]} ${_viewing.year}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textDark),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _prevMonth,
                child: const Icon(Icons.chevron_left,
                    color: AppColors.textGrey, size: 20),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _nextMonth,
                child: const Icon(Icons.chevron_right,
                    color: AppColors.textGrey, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dayLabels
                .map((d) => SizedBox(
                      width: 30,
                      child: Text(d,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textGrey)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),

          // Grid
          ...List.generate(rows, (row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (col) {
                  final cellIndex = row * 7 + col;
                  final day = cellIndex - startOffset + 1;
                  if (day < 1 || day > daysInMonth) {
                    return const SizedBox(width: 30, height: 30);
                  }
                  final date = DateTime(_viewing.year, _viewing.month, day);
                  final isSelected = date.day == widget.selected.day &&
                      date.month == widget.selected.month &&
                      date.year == widget.selected.year;
                  final isToday = date.day == DateTime.now().day &&
                      date.month == DateTime.now().month &&
                      date.year == DateTime.now().year;

                  return GestureDetector(
                    onTap: () => widget.onSelect(date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : isToday
                                ? AppColors.primaryLight
                                : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : isToday
                                      ? AppColors.primary
                                      : AppColors.textDark),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }
}