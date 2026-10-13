import 'body_zone.dart';
import 'user_profile.dart';

enum ExerciseDifficulty { beginner, intermediate, advanced }

extension ExerciseDifficultyLabels on ExerciseDifficulty {
  String get label => switch (this) {
        ExerciseDifficulty.beginner => 'Principiante',
        ExerciseDifficulty.intermediate => 'Intermedio',
        ExerciseDifficulty.advanced => 'Avanzado',
      };
}

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.primaryZones,
    required this.secondaryZones,
    required this.targetMuscles,
    required this.secondaryMuscles,
    required this.equipment,
    required this.difficulty,
    required this.instructions,
    required this.commonMistakes,
    required this.safetyTips,
    required this.source,
    this.gifUrl,
    this.imageUrl,
  });

  final String id;
  final String name;
  final List<BodyZone> primaryZones;
  final List<BodyZone> secondaryZones;
  final List<String> targetMuscles;
  final List<String> secondaryMuscles;
  final List<String> equipment;
  final ExerciseDifficulty difficulty;
  final List<String> instructions;
  final List<String> commonMistakes;
  final List<String> safetyTips;
  final String source;
  final String? gifUrl;
  final String? imageUrl;

  bool isCompatibleWith({
    required List<BodyZone> zones,
    required List<String> availableEquipment,
    required TrainingExperience experience,
    required List<String> dislikedExercises,
  }) {
    final requestedZones = zones.isEmpty ? BodyZone.values : zones;
    final zoneMatch = primaryZones.any(requestedZones.contains) ||
        requestedZones.contains(BodyZone.fullBody);
    final hasEquipment = equipment.every(
      (item) => item == 'sin_equipo' || availableEquipment.contains(item),
    );
    final allowedByExperience = switch (experience) {
      TrainingExperience.beginner => difficulty == ExerciseDifficulty.beginner,
      TrainingExperience.intermediate =>
        difficulty != ExerciseDifficulty.advanced,
      TrainingExperience.advanced => true,
    };
    final disliked = dislikedExercises.any(
      (item) => name.toLowerCase().contains(item.toLowerCase().trim()),
    );
    return zoneMatch && hasEquipment && allowedByExperience && !disliked;
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'primaryZones': primaryZones.map((zone) => zone.id).toList(),
      'secondaryZones': secondaryZones.map((zone) => zone.id).toList(),
      'targetMuscles': targetMuscles,
      'secondaryMuscles': secondaryMuscles,
      'equipment': equipment,
      'difficulty': difficulty.name,
      'instructions': instructions,
      'commonMistakes': commonMistakes,
      'safetyTips': safetyTips,
      'source': source,
      'gifUrl': gifUrl,
      'imageUrl': imageUrl,
    };
  }

  factory Exercise.fromJson(Map<String, Object?> json) {
    return Exercise(
      id: json.stringValue('id'),
      name: json.stringValue('name'),
      primaryZones: json.objectList('primaryZones').map(bodyZoneFromId).toList(),
      secondaryZones:
          json.objectList('secondaryZones').map(bodyZoneFromId).toList(),
      targetMuscles: json.stringList('targetMuscles'),
      secondaryMuscles: json.stringList('secondaryMuscles'),
      equipment: json.stringList('equipment'),
      difficulty: enumByName(
        ExerciseDifficulty.values,
        json['difficulty'],
        ExerciseDifficulty.beginner,
      ),
      instructions: json.stringList('instructions'),
      commonMistakes: json.stringList('commonMistakes'),
      safetyTips: json.stringList('safetyTips'),
      source: json.stringValue('source', fallback: 'local'),
      gifUrl: json['gifUrl']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}

class PlannedSet {
  const PlannedSet({
    required this.repetitions,
    required this.restSeconds,
    this.loadKg,
    this.durationSeconds,
  });

  final int repetitions;
  final int restSeconds;
  final double? loadKg;
  final int? durationSeconds;

  Map<String, Object?> toJson() {
    return {
      'repetitions': repetitions,
      'restSeconds': restSeconds,
      'loadKg': loadKg,
      'durationSeconds': durationSeconds,
    };
  }

  factory PlannedSet.fromJson(Map<String, Object?> json) {
    return PlannedSet(
      repetitions: json.intValue('repetitions'),
      restSeconds: json.intValue('restSeconds', fallback: 60),
      loadKg: json.optionalDouble('loadKg'),
      durationSeconds: json.intValue('durationSeconds') == 0
          ? null
          : json.intValue('durationSeconds'),
    );
  }
}

class CompletedSet {
  const CompletedSet({
    required this.repetitions,
    required this.completed,
    this.loadKg,
    this.durationSeconds,
    this.notes = '',
  });

  final int repetitions;
  final double? loadKg;
  final int? durationSeconds;
  final bool completed;
  final String notes;

  double get volumeKg => (loadKg ?? 0) * repetitions;

  Map<String, Object?> toJson() {
    return {
      'repetitions': repetitions,
      'loadKg': loadKg,
      'durationSeconds': durationSeconds,
      'completed': completed,
      'notes': notes,
    };
  }

  factory CompletedSet.fromJson(Map<String, Object?> json) {
    return CompletedSet(
      repetitions: json.intValue('repetitions'),
      loadKg: json.optionalDouble('loadKg'),
      durationSeconds: json.intValue('durationSeconds') == 0
          ? null
          : json.intValue('durationSeconds'),
      completed: json['completed'] == true,
      notes: json.stringValue('notes'),
    );
  }
}

class WorkoutExercisePlan {
  const WorkoutExercisePlan({
    required this.exercise,
    required this.phase,
    required this.plannedSets,
    this.completedSets = const [],
    this.userNotes = '',
  });

  final Exercise exercise;
  final String phase;
  final List<PlannedSet> plannedSets;
  final List<CompletedSet> completedSets;
  final String userNotes;

  int get plannedRepetitions =>
      plannedSets.fold(0, (total, set) => total + set.repetitions);

  int get completedRepetitions => completedSets
      .where((set) => set.completed)
      .fold(0, (total, set) => total + set.repetitions);

  double get completedVolumeKg => completedSets
      .where((set) => set.completed)
      .fold(0, (total, set) => total + set.volumeKg);

  WorkoutExercisePlan copyWith({
    Exercise? exercise,
    String? phase,
    List<PlannedSet>? plannedSets,
    List<CompletedSet>? completedSets,
    String? userNotes,
  }) {
    return WorkoutExercisePlan(
      exercise: exercise ?? this.exercise,
      phase: phase ?? this.phase,
      plannedSets: plannedSets ?? this.plannedSets,
      completedSets: completedSets ?? this.completedSets,
      userNotes: userNotes ?? this.userNotes,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'exercise': exercise.toJson(),
      'phase': phase,
      'plannedSets': plannedSets.map((set) => set.toJson()).toList(),
      'completedSets': completedSets.map((set) => set.toJson()).toList(),
      'userNotes': userNotes,
    };
  }

  factory WorkoutExercisePlan.fromJson(Map<String, Object?> json) {
    return WorkoutExercisePlan(
      exercise: Exercise.fromJson(
        Map<String, Object?>.from(json['exercise'] as Map),
      ),
      phase: json.stringValue('phase', fallback: 'principal'),
      plannedSets: json
          .objectList('plannedSets')
          .whereType<Map>()
          .map((item) => PlannedSet.fromJson(Map<String, Object?>.from(item)))
          .toList(),
      completedSets: json
          .objectList('completedSets')
          .whereType<Map>()
          .map((item) => CompletedSet.fromJson(Map<String, Object?>.from(item)))
          .toList(),
      userNotes: json.stringValue('userNotes'),
    );
  }
}
