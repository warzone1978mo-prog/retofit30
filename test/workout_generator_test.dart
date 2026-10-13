import 'package:flutter_test/flutter_test.dart';
import 'package:retofit30/features/workouts/data/local_exercise_catalog.dart';
import 'package:retofit30/features/workouts/domain/workout_generator.dart';
import 'package:retofit30/shared/models/body_zone.dart';
import 'package:retofit30/shared/models/exercise.dart';
import 'package:retofit30/shared/models/user_profile.dart';

void main() {
  group('WorkoutGenerator', () {
    final generator = WorkoutGenerator(
      catalog: const LocalExerciseCatalog().all(),
    );

    test('genera rutina compatible de cuerpo completo sin equipo', () {
      final result = generator.generate(
        profile: _profile(),
        plannedAt: DateTime(2026, 1, 1),
      );

      expect(result.session, isNotNull);
      expect(result.session!.exercises.length, greaterThanOrEqualTo(5));
      expect(
        result.session!.exercises.every(
          (plan) => plan.exercise.equipment.every((item) => item == 'sin_equipo'),
        ),
        isTrue,
      );
    });

    test('no permite intensidad avanzada para principiante', () {
      final result = generator.generate(
        profile: _profile(intensity: SessionIntensity.advanced),
        plannedAt: DateTime(2026, 1, 1),
      );

      expect(result.session!.intensity, SessionIntensity.high);
      expect(result.warning, isNotNull);
    });

    test('el filtro de ejercicio respeta equipo disponible', () {
      final dumbbellOnly = const LocalExerciseCatalog()
          .all()
          .firstWhere((exercise) => exercise.id == 'local_db_row');

      expect(
        dumbbellOnly.isCompatibleWith(
          zones: const [BodyZone.back],
          availableEquipment: const ['sin_equipo'],
          experience: TrainingExperience.beginner,
          dislikedExercises: const [],
        ),
        isFalse,
      );
      expect(dumbbellOnly.difficulty, ExerciseDifficulty.beginner);
    });
  });
}

UserProfile _profile({SessionIntensity intensity = SessionIntensity.moderate}) {
  final now = DateTime(2026, 1, 1);
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
    intensityPreference: intensity,
    feedingStyle: FeedingStyle.omnivore,
    mealsPerDay: 3,
    region: 'México',
    sexForFormula: BiologicalSex.unspecified,
    createdAt: now,
    updatedAt: now,
    challengeStartedAt: now,
  );
}
