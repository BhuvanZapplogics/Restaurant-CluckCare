import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme/colors.dart';
import '../../../data/models/staff.dart';
import '../../../data/repositories/staff_repository.dart';
import 'staff_detail_screen.dart';
import '../../../data/repositories/attendance_repository.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  int filterIndex = 0; // 0: all, 1: present, 2: absent, 3: break
  List<StaffModel> staff = [];
  final StaffRepository _repository = StaffRepository();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoading = true);
    try {
      final loadedStaff = await _repository.getAllStaff();
      // Daily reset: if lastStatusDate != today, clear today's status
      final String today = DateTime.now().toIso8601String().split('T').first; // yyyy-MM-dd
      final List<StaffModel> normalized = loadedStaff.map((s) {
        if (s.lastStatusDate == today) return s;
        // Clear status for a new day
        return s.copyWith(status: null, checkInTime: '-', lastStatusDate: null);
      }).toList();
      // Persist any resets
      for (final s in normalized) {
        if (s != loadedStaff.firstWhere((x) => x.id == s.id)) {
          // not a safe identity check; to avoid overcomplication, just write all
        }
      }
      await _repository.saveAllStaff(normalized);
      setState(() {
        staff = normalized;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading staff: $e')),
        );
      }
    }
  }

  int get totalCount => staff.length;
  int get presentCount => staff.where((e) => e.status == 'present').length;
  int get breakCount => staff.where((e) => e.status == 'break').length;
  int get absentCount => staff.where((e) => e.status == 'absent').length;

  List<StaffModel> get filteredStaff {
    switch (filterIndex) {
      case 1:
        return staff.where((e) => e.status == 'present').toList();
      case 2:
        return staff.where((e) => e.status == 'absent').toList();
      case 3:
        return staff.where((e) => e.status == 'break').toList();
      default:
        return staff;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildSummaryRow(context),
                  const SizedBox(height: 16),
                  _buildFilterChips(context),
                  const SizedBox(height: 16),
                  if (filteredStaff.isEmpty) _buildEmptyStaffIllustration(context),
                  ...filteredStaff.asMap().entries.map((entry) {
                    final e = entry.value;
                    // Map filtered index back to main list index
                    final int originalIndex = staff.indexOf(e);
                    return _StaffCard(
                      name: e.name,
                      role: e.role,
                      id: e.employeeId,
                      status: e.status,
                      avatarPath: e.avatarPath,
                      checkIn: e.checkInTime ?? '-',
                      onStatusChange: (newStatus) async {
                        final String today = DateTime.now().toIso8601String().split('T').first;
                        final updatedStaff = staff[originalIndex].copyWith(
                          status: newStatus,
                          checkInTime: newStatus == 'present'
                              ? TimeOfDay.now().format(context)
                              : staff[originalIndex].checkInTime,
                          lastStatusDate: today,
                        );
                        setState(() {
                          staff[originalIndex] = updatedStaff;
                        });
                        await _repository.updateStaff(updatedStaff);
                        // Attendance tracking hooks
                        final att = AttendanceRepository();
                        if (newStatus == 'present') {
                          await att.addOrUpdateOpen(updatedStaff.id, DateTime.now());
                        } else if (newStatus == 'absent') {
                          await att.closeOpen(updatedStaff.id, DateTime.now());
                        } else if (newStatus == 'break') {
                          await att.addBreak(updatedStaff.id, DateTime.now(), 0);
                        }
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StaffDetailScreen(
                              staff: StaffModel(
                                id: e.id,
                                name: e.name,
                                role: e.role,
                                employeeId: e.employeeId,
                                status: e.status,
                                checkInTime: e.checkInTime,
                                avatarPath: e.avatarPath,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryCta,
        foregroundColor: Colors.white,
        onPressed: () async {
          final newStaffData = await Navigator.of(context).push<Map<String, dynamic>>(
            MaterialPageRoute(builder: (_) => const AddStaffScreen()),
          );
          if (newStaffData != null) {
            final newStaff = StaffModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: newStaffData['name'],
              role: newStaffData['role'],
              employeeId: newStaffData['id'],
              status: null, // require owner to choose Present/Absent
              checkInTime: newStaffData['checkIn'],
              avatarPath: newStaffData['avatarPath'] as String?,
              lastStatusDate: null,
            );
            await _repository.addStaff(newStaff);
            await _loadStaff(); // Reload to show the new staff
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyStaffIllustration(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: AppColors.border.withOpacity(0.3)),
            ),
            child: const Icon(Icons.groups_2_outlined, size: 64, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const Text(
            'No staff yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            filterIndex == 0
                ? 'Add your first team member to start tracking attendance.'
                : 'No staff in this filter. Try a different filter or add staff.',
            style: TextStyle(color: AppColors.textSecondary.withOpacity(0.9), fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 160,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add Staff'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(color: AppColors.border.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final newStaffData = await Navigator.of(context).push<Map<String, dynamic>>(
                  MaterialPageRoute(builder: (_) => const AddStaffScreen()),
                );
                if (newStaffData != null) {
                  final newStaff = StaffModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: newStaffData['name'],
                    role: newStaffData['role'],
                    employeeId: newStaffData['id'],
                    status: null,
                    checkInTime: newStaffData['checkIn'],
                    avatarPath: newStaffData['avatarPath'] as String?,
                    lastStatusDate: null,
                  );
                  await _repository.addStaff(newStaff);
                  await _loadStaff();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Staffboard',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }

  // removed round icon buttons per request

  Widget _buildSummaryRow(BuildContext context) {
    Widget tile(Color dotColor, String count, String label) => Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 80),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withOpacity(0.6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Text(
                    count,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );

    return Row(
      children: [
        tile(Colors.green, presentCount.toString(), 'Present'),
        const SizedBox(width: 8),
        tile(Colors.orange, breakCount.toString(), 'On Break'),
        const SizedBox(width: 8),
        tile(Colors.red, absentCount.toString(), 'Absent'),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final labels = ['All Staff', 'Present', 'Absent', 'On Break'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(labels.length, (i) {
        final selected = i == filterIndex;
        return GestureDetector(
          onTap: () => setState(() => filterIndex = i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryCta : AppColors.cardSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: selected ? Colors.transparent : AppColors.border.withOpacity(0.6)),
            ),
            child: Text(
              labels[i],
              style: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
          ),
        );
      }),
    );
  }
}

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({super.key});

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  String? _avatarPath;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _idCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Staff'),
        backgroundColor: AppColors.bgSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile photo picker
              Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _pickAvatar,
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primaryCta.withOpacity(0.15),
                        backgroundImage: (_avatarPath != null && _avatarPath!.isNotEmpty) ? FileImage(File(_avatarPath!)) : null,
                        child: (_avatarPath == null || _avatarPath!.isEmpty)
                            ? const Icon(Icons.camera_alt, color: AppColors.primaryCta)
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _roleCtrl,
                decoration: const InputDecoration(labelText: 'Role (e.g., Chef, Cashier)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter role' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _idCtrl,
                decoration: const InputDecoration(labelText: 'Employee ID'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter employee ID' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _onSave,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }

  void _onSave() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.of(context).pop({
      'name': _nameCtrl.text.trim(),
      'role': _roleCtrl.text.trim(),
      'id': _idCtrl.text.trim(),
      'avatarPath': _avatarPath,
      'checkIn': '-',
    });
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (file != null) {
        setState(() {
          _avatarPath = file.path;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo selected')),
          );
        }
      }
    } catch (e) {
      // Ignore errors silently
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to pick image: $e')),
        );
      }
    }
  }
}

class _StaffCard extends StatelessWidget {
  final String name;
  final String role;
  final String? id;
  final String? status; // present | absent | break
  final String? checkIn;
  final void Function(String)? onStatusChange;
  final String? avatarPath;
  final VoidCallback? onTap;

  const _StaffCard({required this.name, required this.role, this.id, this.status, this.checkIn, this.onStatusChange, this.avatarPath, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border.withOpacity(0.6)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryCta.withOpacity(0.1),
                  backgroundImage: (avatarPath != null && avatarPath!.isNotEmpty) ? FileImage(File(avatarPath!)) : null,
                  child: (avatarPath == null || avatarPath!.isEmpty) ? Icon(Icons.person, color: AppColors.primaryCta) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          ),
                          _statusPill(status),
                        ],
                      ),
                      Text(role, style: TextStyle(color: AppColors.textSecondary)),
                      if (id != null) Text('ID: $id', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Conditional UI
            if (status == null) ...[
              // First-time selection for today: Present or Absent
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onStatusChange?.call('present'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green),
                        foregroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.green.withOpacity(0.06),
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('Present', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onStatusChange?.call('absent'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.red.withOpacity(0.06),
                      ),
                      icon: const Icon(Icons.close),
                      label: const Text('Absent', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ] else if (status == 'present' || status == 'break') ...[
              // Show toggles for Active/On Break
              Row(
                children: [
                  GestureDetector(
                    onTap: () => onStatusChange?.call('present'),
                    child: _chip(label: 'Active', isActive: status == 'present', color: Colors.green),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onStatusChange?.call('break'),
                    child: _chip(label: 'On Break', isActive: status == 'break', color: Colors.orange),
                  ),
                ],
              ),
            ] else if (status == 'absent') ...[
              // Only absent tag remains (no actions)
              const SizedBox.shrink(),
            ],
          ],
        ),
      ),
    ),
  );
  }

  Widget _statusPill(String? status) {
    Color color;
    String label;
    switch (status) {
      case 'present':
        color = Colors.green;
        label = 'Present';
        break;
      case 'break':
        color = Colors.orange;
        label = 'On Break';
        break;
      case 'absent':
      default:
        color = Colors.red;
        label = 'Absent';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.24)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

}

Widget _chip({required String label, required bool isActive, required Color color}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: isActive ? color : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: isActive ? Colors.transparent : color.withOpacity(0.6)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: isActive ? Colors.white : color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}


