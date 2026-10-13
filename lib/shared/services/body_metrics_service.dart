class BmiResult {
  const BmiResult({
    required this.value,
    required this.category,
    required this.note,
  });

  final double value;
  final String category;
  final String note;
}

class BodyMetricsService {
  const BodyMetricsService();

  double calculateBmi({
    required double weightKg,
    required double heightCm,
  }) {
    if (weightKg <= 0 || heightCm <= 0) {
      throw ArgumentError('Peso y estatura deben ser mayores que cero.');
    }
    final heightMeters = heightCm / 100;
    return weightKg / (heightMeters * heightMeters);
  }

  BmiResult? evaluateAdultBmi({
    required int age,
    required double weightKg,
    required double heightCm,
  }) {
    if (age < 18) {
      return null;
    }
    final value = calculateBmi(weightKg: weightKg, heightCm: heightCm);
    final category = switch (value) {
      < 18.5 => 'Bajo peso',
      >= 18.5 && < 25 => 'Rango habitual',
      >= 25 && < 30 => 'Sobrepeso',
      _ => 'Obesidad',
    };
    return BmiResult(
      value: value,
      category: category,
      note:
          'El IMC es una referencia poblacional para adultos; no diagnostica salud ni grasa corporal.',
    );
  }
}
