import 'package:hive_flutter/hive_flutter.dart';
import '../models/staff.dart';

class StaffRepository {
  static const String _boxName = 'staff';
  static const String _staffListKey = 'staff_list';
  static const String _lastResetKey = 'staff_last_reset';
  Box<dynamic>? _box;

  // Initialize Hive box
  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
    }
  }

  // Get all staff
  Future<List<StaffModel>> getAllStaff() async {
    await init();
    final List<dynamic> staffList = _box?.get(_staffListKey, defaultValue: []) ?? [];
    return staffList
        .map((item) => StaffModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  // Save all staff
  Future<void> saveAllStaff(List<StaffModel> staff) async {
    await init();
    final staffJson = staff.map((s) => s.toJson()).toList();
    await _box?.put(_staffListKey, staffJson);
  }

  // Add a new staff member
  Future<void> addStaff(StaffModel staff) async {
    final allStaff = await getAllStaff();
    allStaff.add(staff);
    await saveAllStaff(allStaff);
  }

  // Update staff member
  Future<void> updateStaff(StaffModel updatedStaff) async {
    final allStaff = await getAllStaff();
    final index = allStaff.indexWhere((s) => s.id == updatedStaff.id);
    if (index != -1) {
      allStaff[index] = updatedStaff;
      await saveAllStaff(allStaff);
    }
  }

  // Delete staff member
  Future<void> deleteStaff(String id) async {
    final allStaff = await getAllStaff();
    allStaff.removeWhere((s) => s.id == id);
    await saveAllStaff(allStaff);
  }

  // Clear all staff
  Future<void> clearAll() async {
    await init();
    await _box?.clear();
  }

  Future<String?> getLastResetDate() async {
    await init();
    return _box?.get(_lastResetKey) as String?;
  }

  Future<void> setLastResetDate(String date) async {
    await init();
    await _box?.put(_lastResetKey, date);
  }

  Future<void> clearStaffListOnly() async {
    await init();
    await _box?.delete(_staffListKey);
  }
}


