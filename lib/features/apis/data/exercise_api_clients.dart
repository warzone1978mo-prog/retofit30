import '../../../core/config/api_config.dart';
import '../../../core/networking/http_json_client.dart';
import '../../../shared/models/body_zone.dart';
import '../../../shared/models/exercise.dart';

class ExerciseDbApiClient {
  const ExerciseDbApiClient({this.http = const HttpJsonClient()});

  final HttpJsonClient http;

  Future<List<Exercise>> fetchExercises() async {
    final json = await http.getJson(Uri.parse('${ApiConfig.exerciseDbBase}/exercises'));
    if (json is! List) {
      throw const ApiException('ExerciseDB devolvio una estructura inesperada.');
    }
    return json
        .whereType<Map>()
        .map((item) => _exerciseDbToExercise(Map<String, Object?>.from(item)))
        .toList();
  }

  Exercise _exerciseDbToExercise(Map<String, Object?> json) {
    final bodyParts = _stringList(json['bodyParts']);
    final targetMuscles = _stringList(json['targetMuscles']);
    final equipment = _stringList(json['equipments']).map(_normalizeEquipment).toList();
    return Exercise(
      id: json['exerciseId']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Ejercicio sin nombre',
      primaryZones: bodyParts.map(_zoneFromProvider).toSet().toList(),
      secondaryZones: targetMuscles.map(_zoneFromProvider).toSet().toList(),
      targetMuscles: targetMuscles,
      secondaryMuscles: _stringList(json['secondaryMuscles']),
      equipment: equipment.isEmpty ? ['sin_equipo'] : equipment,
      difficulty: ExerciseDifficulty.intermediate,
      instructions: _stringList(json['instructions']),
      commonMistakes: const ['Revisa tecnica y rango de movimiento.'],
      safetyTips: const [
        'Usa el GIF solo como guia visual; adapta el ejercicio a tu capacidad.',
      ],
      source: 'ExerciseDB OSS',
      gifUrl: json['gifUrl']?.toString(),
    );
  }
}

class WgerApiClient {
  const WgerApiClient({this.http = const HttpJsonClient()});

  final HttpJsonClient http;

  Future<Object?> fetchExerciseInfo({int limit = 20}) {
    final uri = Uri.parse('${ApiConfig.wgerBase}/exerciseinfo/').replace(
      queryParameters: {'limit': '$limit'},
    );
    return http.getJson(uri, headers: const {'Accept': 'application/json'});
  }
}

List<String> _stringList(Object? value) {
  if (value is List) {
    return value.map((item) => item.toString()).where((item) => item.isNotEmpty).toList();
  }
  if (value == null) {
    return const [];
  }
  return [value.toString()];
}

String _normalizeEquipment(String value) {
  final normalized = value.toLowerCase().trim();
  if (normalized.contains('dumbbell')) {
    return 'mancuernas';
  }
  if (normalized.contains('barbell')) {
    return 'barra_discos';
  }
  if (normalized.contains('band')) {
    return 'bandas_resistencia';
  }
  if (normalized.contains('cable')) {
    return 'poleas';
  }
  if (normalized.contains('machine')) {
    return 'maquinas';
  }
  if (normalized.contains('body weight') || normalized.contains('bodyweight')) {
    return 'sin_equipo';
  }
  return normalized.replaceAll(' ', '_');
}

BodyZone _zoneFromProvider(String value) {
  final normalized = value.toLowerCase();
  if (normalized.contains('chest') || normalized.contains('pector')) {
    return BodyZone.chest;
  }
  if (normalized.contains('back') || normalized.contains('lat')) {
    return BodyZone.back;
  }
  if (normalized.contains('shoulder') || normalized.contains('delt')) {
    return BodyZone.shoulders;
  }
  if (normalized.contains('biceps')) {
    return BodyZone.biceps;
  }
  if (normalized.contains('triceps')) {
    return BodyZone.triceps;
  }
  if (normalized.contains('forearm')) {
    return BodyZone.forearms;
  }
  if (normalized.contains('waist') || normalized.contains('abs')) {
    return BodyZone.core;
  }
  if (normalized.contains('glute')) {
    return BodyZone.glutes;
  }
  if (normalized.contains('quad') || normalized.contains('upper legs')) {
    return BodyZone.quads;
  }
  if (normalized.contains('hamstring')) {
    return BodyZone.hamstrings;
  }
  if (normalized.contains('calves') || normalized.contains('lower legs')) {
    return BodyZone.calves;
  }
  if (normalized.contains('cardio')) {
    return BodyZone.cardio;
  }
  return BodyZone.fullBody;
}
