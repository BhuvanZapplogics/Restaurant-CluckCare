import 'package:hive_flutter/hive_flutter.dart';
import '../models/attendance.dart';

class AttendanceRepository {
  static const String _boxName = 'attendance_box';
  Box<dynamic>? _box;

  Future<void> _init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
    }
  }

  String _idFor(String staffId, DateTime date) {
    final d = normalizeDate(date);
    return '${staffId}_${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<AttendanceRecord> _getOrCreate(String staffId, DateTime date) async {
    await _init();
    final id = _idFor(staffId, date);
    final raw = _box!.get(id);
    if (raw != null) {
      return AttendanceRecord.fromJson(Map<String, dynamic>.from(raw as Map));
    }
    final rec = AttendanceRecord(id: id, staffId: staffId, date: normalizeDate(date));
    await _box!.put(id, rec.toJson());
    return rec;
  }

  Future<void> addOrUpdateOpen(String staffId, DateTime checkInAt) async {
    final rec = await _getOrCreate(staffId, checkInAt);
    final updated = rec.copyWith(checkInAt: rec.checkInAt ?? checkInAt);
    await _box!.put(updated.id, updated.toJson());
  }

  Future<void> closeOpen(String staffId, DateTime checkOutAt) async {
    final rec = await _getOrCreate(staffId, checkOutAt);
    final updated = rec.copyWith(checkOutAt: checkOutAt);
    await _box!.put(updated.id, updated.toJson());
  }

  Future<void> addBreak(String staffId, DateTime date, int minutes) async {
    final rec = await _getOrCreate(staffId, date);
    final updated = rec.copyWith(breakMinutes: rec.breakMinutes + minutes);
    await _box!.put(updated.id, updated.toJson());
  }

  Future<AttendanceRecord?> getToday(String staffId) async {
    await _init();
    final id = _idFor(staffId, DateTime.now());
    final raw = _box!.get(id);
    if (raw == null) return null;
    return AttendanceRecord.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<List<AttendanceRecord>> getRange(String staffId, DateTime from, DateTime to) async {
    await _init();
    final start = normalizeDate(from);
    final end = normalizeDate(to);
    final out = <AttendanceRecord>[];
    DateTime cur = start;
    while (!cur.isAfter(end)) {
      final id = _idFor(staffId, cur);
      final raw = _box!.get(id);
      if (raw != null) {
        out.add(AttendanceRecord.fromJson(Map<String, dynamic>.from(raw as Map)));
      }
      cur = cur.add(const Duration(days: 1));
    }
    return out;
  }
}
















