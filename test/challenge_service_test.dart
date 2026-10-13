import 'package:flutter_test/flutter_test.dart';
import 'package:retofit30/features/challenge/domain/challenge_service.dart';
import 'package:retofit30/shared/models/body_zone.dart';
import 'package:retofit30/shared/models/user_profile.dart';
import 'package:retofit30/shared/models/workout_session.dart';

void main() {
  test('calcula dias completados solo desde sesiones reales', () {
    final start = DateTime.now().subtract(const Duration(days: 2));
    final profile = _profile(start);
    final service = const ChallengeService();
    final stats = service.calculate(profile, [
      _session(start, WorkoutStatus.completed),
      _session(start.add(const Duration(days: 1)), WorkoutStatus.planned),
    ]);

    expect(stats.completedDays, 1);
    expect(stats.progress, closeTo(1 / 30, 0.001));
  });
}

UserProfile _profile(DateTime start) {
  return UserProfile(
    alias: 'Test',
    age: 30,
    heightCm: 175,
    weightKg: 70,
    goal: TrainingGoal.habit,
    activityLevel: ActivityLevel.light,
    experience: TrainingExperience.beginner,
    trainingPlace: TrainingPlace.home,
    equipment: const ['sin_equipo'],
    desiredZones: const [BodyZone.fullBody],
    daysPerWeek: 3,
    minutesPerSession: 30,
    intensityPreference: SessionIntensity.moderate,
    feedingStyle: FeedingStyle.omnivore,
    mealsPerDay: 3,
    region: 'México',
    sexForFormula: BiologicalSex.unspecified,
    createdAt: start,
    updatedAt: start,
    challengeStartedAt: start,
  );
}

WorkoutSession _session(DateTime date, WorkoutStatus status) {
  return WorkoutSession(
    id: date.toIso8601String(),
    name: 'Sesion',
    plannedAt: date,
    completedAt: status == WorkoutStatus.completed ? date : null,
    type: WorkoutType.mixed,
    goal: TrainingGoal.habit,
    intensity: SessionIntensity.moderate,
    difficultyLabel: 'Principiante',
    plannedDurationMinutes: 30,
    actualDurationMinutes: status == WorkoutStatus.completed ? 30 : 0,
    status: status,
    primaryZones: const [BodyZone.fullBody],
    secondaryZones: const [],
    exercises: const [],
  );
}
