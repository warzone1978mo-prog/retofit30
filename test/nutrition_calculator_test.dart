import 'package:flutter_test/flutter_test.dart';
import 'package:retofit30/shared/models/user_profile.dart';
import 'package:retofit30/shared/services/nutrition_calculator.dart';

void main() {
  group('NutritionCalculator', () {
    const calculator = NutritionCalculator();

    test('usa Mifflin-St Jeor cuando los datos requeridos existen', () {
      final profile = _profile(sex: BiologicalSex.male);
      final estimate = calculator.estimate(profile);

      expect(estimate.available, isTrue);
      expect(estimate.bmrKcal, closeTo(1648.75, 0.1));
      expect(estimate.tdeeKcal, closeTo(2267.03, 0.1));
      expect(estimate.targetKcal, closeTo(2267.03, 0.1));
    });

    test('no inventa el parametro de sexo biologico', () {
      final estimate = calculator.estimate(
        _profile(sex: BiologicalSex.unspecified),
      );

      expect(estimate.available, isFalse);
      expect(estimate.explanation, contains('Falta'));
    });
  });
}

UserProfile _profile({required BiologicalSex sex}) {
  final now = DateTime(2026, 1, 1);
  return UserProfile(
    alias: 'Test',
    age: 30,
    heightCm: 175,
    weightKg: 70,
    goal: TrainingGoal.maintenance,
    activityLevel: ActivityLevel.light,
    experience: TrainingExperience.beginner,
    trainingPlace: TrainingPlace.home,
    equipment: const ['sin_equipo'],
    desiredZones: const [],
    daysPerWeek: 3,
    minutesPerSession: 30,
    intensityPreference: SessionIntensity.moderate,
    feedingStyle: FeedingStyle.omnivore,
    mealsPerDay: 3,
    region: 'México',
    sexForFormula: sex,
    createdAt: now,
    updatedAt: now,
    challengeStartedAt: now,
  );
}
