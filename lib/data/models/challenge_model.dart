import 'package:hive/hive.dart';

part 'challenge_model.g.dart';

@HiveType(typeId: 100)
class ChallengeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final int points;

  @HiveField(5)
  final DateTime startDate;

  @HiveField(6)
  final DateTime endDate;

  @HiveField(7)
  final String createdBy;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final List<String> participants;

  @HiveField(10)
  final Map<String, dynamic> progress;

  @HiveField(11)
  final bool isActive;

  @HiveField(12)
  final String difficulty;

  @HiveField(13)
  final List<String> tags;

  @HiveField(14)
  final String imageUrl;

  @HiveField(15)
  final Map<String, dynamic> requirements;

  @HiveField(16)
  final Map<String, dynamic> rewards;

  @HiveField(17)
  final int maxParticipants;

  @HiveField(18)
  final bool isPublic;

  @HiveField(19)
  final List<String> admins;

  @HiveField(20)
  final Map<String, dynamic> settings;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.points,
    required this.startDate,
    required this.endDate,
    required this.createdBy,
    required this.createdAt,
    required this.participants,
    required this.progress,
    required this.isActive,
    required this.difficulty,
    required this.tags,
    required this.imageUrl,
    required this.requirements,
    required this.rewards,
    required this.maxParticipants,
    required this.isPublic,
    required this.admins,
    required this.settings,
  });

  ChallengeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? points,
    DateTime? startDate,
    DateTime? endDate,
    String? createdBy,
    DateTime? createdAt,
    List<String>? participants,
    Map<String, dynamic>? progress,
    bool? isActive,
    String? difficulty,
    List<String>? tags,
    String? imageUrl,
    Map<String, dynamic>? requirements,
    Map<String, dynamic>? rewards,
    int? maxParticipants,
    bool? isPublic,
    List<String>? admins,
    Map<String, dynamic>? settings,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      points: points ?? this.points,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      participants: participants ?? this.participants,
      progress: progress ?? this.progress,
      isActive: isActive ?? this.isActive,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      requirements: requirements ?? this.requirements,
      rewards: rewards ?? this.rewards,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      isPublic: isPublic ?? this.isPublic,
      admins: admins ?? this.admins,
      settings: settings ?? this.settings,
    );
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isUpcoming => DateTime.now().isBefore(startDate);
  bool get isOngoing => !isExpired && !isUpcoming;
  int get participantCount => participants.length;
  bool get isFull => participantCount >= maxParticipants;
  bool get canJoin => isActive && !isFull && !isExpired && isPublic;

  double getProgressForUser(String userId) {
    final userProgress = progress[userId];
    if (userProgress == null) return 0.0;

    final completed = userProgress['completed'] ?? 0;
    final total = userProgress['total'] ?? 1;

    return total > 0 ? (completed / total) : 0.0;
  }

  bool isUserParticipating(String userId) {
    return participants.contains(userId);
  }

  bool isUserAdmin(String userId) {
    return admins.contains(userId) || createdBy == userId;
  }

  bool canUserJoin(String userId) {
    return canJoin && !isUserParticipating(userId);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'points': points,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'participants': participants,
      'progress': progress,
      'isActive': isActive,
      'difficulty': difficulty,
      'tags': tags,
      'imageUrl': imageUrl,
      'requirements': requirements,
      'rewards': rewards,
      'maxParticipants': maxParticipants,
      'isPublic': isPublic,
      'admins': admins,
      'settings': settings,
    };
  }

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      points: json['points'] ?? 0,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      participants: List<String>.from(json['participants'] ?? []),
      progress: Map<String, dynamic>.from(json['progress'] ?? {}),
      isActive: json['isActive'] ?? true,
      difficulty: json['difficulty'] ?? 'medium',
      tags: List<String>.from(json['tags'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
      requirements: Map<String, dynamic>.from(json['requirements'] ?? {}),
      rewards: Map<String, dynamic>.from(json['rewards'] ?? {}),
      maxParticipants: json['maxParticipants'] ?? 100,
      isPublic: json['isPublic'] ?? true,
      admins: List<String>.from(json['admins'] ?? []),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'ChallengeModel(id: $id, title: $title, category: $category, points: $points, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChallengeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
