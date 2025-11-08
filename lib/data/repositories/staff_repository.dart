import 'package:hive_flutter/hive_flutter.dart';
import '../models/staff.dart';

class StaffRepository {
  static const String _boxName = 'staff';
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
    final List<dynamic> staffList = _box?.get('staff_list', defaultValue: []) ?? [];
    return staffList
        .map((item) => StaffModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  // Save all staff
  Future<void> saveAllStaff(List<StaffModel> staff) async {
    await init();
    final staffJson = staff.map((s) => s.toJson()).toList();
    await _box?.put('staff_list', staffJson);
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
}


