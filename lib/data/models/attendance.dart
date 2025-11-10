class AttendanceRecord {
  final String id; // staffId + yyyy-MM-dd
  final String staffId;
  final DateTime date; // normalized to midnight
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final int breakMinutes; // total break minutes in the day
  final String? notes;

  AttendanceRecord({
    required this.id,
    required this.staffId,
    required this.date,
    this.checkInAt,
    this.checkOutAt,
    this.breakMinutes = 0,
    this.notes,
  });

  Duration get workedDuration {
    if (checkInAt == null) return Duration.zero;
    final end = checkOutAt ?? DateTime.now();
    final total = end.difference(checkInAt!);
    final minusBreaks = total - Duration(minutes: breakMinutes);
    return minusBreaks.isNegative ? Duration.zero : minusBreaks;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'staffId': staffId,
        'date': date.millisecondsSinceEpoch,
        'checkInAt': checkInAt?.millisecondsSinceEpoch,
        'checkOutAt': checkOutAt?.millisecondsSinceEpoch,
        'breakMinutes': breakMinutes,
        'notes': notes,
      };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) => AttendanceRecord(
        id: json['id'] as String,
        staffId: json['staffId'] as String,
        date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
        checkInAt: json['checkInAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['checkInAt'] as int) : null,
        checkOutAt: json['checkOutAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['checkOutAt'] as int) : null,
        breakMinutes: (json['breakMinutes'] as num?)?.toInt() ?? 0,
        notes: json['notes'] as String?,
      );

  AttendanceRecord copyWith({
    DateTime? checkInAt,
    DateTime? checkOutAt,
    int? breakMinutes,
    String? notes,
  }) {
    return AttendanceRecord(
      id: id,
      staffId: staffId,
      date: date,
      checkInAt: checkInAt ?? this.checkInAt,
      checkOutAt: checkOutAt ?? this.checkOutAt,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      notes: notes ?? this.notes,
    );
  }
}

DateTime normalizeDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);













<<<<<<< Updated upstream
=======



>>>>>>> Stashed changes
