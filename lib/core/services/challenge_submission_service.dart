import 'package:hive/hive.dart';
import 'package:snack_hack_app/data/models/challenge_submission.dart';

class ChallengeSubmissionService {
  static const String _boxName = 'challenge_submissions';

  static Future<void> saveSubmission(ChallengeSubmission submission) async {
    final box = await Hive.openBox(_boxName);
    await box.put(
      submission.submittedAt.toIso8601String(),
      submission.toJson(),
    );
  }

  static Future<ChallengeSubmission?> getSubmissionForDate(
    DateTime date,
  ) async {
    final box = await Hive.openBox(_boxName);
    final map = box.get(date.toIso8601String());
    if (map == null) return null;
    return ChallengeSubmission.fromJson(Map<String, dynamic>.from(map));
  }

  static Future<List<ChallengeSubmission>> getAllSubmissions() async {
    final box = await Hive.openBox(_boxName);
    return box.values
        .map((e) => ChallengeSubmission.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
