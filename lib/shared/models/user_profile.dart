import '../../core/utils/date_utils.dart';
import 'body_zone.dart';

enum TrainingGoal {
  hypertrophy,
  strength,
  fatLoss,
  cardiovascular,
  muscularEndurance,
  mobility,
  maintenance,
  habit,
}

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

enum TrainingExperience { beginner, intermediate, advanced }

enum TrainingPlace { home, gym }

enum SessionIntensity { low, moderate, high, advanced }

enum FeedingStyle { omnivore, vegetarian, vegan, pescatarian, custom }

enum BiologicalSex { unspecified, female, male }

extension TrainingGoalLabels on TrainingGoal {
  String get label => switch (this) {
        TrainingGoal.hypertrophy => 'Ganar masa muscular',
        TrainingGoal.strength => 'Mejorar fuerza',
        TrainingGoal.fatLoss => 'Reducir grasa corporal',
        TrainingGoal.cardiovascular => 'Mejorar condición cardiovascular',
        TrainingGoal.muscularEndurance => 'Mejorar resistencia muscular',
        TrainingGoal.mobility => 'Mejorar movilidad y flexibilidad',
        TrainingGoal.maintenance => 'Mantener la condición física',
        TrainingGoal.habit => 'Crear un hábito de ejercicio',
      };
}

extension ActivityLevelLabels on ActivityLevel {
  String get label => switch (this) {
        ActivityLevel.sedentary => 'Sedentario',
        ActivityLevel.light => 'Ligero',
        ActivityLevel.moderate => 'Moderado',
        ActivityLevel.active => 'Activo',
        ActivityLevel.veryActive => 'Muy activo',
      };

  double get multiplier => switch (this) {
        ActivityLevel.sedentary => 1.2,
        ActivityLevel.light => 1.375,
        ActivityLevel.moderate => 1.55,
        ActivityLevel.active => 1.725,
        ActivityLevel.veryActive => 1.9,
      };
}

extension TrainingExperienceLabels on TrainingExperience {
  String get label => switch (this) {
        TrainingExperience.beginner => 'Principiante',
        TrainingExperience.intermediate => 'Intermedio',
        TrainingExperience.advanced => 'Avanzado',
      };
}

extension SessionIntensityLabels on SessionIntensity {
  String get label => switch (this) {
        SessionIntensity.low => 'Bajo',
        SessionIntensity.moderate => 'Moderado',
        SessionIntensity.high => 'Alto',
        SessionIntensity.advanced => 'Avanzado',
      };
}

extension FeedingStyleLabels on FeedingStyle {
  String get label => switch (this) {
        FeedingStyle.omnivore => 'Omnívora',
        FeedingStyle.vegetarian => 'Vegetariana',
        FeedingStyle.vegan => 'Vegana',
        FeedingStyle.pescatarian => 'Pescetariana',
        FeedingStyle.custom => 'Otra',
      };
}

class UserProfile {
  const UserProfile({
    required this.alias,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.activityLevel,
    required this.experience,
    required this.trainingPlace,
    required this.equipment,
    required this.desiredZones,
    required this.daysPerWeek,
    required this.minutesPerSession,
    required this.intensityPreference,
    required this.feedingStyle,
    required this.mealsPerDay,
    required this.region,
    required this.sexForFormula,
    required this.createdAt,
    required this.updatedAt,
    required this.challengeStartedAt,
    this.targetWeightKg,
    this.dislikedExercises = const [],
    this.limitations = '',
    this.activitiesEnjoyed = const [],
    this.allergies = const [],
    this.intolerances = const [],
    this.avoidedFoods = const [],
    this.preferredFoods = const [],
    this.groceryBudget = '',
    this.cookingMinutes = 20,
    this.availableFoods = const [],
    this.medicalNotes = '',
  });

  final String alias;
  final int age;
  final double heightCm;
  final double weightKg;
  final double? targetWeightKg;
  final TrainingGoal goal;
  final ActivityLevel activityLevel;
  final TrainingExperience experience;
  final TrainingPlace trainingPlace;
  final List<String> equipment;
  final List<BodyZone> desiredZones;
  final int daysPerWeek;
  final int minutesPerSession;
  final SessionIntensity intensityPreference;
  final List<String> dislikedExercises;
  final String limitations;
  final List<String> activitiesEnjoyed;
  final FeedingStyle feedingStyle;
  final List<String> allergies;
  final List<String> intolerances;
  final List<String> avoidedFoods;
  final List<String> preferredFoods;
  final int mealsPerDay;
  final String groceryBudget;
  final int cookingMinutes;
  final List<String> availableFoods;
  final String region;
  final String medicalNotes;
  final BiologicalSex sexForFormula;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime challengeStartedAt;

  bool get isAdult => age >= 18;

  bool get hasSafetyFlags =>
      limitations.trim().isNotEmpty || medicalNotes.trim().isNotEmpty;

  UserProfile copyWith({
    String? alias,
    int? age,
    double? heightCm,
    double? weightKg,
    double? targetWeightKg,
    TrainingGoal? goal,
    ActivityLevel? activityLevel,
    TrainingExperience? experience,
    TrainingPlace? trainingPlace,
    List<String>? equipment,
    List<BodyZone>? desiredZones,
    int? daysPerWeek,
    int? minutesPerSession,
    SessionIntensity? intensityPreference,
    List<String>? dislikedExercises,
    String? limitations,
    List<String>? activitiesEnjoyed,
    FeedingStyle? feedingStyle,
    List<String>? allergies,
    List<String>? intolerances,
    List<String>? avoidedFoods,
    List<String>? preferredFoods,
    int? mealsPerDay,
    String? groceryBudget,
    int? cookingMinutes,
    List<String>? availableFoods,
    String? region,
    String? medicalNotes,
    BiologicalSex? sexForFormula,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? challengeStartedAt,
  }) {
    return UserProfile(
      alias: alias ?? this.alias,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      experience: experience ?? this.experience,
      trainingPlace: trainingPlace ?? this.trainingPlace,
      equipment: equipment ?? this.equipment,
      desiredZones: desiredZones ?? this.desiredZones,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      minutesPerSession: minutesPerSession ?? this.minutesPerSession,
      intensityPreference: intensityPreference ?? this.intensityPreference,
      dislikedExercises: dislikedExercises ?? this.dislikedExercises,
      limitations: limitations ?? this.limitations,
      activitiesEnjoyed: activitiesEnjoyed ?? this.activitiesEnjoyed,
      feedingStyle: feedingStyle ?? this.feedingStyle,
      allergies: allergies ?? this.allergies,
      intolerances: intolerances ?? this.intolerances,
      avoidedFoods: avoidedFoods ?? this.avoidedFoods,
      preferredFoods: preferredFoods ?? this.preferredFoods,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
      groceryBudget: groceryBudget ?? this.groceryBudget,
      cookingMinutes: cookingMinutes ?? this.cookingMinutes,
      availableFoods: availableFoods ?? this.availableFoods,
      region: region ?? this.region,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      sexForFormula: sexForFormula ?? this.sexForFormula,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      challengeStartedAt: challengeStartedAt ?? this.challengeStartedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'alias': alias,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'targetWeightKg': targetWeightKg,
      'goal': goal.name,
      'activityLevel': activityLevel.name,
      'experience': experience.name,
      'trainingPlace': trainingPlace.name,
      'equipment': equipment,
      'desiredZones': desiredZones.map((zone) => zone.id).toList(),
      'daysPerWeek': daysPerWeek,
      'minutesPerSession': minutesPerSession,
      'intensityPreference': intensityPreference.name,
      'dislikedExercises': dislikedExercises,
      'limitations': limitations,
      'activitiesEnjoyed': activitiesEnjoyed,
      'feedingStyle': feedingStyle.name,
      'allergies': allergies,
      'intolerances': intolerances,
      'avoidedFoods': avoidedFoods,
      'preferredFoods': preferredFoods,
      'mealsPerDay': mealsPerDay,
      'groceryBudget': groceryBudget,
      'cookingMinutes': cookingMinutes,
      'availableFoods': availableFoods,
      'region': region,
      'medicalNotes': medicalNotes,
      'sexForFormula': sexForFormula.name,
      'createdAt': toIsoDateTime(createdAt),
      'updatedAt': toIsoDateTime(updatedAt),
      'challengeStartedAt': toIsoDateTime(challengeStartedAt),
    };
  }

  factory UserProfile.fromJson(Map<String, Object?> json) {
    return UserProfile(
      alias: json.stringValue('alias', fallback: 'Atleta'),
      age: json.intValue('age', fallback: 18),
      heightCm: json.doubleValue('heightCm', fallback: 170),
      weightKg: json.doubleValue('weightKg', fallback: 70),
      targetWeightKg: json.optionalDouble('targetWeightKg'),
      goal: enumByName(TrainingGoal.values, json['goal'], TrainingGoal.habit),
      activityLevel: enumByName(
        ActivityLevel.values,
        json['activityLevel'],
        ActivityLevel.light,
      ),
      experience: enumByName(
        TrainingExperience.values,
        json['experience'],
        TrainingExperience.beginner,
      ),
      trainingPlace: enumByName(
        TrainingPlace.values,
        json['trainingPlace'],
        TrainingPlace.home,
      ),
      equipment: json.stringList('equipment'),
      desiredZones: json
          .objectList('desiredZones')
          .map(bodyZoneFromId)
          .toList(growable: false),
      daysPerWeek: json.intValue('daysPerWeek', fallback: 3),
      minutesPerSession: json.intValue('minutesPerSession', fallback: 30),
      intensityPreference: enumByName(
        SessionIntensity.values,
        json['intensityPreference'],
        SessionIntensity.moderate,
      ),
      dislikedExercises: json.stringList('dislikedExercises'),
      limitations: json.stringValue('limitations'),
      activitiesEnjoyed: json.stringList('activitiesEnjoyed'),
      feedingStyle: enumByName(
        FeedingStyle.values,
        json['feedingStyle'],
        FeedingStyle.omnivore,
      ),
      allergies: json.stringList('allergies'),
      intolerances: json.stringList('intolerances'),
      avoidedFoods: json.stringList('avoidedFoods'),
      preferredFoods: json.stringList('preferredFoods'),
      mealsPerDay: json.intValue('mealsPerDay', fallback: 3),
      groceryBudget: json.stringValue('groceryBudget'),
      cookingMinutes: json.intValue('cookingMinutes', fallback: 20),
      availableFoods: json.stringList('availableFoods'),
      region: json.stringValue('region', fallback: 'México'),
      medicalNotes: json.stringValue('medicalNotes'),
      sexForFormula: enumByName(
        BiologicalSex.values,
        json['sexForFormula'],
        BiologicalSex.unspecified,
      ),
      createdAt: parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDateTime(json['updatedAt']) ?? DateTime.now(),
      challengeStartedAt:
          parseDateTime(json['challengeStartedAt']) ?? DateTime.now(),
    );
  }
}

T enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  return values.firstWhere(
    (value) => value.name == name,
    orElse: () => fallback,
  );
}

extension JsonRead on Map<String, Object?> {
  String stringValue(String key, {String fallback = ''}) {
    final value = this[key];
    if (value == null) {
      return fallback;
    }
    return value.toString();
  }

  int intValue(String key, {int fallback = 0}) {
    final value = this[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double doubleValue(String key, {double fallback = 0}) {
    final value = this[key];
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double? optionalDouble(String key) {
    final value = this[key];
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  List<Object?> objectList(String key) {
    final value = this[key];
    if (value is List) {
      return value;
    }
    return const [];
  }

  List<String> stringList(String key) {
    return objectList(key).map((value) => value.toString()).toList();
  }
}
