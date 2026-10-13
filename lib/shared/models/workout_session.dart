import '../../core/utils/date_utils.dart';
import 'body_zone.dart';
import 'exercise.dart';
import 'user_profile.dart';

enum WorkoutStatus { planned, started, completed, cancelled, missed }

enum WorkoutType { strength, cardio, mobility, mixed, rest }

extension WorkoutStatusLabels on WorkoutStatus {
  String get label => switch (this) {
        WorkoutStatus.planned => 'Planificada',
        WorkoutStatus.started => 'Iniciada',
        WorkoutStatus.completed => 'Completada',
        WorkoutStatus.cancelled => 'Cancelada',
        WorkoutStatus.missed => 'No realizada',
      };
}

extension WorkoutTypeLabels on WorkoutType {
  String get label => switch (this) {
        WorkoutType.strength => 'Fuerza',
        WorkoutType.cardio => 'Cardio',
        WorkoutType.mobility => 'Movilidad',
        WorkoutType.mixed => 'Mixta',
        WorkoutType.rest => 'Descanso',
      };
}

class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.name,
    required this.plannedAt,
    required this.type,
    required this.goal,
    required this.intensity,
    required this.difficultyLabel,
    required this.plannedDurationMinutes,
    required this.status,
    required this.primaryZones,
    required this.secondaryZones,
    required this.exercises,
    this.startedAt,
    this.completedAt,
    this.actualDurationMinutes = 0,
    this.notes = '',
    this.changeLog = const [],
  });

  final String id;
  final String name;
  final DateTime plannedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final WorkoutType type;
  final TrainingGoal goal;
  final SessionIntensity intensity;
  final String difficultyLabel;
  final int plannedDurationMinutes;
  final int actualDurationMinutes;
  final WorkoutStatus status;
  final List<BodyZone> primaryZones;
  final List<BodyZone> secondaryZones;
  final List<WorkoutExercisePlan> exercises;
  final String notes;
  final List<String> changeLog;

  bool get isCompleted => status == WorkoutStatus.completed;

  int get completedSets => exercises.fold(
        0,
        (total, exercise) =>
            total + exercise.completedSets.where((set) => set.completed).length,
      );

  int get completedRepetitions => exercises.fold(
        0,
        (total, exercise) => total + exercise.completedRepetitions,
      );

  double get completedVolumeKg => exercises.fold(
        0,
        (total, exercise) => total + exercise.completedVolumeKg,
      );

  WorkoutSession copyWith({
    String? id,
    String? name,
    DateTime? plannedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    WorkoutType? type,
    TrainingGoal? goal,
    SessionIntensity? intensity,
    String? difficultyLabel,
    int? plannedDurationMinutes,
    int? actualDurationMinutes,
    WorkoutStatus? status,
    List<BodyZone>? primaryZones,
    List<BodyZone>? secondaryZones,
    List<WorkoutExercisePlan>? exercises,
    String? notes,
    List<String>? changeLog,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      name: name ?? this.name,
      plannedAt: plannedAt ?? this.plannedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      type: type ?? this.type,
      goal: goal ?? this.goal,
      intensity: intensity ?? this.intensity,
      difficultyLabel: difficultyLabel ?? this.difficultyLabel,
      plannedDurationMinutes:
          plannedDurationMinutes ?? this.plannedDurationMinutes,
      actualDurationMinutes:
          actualDurationMinutes ?? this.actualDurationMinutes,
      status: status ?? this.status,
      primaryZones: primaryZones ?? this.primaryZones,
      secondaryZones: secondaryZones ?? this.secondaryZones,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
      changeLog: changeLog ?? this.changeLog,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'plannedAt': toIsoDateTime(plannedAt),
      'startedAt': startedAt == null ? null : toIsoDateTime(startedAt!),
      'completedAt': completedAt == null ? null : toIsoDateTime(completedAt!),
      'type': type.name,
      'goal': goal.name,
      'intensity': intensity.name,
      'difficultyLabel': difficultyLabel,
      'plannedDurationMinutes': plannedDurationMinutes,
      'actualDurationMinutes': actualDurationMinutes,
      'status': status.name,
      'primaryZones': primaryZones.map((zone) => zone.id).toList(),
      'secondaryZones': secondaryZones.map((zone) => zone.id).toList(),
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
      'notes': notes,
      'changeLog': changeLog,
    };
  }

  factory WorkoutSession.fromJson(Map<String, Object?> json) {
    return WorkoutSession(
      id: json.stringValue('id'),
      name: json.stringValue('name'),
      plannedAt: parseDateTime(json['plannedAt']) ?? DateTime.now(),
      startedAt: parseDateTime(json['startedAt']),
      completedAt: parseDateTime(json['completedAt']),
      type: enumByName(WorkoutType.values, json['type'], WorkoutType.mixed),
      goal: enumByName(TrainingGoal.values, json['goal'], TrainingGoal.habit),
      intensity: enumByName(
        SessionIntensity.values,
        json['intensity'],
        SessionIntensity.moderate,
      ),
      difficultyLabel: json.stringValue('difficultyLabel'),
      plannedDurationMinutes:
          json.intValue('plannedDurationMinutes', fallback: 30),
      actualDurationMinutes: json.intValue('actualDurationMinutes'),
      status: enumByName(
        WorkoutStatus.values,
        json['status'],
        WorkoutStatus.planned,
      ),
      primaryZones: json.objectList('primaryZones').map(bodyZoneFromId).toList(),
      secondaryZones:
          json.objectList('secondaryZones').map(bodyZoneFromId).toList(),
      exercises: json
          .objectList('exercises')
          .whereType<Map>()
          .map(
            (item) => WorkoutExercisePlan.fromJson(
              Map<String, Object?>.from(item),
            ),
          )
          .toList(),
      notes: json.stringValue('notes'),
      changeLog: json.stringList('changeLog'),
    );
  }
}
