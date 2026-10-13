import 'package:flutter_test/flutter_test.dart';
import 'package:retofit30/shared/services/body_metrics_service.dart';

void main() {
  group('BodyMetricsService', () {
    const service = BodyMetricsService();

    test('calcula IMC con kg/m2', () {
      final bmi = service.calculateBmi(weightKg: 70, heightCm: 175);
      expect(bmi, closeTo(22.86, 0.01));
    });

    test('no interpreta IMC adulto para menores', () {
      final result = service.evaluateAdultBmi(
        age: 16,
        weightKg: 60,
        heightCm: 170,
      );
      expect(result, isNull);
    });
  });
}
