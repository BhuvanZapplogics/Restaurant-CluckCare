import 'package:hive/hive.dart';

class BadgeService {
  static const String _boxName = 'earned_badges';

  // List of all badge IDs
  static const String firstSpin = 'first_spin';
  static const String healthySnack = 'healthy_snack';
  static const String streak3 = 'streak_3';
  static const String proof5 = 'proof_5';
  static const String challenge10 = 'challenge_10';

  static Future<List<String>> getEarnedBadges() async {
    final box = await Hive.openBox(_boxName);
    final badges = List<String>.from(
      box.get('badges', defaultValue: <String>[]),
    );
    print('DEBUG: getEarnedBadges called, badges=$badges');
    return badges;
  }

  static Future<void> _saveEarnedBadges(List<String> badges) async {
    final box = await Hive.openBox(_boxName);
    print('DEBUG: Writing badges to Hive: $badges');
    await box.put('badges', badges);
  }

  static Future<void> checkAndAwardBadges({
    required int totalSpins,
    required int streak,
    required int proofCount,
    required int completedChallenges,
    required bool healthySnackSubmitted,
  }) async {
    print(
      'DEBUG: checkAndAwardBadges called with totalSpins=$totalSpins, streak=$streak, proofCount=$proofCount, completedChallenges=$completedChallenges, healthySnackSubmitted=$healthySnackSubmitted',
    );
    final badges = await getEarnedBadges();
    bool updated = false;

    if (totalSpins >= 1 && !badges.contains(firstSpin)) {
      badges.add(firstSpin);
      updated = true;
    }
    if (healthySnackSubmitted && !badges.contains(healthySnack)) {
      badges.add(healthySnack);
      updated = true;
    }
    if (streak >= 3 && !badges.contains(streak3)) {
      badges.add(streak3);
      updated = true;
    }
    if (proofCount >= 5 && !badges.contains(proof5)) {
      badges.add(proof5);
      updated = true;
    }
    if (completedChallenges >= 10 && !badges.contains(challenge10)) {
      badges.add(challenge10);
      updated = true;
    }
    if (updated) {
      await _saveEarnedBadges(badges);
    }
  }

  static Future<bool> hasBadge(String badgeId) async {
    final badges = await getEarnedBadges();
    return badges.contains(badgeId);
  }
}
