import 'package:hive/hive.dart';

class ChallengeEntry {
  final String challengeText;
  final DateTime date;
  final List<String> modifiers;
  final bool completed;

  ChallengeEntry({
    required this.challengeText,
    required this.date,
    required this.modifiers,
    required this.completed,
  });

  Map<String, dynamic> toMap() => {
    'challengeText': challengeText,
    'date': date.toIso8601String(),
    'modifiers': modifiers,
    'completed': completed,
  };

  static ChallengeEntry fromMap(Map<String, dynamic> map) => ChallengeEntry(
    challengeText: map['challengeText'],
    date: DateTime.parse(map['date']),
    modifiers: List<String>.from(map['modifiers']),
    completed: map['completed'],
  );
}

class ChallengeService {
  static const String _challengesBox = 'challenges';
  static const String _progressBox = 'progress';

  /// Save today's challenge (when spun/accepted)
  static Future<void> saveTodaysChallenge(ChallengeEntry entry) async {
    final box = await Hive.openBox(_challengesBox);
    final key = _dateKey(entry.date);
    await box.put(key, entry.toMap());
  }

  /// Get today's challenge, or null if not set
  static Future<ChallengeEntry?> getTodaysChallenge() async {
    final box = await Hive.openBox(_challengesBox);
    final key = _dateKey(DateTime.now());
    final map = box.get(key);
    if (map == null) return null;
    return ChallengeEntry.fromMap(Map<String, dynamic>.from(map));
  }

  /// Mark today's challenge as completed and update streak/points
  static Future<void> completeTodaysChallenge() async {
    final box = await Hive.openBox(_challengesBox);
    final progressBox = await Hive.openBox(_progressBox);
    final todayKey = _dateKey(DateTime.now());
    final map = box.get(todayKey);
    if (map == null) return;

    // Mark as completed
    final entry = ChallengeEntry.fromMap(Map<String, dynamic>.from(map));
    final updatedEntry = ChallengeEntry(
      challengeText: entry.challengeText,
      date: entry.date,
      modifiers: entry.modifiers,
      completed: true,
    );
    await box.put(todayKey, updatedEntry.toMap());

    // Update streak
    final lastCompletedDateStr = progressBox.get('lastCompletedDate');
    int streak = progressBox.get('streak', defaultValue: 0);

    if (lastCompletedDateStr != null) {
      final lastCompletedDate = DateTime.parse(lastCompletedDateStr);
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      if (_isSameDate(lastCompletedDate, yesterday)) {
        streak += 1;
      } else if (!_isSameDate(lastCompletedDate, DateTime.now())) {
        streak = 1;
      }
    } else {
      streak = 1;
    }

    await progressBox.put('streak', streak);
    await progressBox.put('lastCompletedDate', _dateKey(DateTime.now()));

    // Update points (example: +10 for completion)
    int points = progressBox.get('points', defaultValue: 0);
    points += 10;
    await progressBox.put('points', points);
  }

  /// Get current streak
  static Future<int> getStreak() async {
    final box = await Hive.openBox(_progressBox);
    return box.get('streak', defaultValue: 0);
  }

  /// Get current points
  static Future<int> getPoints() async {
    final box = await Hive.openBox(_progressBox);
    return box.get('points', defaultValue: 0);
  }

  /// Get number of spins used today
  static Future<int> getSpinsToday() async {
    final box = await Hive.openBox(_progressBox);
    final key = 'spins_${_dateKey(DateTime.now())}';
    return box.get(key, defaultValue: 0);
  }

  /// Increment today's spin count by 1
  static Future<void> incrementSpinsToday() async {
    final box = await Hive.openBox(_progressBox);
    final key = 'spins_${_dateKey(DateTime.now())}';
    int spins = box.get(key, defaultValue: 0);
    spins += 1;
    await box.put(key, spins);
  }

  /// Reset spins if a new day has started (optional, for cleanup)
  static Future<void> resetSpinsIfNewDay() async {
    final box = await Hive.openBox(_progressBox);
    final todayKey = 'spins_${_dateKey(DateTime.now())}';
    final allKeys = box.keys.where((k) => k.toString().startsWith('spins_'));
    for (final k in allKeys) {
      if (k != todayKey) await box.delete(k);
    }
  }

  /// Utility: format date as yyyy-MM-dd
  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
