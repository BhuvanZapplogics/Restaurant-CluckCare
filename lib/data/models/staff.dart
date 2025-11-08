class StaffModel {
  final String id;
  final String name;
  final String role;
  final String employeeId;
  final String? status; // present | absent | break | null when not set today
  final String? checkInTime;
  final String? avatarPath; // local file path for profile photo
  final String? lastStatusDate; // yyyy-MM-dd for daily reset

  StaffModel({
    required this.id,
    required this.name,
    required this.role,
    required this.employeeId,
    this.status,
    this.checkInTime,
    this.avatarPath,
    this.lastStatusDate,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'employeeId': employeeId,
      'status': status,
      'checkInTime': checkInTime,
      'avatarPath': avatarPath,
      'lastStatusDate': lastStatusDate,
    };
  }

  // Create from JSON
  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      employeeId: json['employeeId'] as String,
      status: json['status'] as String?,
      checkInTime: json['checkInTime'] as String?,
      avatarPath: json['avatarPath'] as String?,
      lastStatusDate: json['lastStatusDate'] as String?,
    );
  }

  // Copy with method for updates
  StaffModel copyWith({
    String? id,
    String? name,
    String? role,
    String? employeeId,
    String? status,
    String? checkInTime,
    String? avatarPath,
    String? lastStatusDate,
  }) {
    return StaffModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      employeeId: employeeId ?? this.employeeId,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      avatarPath: avatarPath ?? this.avatarPath,
      lastStatusDate: lastStatusDate ?? this.lastStatusDate,
    );
  }
}


