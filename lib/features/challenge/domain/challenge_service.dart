import '../../../core/utils/date_utils.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/models/workout_session.dart';

class ChallengeStats {
  const ChallengeStats({
    required this.currentDay,
    required this.completedDays,
    required this.progress,
    required this.streak,
    required this.remainingDays,
  });

  final int currentDay;
  final int completedDays;
  final double progress;
  final int streak;
  final int remainingDays;
}

class ChallengeService {
  const ChallengeService();

  ChallengeStats calculate(UserProfile profile, List<WorkoutSession> sessions) {
    final start = dateOnly(profile.challengeStartedAt);
    final today = dateOnly(DateTime.now());
    final day = today.difference(start).inDays + 1;
    final currentDay = day.clamp(1, 30).toInt();
    final completedDates = sessions
        .where((session) => session.isCompleted && session.completedAt != null)
        .map((session) => dateOnly(session.completedAt!))
        .toSet();
    final completedInChallenge = completedDates
        .where((date) => date.difference(start).inDays.between(0, 29))
        .length;

    return ChallengeStats(
      currentDay: currentDay,
      completedDays: completedInChallenge,
      progress: completedInChallenge / 30,
      streak: _streakFrom(today, completedDates),
      remainingDays: (30 - currentDay).clamp(0, 30).toInt(),
    );
  }

  int _streakFrom(DateTime today, Set<DateTime> completedDates) {
    var cursor = dateOnly(today);
    var streak = 0;
    while (completedDates.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}

extension _IntRange on int {
  bool between(int start, int end) => this >= start && this <= end;
}
