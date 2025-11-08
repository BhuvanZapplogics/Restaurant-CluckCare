import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../data/models/staff.dart';
import '../../../data/models/attendance.dart';
import '../../../data/repositories/attendance_repository.dart';

class StaffDetailScreen extends StatefulWidget {
  final StaffModel staff;
  const StaffDetailScreen({super.key, required this.staff});

  @override
  State<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends State<StaffDetailScreen> {
  final AttendanceRepository _repo = AttendanceRepository();
  late DateTime _month;
  List<AttendanceRecord> _monthRecords = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _loadMonth();
  }

  Future<void> _loadMonth() async {
    setState(() => _loading = true);
    final first = DateTime(_month.year, _month.month, 1);
    final last = DateTime(_month.year, _month.month + 1, 0);
    final records = await _repo.getRange(widget.staff.id, first, last);
    setState(() {
      _monthRecords = records;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = widget.staff.status;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Detail'),
        backgroundColor: AppColors.bgSurface,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
        child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border.withOpacity(0.6)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primaryCta.withOpacity(0.15),
                          child: const Icon(Icons.person, color: AppColors.primaryCta),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.staff.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                              Text(widget.staff.role, style: const TextStyle(color: AppColors.textSecondary)),
                              Text('ID: ${widget.staff.employeeId}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                        _statusPill(status),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Month selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() => _month = DateTime(_month.year, _month.month - 1, 1));
                          _loadMonth();
                        },
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text('${_monthName(_month.month)} ${_month.year}',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      IconButton(
                        onPressed: () {
                          setState(() => _month = DateTime(_month.year, _month.month + 1, 1));
                          _loadMonth();
                        },
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Stats cards
                  Row(
                    children: [
                      Expanded(child: _statCard(icon: Icons.check, color: Colors.green, label: 'Present', value: _presentCount().toString())),
                      const SizedBox(width: 12),
                      Expanded(child: _statCard(icon: Icons.close, color: Colors.red, label: 'Absent', value: _absentCount().toString())),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Attendance rate
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border.withOpacity(0.6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Attendance Rate', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                            Text('${_attendanceRatePercent()}%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _attendanceRate(),
                            minHeight: 8,
                            backgroundColor: AppColors.border.withOpacity(0.3),
                            color: Colors.green,
                          ),
                        ),
                ],
              ),
            ),

                  const SizedBox(height: 16),

                  // Calendar grid
                  _monthCalendar(),
          ],
        ),
      ),
    );
  }

  int _presentCount() {
    return _monthRecords.where((r) => r.checkInAt != null).length;
  }

  int _absentCount() {
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final today = DateTime.now();
    final lastDayToCount = (_month.year == today.year && _month.month == today.month) ? today.day : daysInMonth;
    final present = _presentCount();
    return (lastDayToCount - present).clamp(0, daysInMonth);
  }

  double _attendanceRate() {
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final today = DateTime.now();
    final denominator = (_month.year == today.year && _month.month == today.month) ? today.day : daysInMonth;
    if (denominator <= 0) return 0;
    return _presentCount() / denominator;
  }

  int _attendanceRatePercent() => (_attendanceRate() * 100).round();

  Widget _statCard({required IconData icon, required Color color, required String label, required String value}) {
    return Container(
          padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Icon(icon, color: color),
              const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _monthCalendar() {
    final first = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final startWeekday = first.weekday % 7; // 0=Sun

    final presentDays = _monthRecords.where((r) => r.checkInAt != null).map((r) => r.date.day).toSet();
    final breakDays = _monthRecords.where((r) => r.breakMinutes > 0).map((r) => r.date.day).toSet();
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
      ),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _Wd('S'), _Wd('M'), _Wd('T'), _Wd('W'), _Wd('T'), _Wd('F'), _Wd('S'),
            ],
          ),
              const SizedBox(height: 8),
          // Grid
          Wrap(
            spacing: 0,
            runSpacing: 8,
            children: List.generate(startWeekday + daysInMonth, (i) {
              if (i < startWeekday) {
                return const SizedBox(width: 36, height: 36);
              }
              final day = i - startWeekday + 1;
              final isToday = (today.year == _month.year && today.month == _month.month && today.day == day);
              final hasPresent = presentDays.contains(day);
              final hasBreak = breakDays.contains(day);
              return SizedBox(
                width: 36,
                height: 36,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: isToday ? Border.all(color: Colors.green, width: 2) : null,
                        ),
                        child: Text('$day', style: const TextStyle(color: AppColors.textPrimary)),
                      ),
                    ),
                    if (hasPresent)
                      const Positioned(bottom: 4, left: 8, child: _Dot(color: Colors.green)),
                    if (hasBreak)
                      const Positioned(bottom: 4, right: 8, child: _Dot(color: Colors.orange)),
            ],
          ),
        );
            }),
          ),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return names[m - 1];
  }

  Widget _statusPill(String? status) {
    late Color color;
    late String label;
    switch (status) {
      case 'present':
        color = Colors.green; label = 'Present'; break;
      case 'break':
        color = Colors.orange; label = 'On Break'; break;
      case 'absent':
        color = Colors.red; label = 'Absent'; break;
      default:
        color = AppColors.border; label = '—';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.4))),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
    );
  }
}

// Legacy tabs removed in favor of a single detail view.
// Legacy tabs removed in favor of the single detail view above.

class _Wd extends StatelessWidget {
  final String t;
  const _Wd(this.t);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Center(
        child: Text(t, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}





