import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../core/storage/local_storage_service.dart';
import '../core/utils/date_utils.dart';
import '../features/challenge/domain/challenge_service.dart';
import '../features/workouts/data/local_exercise_catalog.dart';
import '../features/workouts/domain/workout_generator.dart';
import '../shared/models/body_zone.dart';
import '../shared/models/exercise.dart';
import '../shared/models/nutrition.dart';
import '../shared/models/user_profile.dart';
import '../shared/models/workout_session.dart';
import '../shared/services/body_metrics_service.dart';
import '../shared/services/nutrition_calculator.dart';

class RetoFitState extends ChangeNotifier {
  RetoFitState({
    required LocalStorageService storage,
    required RetoFitSnapshot snapshot,
  })  : _storage = storage,
        _snapshot = snapshot;

  final LocalStorageService _storage;
  final Uuid _uuid = const Uuid();
  final BodyMetricsService bodyMetrics = const BodyMetricsService();
  final NutritionCalculator nutritionCalculator = const NutritionCalculator();
  final ChallengeService challengeService = const ChallengeService();
  final WorkoutGenerator workoutGenerator = WorkoutGenerator(
    catalog: const LocalExerciseCatalog().all(),
  );

  RetoFitSnapshot _snapshot;

  UserProfile? get profile => _snapshot.profile;
  UserProfile? get draftProfile => _snapshot.draftProfile;
  List<WorkoutSession> get sessions => List.unmodifiable(_snapshot.sessions);
  List<MealEntry> get meals => List.unmodifiable(_snapshot.meals);
  List<HydrationLog> get hydration => List.unmodifiable(_snapshot.hydration);
  List<BodyMeasurement> get measurements =>
      List.unmodifiable(_snapshot.measurements);

  bool get hasProfile => profile != null;

  WorkoutSession? get todayWorkout {
    final today = DateTime.now();
    final todays = sessions
        .where((session) => isSameCalendarDay(session.plannedAt, today))
        .toList()
      ..sort((a, b) => a.plannedAt.compareTo(b.plannedAt));
    return todays.isEmpty ? null : todays.first;
  }

  List<MealEntry> get todayMeals {
    final today = DateTime.now();
    return meals.where((meal) => isSameCalendarDay(meal.date, today)).toList();
  }

  int get todayWaterMl {
    final today = DateTime.now();
    return hydration
        .where((entry) => isSameCalendarDay(entry.date, today))
        .fold(0, (total, entry) => total + entry.milliliters);
  }

  BodyMeasurement? get latestMeasurement {
    if (measurements.isEmpty) {
      return null;
    }
    final sorted = [...measurements]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.first;
  }

  Nutrients get todayConsumedNutrients {
    return todayMeals.fold(
      const Nutrients(),
      (total, meal) => total + meal.consumedNutrients,
    );
  }

  ChallengeStats? get challengeStats {
    final currentProfile = profile;
    if (currentProfile == null) {
      return null;
    }
    return challengeService.calculate(currentProfile, sessions);
  }

  List<Exercise> get exerciseCatalog => const LocalExerciseCatalog().all();

  Future<void> saveDraft(UserProfile draft) async {
    _snapshot = _snapshot.copyWith(draftProfile: draft);
    await _persist();
  }

  Future<void> saveProfile(UserProfile value) async {
    final now = DateTime.now();
    final profileWithDates = value.copyWith(
      updatedAt: now,
      createdAt: value.createdAt,
      challengeStartedAt: value.challengeStartedAt,
    );
    final measurements = [
      ..._snapshot.measurements,
      if (_snapshot.measurements.isEmpty)
        BodyMeasurement(
          id: _uuid.v4(),
          date: now,
          weightKg: profileWithDates.weightKg,
          notes: 'Medición inicial',
        ),
    ];
    _snapshot = _snapshot.copyWith(
      profile: profileWithDates,
      draftProfile: profileWithDates,
      measurements: measurements,
    );
    if (todayWorkout == null) {
      final result = workoutGenerator.generate(
        profile: profileWithDates,
        plannedAt: now,
        history: sessions,
      );
      if (result.session != null) {
        _snapshot = _snapshot.copyWith(
          sessions: [..._snapshot.sessions, result.session!],
        );
      }
    }
    await _persist();
  }

  Future<WorkoutGenerationResult> generateWorkout({
    List<BodyZone>? zones,
    SessionIntensity? intensity,
  }) async {
    final currentProfile = profile;
    if (currentProfile == null) {
      return const WorkoutGenerationResult(
        session: null,
        warning: 'Primero completa tu perfil.',
      );
    }
    final result = workoutGenerator.generate(
      profile: currentProfile,
      plannedAt: DateTime.now(),
      requestedZones: zones,
      intensity: intensity,
      history: sessions,
    );
    if (result.session != null) {
      _snapshot = _snapshot.copyWith(
        sessions: [..._snapshot.sessions, result.session!],
      );
      await _persist();
    }
    return result;
  }

  Future<void> startSession(String id) async {
    final now = DateTime.now();
    _replaceSession(
      id,
      (session) => session.copyWith(
        startedAt: now,
        status: WorkoutStatus.started,
      ),
    );
    await _persist();
  }

  Future<void> completeSessionWithDefaults(String id) async {
    final now = DateTime.now();
    _replaceSession(id, (session) {
      final startedAt = session.startedAt ?? now;
      final exercises = session.exercises.map((plan) {
        if (plan.completedSets.isNotEmpty) {
          return plan;
        }
        return plan.copyWith(
          completedSets: plan.plannedSets
              .map(
                (set) => CompletedSet(
                  repetitions: set.repetitions,
                  loadKg: set.loadKg,
                  durationSeconds: set.durationSeconds,
                  completed: true,
                ),
              )
              .toList(),
        );
      }).toList();
      final duration = now.difference(startedAt).inMinutes.clamp(
            1,
            session.plannedDurationMinutes,
          ).toInt();
      return session.copyWith(
        startedAt: startedAt,
        completedAt: now,
        actualDurationMinutes: duration,
        status: WorkoutStatus.completed,
        exercises: exercises,
      );
    });
    await _persist();
  }

  Future<void> addWater(int milliliters) async {
    if (milliliters <= 0) {
      return;
    }
    _snapshot = _snapshot.copyWith(
      hydration: [
        ...hydration,
        HydrationLog(
          id: _uuid.v4(),
          date: DateTime.now(),
          milliliters: milliliters,
        ),
      ],
    );
    await _persist();
  }

  Future<void> addMeal({
    required String name,
    required MealType type,
    required double amount,
    required Nutrients nutrientsPerReference,
    String referenceUnit = 'g',
    double referenceAmount = 100,
  }) async {
    if (name.trim().isEmpty || amount <= 0) {
      return;
    }
    final food = FoodItem(
      id: _uuid.v4(),
      name: name.trim(),
      referenceAmount: referenceAmount,
      referenceUnit: referenceUnit,
      nutrients: nutrientsPerReference,
      source: 'manual',
      dataWarnings: const ['Registro manual; revisa cantidad y nutrientes.'],
    );
    _snapshot = _snapshot.copyWith(
      meals: [
        ...meals,
        MealEntry(
          id: _uuid.v4(),
          date: DateTime.now(),
          type: type,
          food: food,
          amount: amount,
          unit: referenceUnit,
        ),
      ],
    );
    await _persist();
  }

  Future<void> addMeasurement({
    required double weightKg,
    double? waistCm,
    double? hipCm,
    String notes = '',
  }) async {
    if (weightKg <= 0) {
      return;
    }
    _snapshot = _snapshot.copyWith(
      measurements: [
        ...measurements,
        BodyMeasurement(
          id: _uuid.v4(),
          date: DateTime.now(),
          weightKg: weightKg,
          waistCm: waistCm,
          hipCm: hipCm,
          notes: notes,
        ),
      ],
    );
    final currentProfile = profile;
    if (currentProfile != null) {
      _snapshot = _snapshot.copyWith(
        profile: currentProfile.copyWith(
          weightKg: weightKg,
          updatedAt: DateTime.now(),
        ),
      );
    }
    await _persist();
  }

  Future<void> clearAllData() async {
    await _storage.clear();
    _snapshot = RetoFitSnapshot.empty();
    notifyListeners();
  }

  void _replaceSession(
    String id,
    WorkoutSession Function(WorkoutSession session) update,
  ) {
    _snapshot = _snapshot.copyWith(
      sessions: sessions
          .map((session) => session.id == id ? update(session) : session)
          .toList(),
    );
  }

  Future<void> _persist() async {
    await _storage.save(_snapshot);
    notifyListeners();
  }
}

class RetoFitScope extends InheritedNotifier<RetoFitState> {
  const RetoFitScope({
    required RetoFitState state,
    required super.child,
    super.key,
  }) : super(notifier: state);

  static RetoFitState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RetoFitScope>();
    assert(scope != null, 'RetoFitScope no encontrado en el arbol.');
    return scope!.notifier!;
  }
}
