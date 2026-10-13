import '../models/user_profile.dart';

class EnergyEstimate {
  const EnergyEstimate({
    required this.available,
    required this.explanation,
    this.bmrKcal,
    this.tdeeKcal,
    this.targetKcal,
    this.proteinG,
    this.carbsG,
    this.fatG,
  });

  final bool available;
  final String explanation;
  final double? bmrKcal;
  final double? tdeeKcal;
  final double? targetKcal;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
}

class NutritionCalculator {
  const NutritionCalculator();

  EnergyEstimate estimate(UserProfile profile) {
    if (!profile.isAdult) {
      return const EnergyEstimate(
        available: false,
        explanation:
            'Para menores de edad no se generan metas caloricas automaticas de adulto.',
      );
    }
    if (profile.sexForFormula == BiologicalSex.unspecified) {
      return const EnergyEstimate(
        available: false,
        explanation:
            'Falta el parametro de sexo biologico requerido por Mifflin-St Jeor.',
      );
    }
    if (profile.heightCm <= 0 || profile.weightKg <= 0 || profile.age <= 0) {
      return const EnergyEstimate(
        available: false,
        explanation: 'Faltan peso, estatura o edad validos.',
      );
    }

    final sexConstant =
        profile.sexForFormula == BiologicalSex.male ? 5.0 : -161.0;
    final bmr = (10 * profile.weightKg) +
        (6.25 * profile.heightCm) -
        (5 * profile.age) +
        sexConstant;
    final tdee = bmr * profile.activityLevel.multiplier;
    final target = _targetCalories(tdee, profile.goal);
    final protein = _proteinTarget(profile);
    final fat = (target * 0.28) / 9;
    final carbs = ((target - (protein * 4) - (fat * 9)) / 4).clamp(0, 1000);

    return EnergyEstimate(
      available: true,
      bmrKcal: bmr,
      tdeeKcal: tdee,
      targetKcal: target,
      proteinG: protein,
      carbsG: carbs.toDouble(),
      fatG: fat,
      explanation:
          'Estimacion con Mifflin-St Jeor y factor de actividad declarado. Es una aproximacion ajustable, no una prescripcion clinica.',
    );
  }

  double _targetCalories(double tdee, TrainingGoal goal) {
    return switch (goal) {
      TrainingGoal.fatLoss => tdee - 300,
      TrainingGoal.hypertrophy || TrainingGoal.strength => tdee + 200,
      _ => tdee,
    };
  }

  double _proteinTarget(UserProfile profile) {
    final gramsPerKg = switch (profile.goal) {
      TrainingGoal.hypertrophy || TrainingGoal.strength => 1.8,
      TrainingGoal.fatLoss => 1.6,
      _ => 1.3,
    };
    return profile.weightKg * gramsPerKg;
  }
}
