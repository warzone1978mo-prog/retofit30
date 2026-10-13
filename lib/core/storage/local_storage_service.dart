import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/models/nutrition.dart';
import '../../shared/models/user_profile.dart';
import '../../shared/models/workout_session.dart';

class RetoFitSnapshot {
  const RetoFitSnapshot({
    required this.storageVersion,
    this.profile,
    this.draftProfile,
    this.sessions = const [],
    this.meals = const [],
    this.hydration = const [],
    this.measurements = const [],
  });

  final int storageVersion;
  final UserProfile? profile;
  final UserProfile? draftProfile;
  final List<WorkoutSession> sessions;
  final List<MealEntry> meals;
  final List<HydrationLog> hydration;
  final List<BodyMeasurement> measurements;

  RetoFitSnapshot copyWith({
    int? storageVersion,
    UserProfile? profile,
    UserProfile? draftProfile,
    List<WorkoutSession>? sessions,
    List<MealEntry>? meals,
    List<HydrationLog>? hydration,
    List<BodyMeasurement>? measurements,
  }) {
    return RetoFitSnapshot(
      storageVersion: storageVersion ?? this.storageVersion,
      profile: profile ?? this.profile,
      draftProfile: draftProfile ?? this.draftProfile,
      sessions: sessions ?? this.sessions,
      meals: meals ?? this.meals,
      hydration: hydration ?? this.hydration,
      measurements: measurements ?? this.measurements,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'storageVersion': storageVersion,
      'profile': profile?.toJson(),
      'draftProfile': draftProfile?.toJson(),
      'sessions': sessions.map((session) => session.toJson()).toList(),
      'meals': meals.map((meal) => meal.toJson()).toList(),
      'hydration': hydration.map((entry) => entry.toJson()).toList(),
      'measurements':
          measurements.map((measurement) => measurement.toJson()).toList(),
    };
  }

  factory RetoFitSnapshot.fromJson(Map<String, Object?> json) {
    return RetoFitSnapshot(
      storageVersion: json.intValue('storageVersion', fallback: 1),
      profile: json['profile'] is Map
          ? UserProfile.fromJson(Map<String, Object?>.from(json['profile'] as Map))
          : null,
      draftProfile: json['draftProfile'] is Map
          ? UserProfile.fromJson(
              Map<String, Object?>.from(json['draftProfile'] as Map),
            )
          : null,
      sessions: json
          .objectList('sessions')
          .whereType<Map>()
          .map((item) => WorkoutSession.fromJson(Map<String, Object?>.from(item)))
          .toList(),
      meals: json
          .objectList('meals')
          .whereType<Map>()
          .map((item) => MealEntry.fromJson(Map<String, Object?>.from(item)))
          .toList(),
      hydration: json
          .objectList('hydration')
          .whereType<Map>()
          .map((item) => HydrationLog.fromJson(Map<String, Object?>.from(item)))
          .toList(),
      measurements: json
          .objectList('measurements')
          .whereType<Map>()
          .map(
            (item) => BodyMeasurement.fromJson(Map<String, Object?>.from(item)),
          )
          .toList(),
    );
  }

  static RetoFitSnapshot empty() {
    return const RetoFitSnapshot(storageVersion: LocalStorageService.version);
  }
}

class LocalStorageService {
  LocalStorageService._(this._preferences);

  static const version = 1;
  static const _key = 'retofit30.snapshot.v1';

  final SharedPreferences _preferences;

  static Future<LocalStorageService> create() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalStorageService._(preferences);
  }

  Future<RetoFitSnapshot> load() async {
    final raw = _preferences.getString(_key);
    if (raw == null || raw.trim().isEmpty) {
      return RetoFitSnapshot.empty();
    }
    Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      return RetoFitSnapshot.empty();
    }
    if (decoded is! Map) {
      return RetoFitSnapshot.empty();
    }
    final migrated = _migrate(Map<String, Object?>.from(decoded));
    return RetoFitSnapshot.fromJson(migrated);
  }

  Future<void> save(RetoFitSnapshot snapshot) async {
    final json = jsonEncode(snapshot.copyWith(storageVersion: version).toJson());
    await _preferences.setString(_key, json);
  }

  Future<void> clear() async {
    await _preferences.remove(_key);
  }

  Map<String, Object?> _migrate(Map<String, Object?> json) {
    final storedVersion = json.intValue('storageVersion');
    if (storedVersion >= version) {
      return json;
    }

    // Future migrations should copy data forward instead of replacing it.
    return {
      ...json,
      'storageVersion': version,
      'sessions': json['sessions'] ?? const [],
      'meals': json['meals'] ?? const [],
      'hydration': json['hydration'] ?? const [],
      'measurements': json['measurements'] ?? const [],
    };
  }
}
