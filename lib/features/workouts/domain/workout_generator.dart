import 'package:uuid/uuid.dart';

import '../../../shared/models/body_zone.dart';
import '../../../shared/models/exercise.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/models/workout_session.dart';

class WorkoutGenerationResult {
  const WorkoutGenerationResult({
    required this.session,
    this.warning,
  });

  final WorkoutSession? session;
  final String? warning;

  bool get hasSession => session != null;
}

class WorkoutGenerator {
  const WorkoutGenerator({
    required List<Exercise> catalog,
    Uuid? uuid,
  })  : _catalog = catalog,
        _uuid = uuid ?? const Uuid();

  final List<Exercise> _catalog;
  final Uuid _uuid;

  WorkoutGenerationResult generate({
    required UserProfile profile,
    required DateTime plannedAt,
    List<BodyZone>? requestedZones,
    SessionIntensity? intensity,
    List<WorkoutSession> history = const [],
  }) {
    final zones = requestedZones?.isEmpty == false
        ? requestedZones!
        : profile.desiredZones.isEmpty
            ? [BodyZone.fullBody]
            : profile.desiredZones;
    final selectedIntensity = _capIntensity(
      intensity ?? profile.intensityPreference,
      profile.experience,
    );

    final recoveredZones = _zonesWithRecentLoad(history, plannedAt);
    final trainingZones = zones
        .where((zone) => !recoveredZones.contains(zone))
        .toList(growable: false);
    final effectiveZones = trainingZones.isEmpty ? zones : trainingZones;

    final compatible = _catalog
        .where(
          (exercise) => exercise.isCompatibleWith(
            zones: effectiveZones,
            availableEquipment: profile.equipment,
            experience: profile.experience,
            dislikedExercises: profile.dislikedExercises,
          ),
        )
        .toList();

    final minimumExercises = profile.minutesPerSession >= 40 ? 4 : 3;
    if (compatible.length < minimumExercises) {
      return WorkoutGenerationResult(
        session: null,
        warning:
            'No hay suficientes ejercicios compatibles con tu equipo, zonas y experiencia. Ajusta filtros o agrega equipo.',
      );
    }

    final selected = _balancedSelection(compatible, minimumExercises + 1);
    final warmup = _warmupFor(effectiveZones);
    final cooldown = _cooldownFor(effectiveZones);
    final mainPlans = selected.take(minimumExercises).map(
          (exercise) => WorkoutExercisePlan(
            exercise: exercise,
            phase: 'principal',
            plannedSets: _setsFor(profile.goal, selectedIntensity, exercise),
          ),
        );

    final plans = [
      warmup,
      ...mainPlans,
      cooldown,
    ];

    final allPrimary = <BodyZone>{
      for (final plan in plans) ...plan.exercise.primaryZones,
    }.toList();
    final allSecondary = <BodyZone>{
      for (final plan in plans) ...plan.exercise.secondaryZones,
    }.where((zone) => !allPrimary.contains(zone)).toList();

    return WorkoutGenerationResult(
      session: WorkoutSession(
        id: _uuid.v4(),
        name: _nameFor(profile.goal, effectiveZones),
        plannedAt: plannedAt,
        type: _typeFor(effectiveZones, profile.goal),
        goal: profile.goal,
        intensity: selectedIntensity,
        difficultyLabel: _difficultyLabel(profile.experience, selectedIntensity),
        plannedDurationMinutes: profile.minutesPerSession,
        status: WorkoutStatus.planned,
        primaryZones: allPrimary,
        secondaryZones: allSecondary,
        exercises: plans,
        changeLog: [
          'Rutina generada con ${compatible.length} ejercicios compatibles.',
        ],
      ),
      warning: selectedIntensity != (intensity ?? profile.intensityPreference)
          ? 'La intensidad avanzada se ajusto por compatibilidad con la experiencia declarada.'
          : null,
    );
  }

  SessionIntensity _capIntensity(
    SessionIntensity requested,
    TrainingExperience experience,
  ) {
    if (requested == SessionIntensity.advanced &&
        experience != TrainingExperience.advanced) {
      return SessionIntensity.high;
    }
    return requested;
  }

  Set<BodyZone> _zonesWithRecentLoad(
    List<WorkoutSession> history,
    DateTime plannedAt,
  ) {
    final recent = history.where((session) {
      if (!session.isCompleted || session.completedAt == null) {
        return false;
      }
      final days = plannedAt.difference(session.completedAt!).inDays;
      return days >= 0 && days < 2;
    });
    return {
      for (final session in recent) ...session.primaryZones,
    };
  }

  List<Exercise> _balancedSelection(List<Exercise> source, int count) {
    final selected = <Exercise>[];
    final usedMovementNames = <String>{};
    for (final exercise in source) {
      final movementKey = exercise.name.split(' ').take(2).join(' ');
      if (usedMovementNames.add(movementKey)) {
        selected.add(exercise);
      }
      if (selected.length >= count) {
        break;
      }
    }
    return selected;
  }

  WorkoutExercisePlan _warmupFor(List<BodyZone> zones) {
    final exercise = zones.contains(BodyZone.cardio)
        ? _catalog.firstWhere((item) => item.id == 'local_treadmill_walk')
        : _catalog.firstWhere((item) => item.id == 'local_mobility_flow');
    return WorkoutExercisePlan(
      exercise: exercise,
      phase: 'calentamiento',
      plannedSets: const [
        PlannedSet(repetitions: 1, durationSeconds: 300, restSeconds: 30),
      ],
    );
  }

  WorkoutExercisePlan _cooldownFor(List<BodyZone> zones) {
    final exercise = _catalog.firstWhere((item) => item.id == 'local_mobility_flow');
    return WorkoutExercisePlan(
      exercise: exercise,
      phase: zones.contains(BodyZone.mobility) ? 'principal' : 'vuelta_calma',
      plannedSets: const [
        PlannedSet(repetitions: 1, durationSeconds: 240, restSeconds: 0),
      ],
    );
  }

  List<PlannedSet> _setsFor(
    TrainingGoal goal,
    SessionIntensity intensity,
    Exercise exercise,
  ) {
    final isTimed = exercise.primaryZones.contains(BodyZone.cardio) ||
        exercise.primaryZones.contains(BodyZone.mobility);
    if (isTimed) {
      final seconds = switch (intensity) {
        SessionIntensity.low => 300,
        SessionIntensity.moderate => 480,
        SessionIntensity.high => 600,
        SessionIntensity.advanced => 720,
      };
      return [PlannedSet(repetitions: 1, durationSeconds: seconds, restSeconds: 60)];
    }

    final reps = switch (goal) {
      TrainingGoal.strength => 6,
      TrainingGoal.hypertrophy => 10,
      TrainingGoal.muscularEndurance => 15,
      _ => 12,
    };
    final sets = switch (intensity) {
      SessionIntensity.low => 2,
      SessionIntensity.moderate => 3,
      SessionIntensity.high => 4,
      SessionIntensity.advanced => 5,
    };
    final rest = switch (goal) {
      TrainingGoal.strength => 120,
      TrainingGoal.hypertrophy => 75,
      TrainingGoal.muscularEndurance => 45,
      _ => 60,
    };
    return List.generate(
      sets,
      (_) => PlannedSet(repetitions: reps, restSeconds: rest),
    );
  }

  String _nameFor(TrainingGoal goal, List<BodyZone> zones) {
    final zoneName =
        zones.contains(BodyZone.fullBody) ? 'cuerpo completo' : zones.first.label;
    return switch (goal) {
      TrainingGoal.strength => 'Fuerza: $zoneName',
      TrainingGoal.hypertrophy => 'Hipertrofia: $zoneName',
      TrainingGoal.cardiovascular => 'Cardio progresivo',
      TrainingGoal.mobility => 'Movilidad guiada',
      _ => 'Rutina de $zoneName',
    };
  }

  WorkoutType _typeFor(List<BodyZone> zones, TrainingGoal goal) {
    if (zones.contains(BodyZone.cardio) ||
        goal == TrainingGoal.cardiovascular ||
        goal == TrainingGoal.fatLoss) {
      return WorkoutType.cardio;
    }
    if (zones.contains(BodyZone.mobility) || goal == TrainingGoal.mobility) {
      return WorkoutType.mobility;
    }
    if (goal == TrainingGoal.strength || goal == TrainingGoal.hypertrophy) {
      return WorkoutType.strength;
    }
    return WorkoutType.mixed;
  }

  String _difficultyLabel(
    TrainingExperience experience,
    SessionIntensity intensity,
  ) {
    return '${experience.label} / esfuerzo ${intensity.label.toLowerCase()}';
  }
}
