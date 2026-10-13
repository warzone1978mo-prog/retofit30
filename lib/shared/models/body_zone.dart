enum BodyZone {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  forearms,
  core,
  glutes,
  quads,
  hamstrings,
  calves,
  fullBody,
  cardio,
  mobility,
}

extension BodyZoneLabels on BodyZone {
  String get id => switch (this) {
        BodyZone.chest => 'chest',
        BodyZone.back => 'back',
        BodyZone.shoulders => 'shoulders',
        BodyZone.biceps => 'biceps',
        BodyZone.triceps => 'triceps',
        BodyZone.forearms => 'forearms',
        BodyZone.core => 'core',
        BodyZone.glutes => 'glutes',
        BodyZone.quads => 'quads',
        BodyZone.hamstrings => 'hamstrings',
        BodyZone.calves => 'calves',
        BodyZone.fullBody => 'full_body',
        BodyZone.cardio => 'cardio',
        BodyZone.mobility => 'mobility',
      };

  String get label => switch (this) {
        BodyZone.chest => 'Pecho',
        BodyZone.back => 'Espalda',
        BodyZone.shoulders => 'Hombros',
        BodyZone.biceps => 'Bíceps',
        BodyZone.triceps => 'Tríceps',
        BodyZone.forearms => 'Antebrazos',
        BodyZone.core => 'Abdomen y zona media',
        BodyZone.glutes => 'Glúteos',
        BodyZone.quads => 'Cuádriceps',
        BodyZone.hamstrings => 'Isquiotibiales',
        BodyZone.calves => 'Pantorrillas',
        BodyZone.fullBody => 'Cuerpo completo',
        BodyZone.cardio => 'Cardio',
        BodyZone.mobility => 'Movilidad',
      };
}

BodyZone bodyZoneFromId(Object? value) {
  final id = value?.toString();
  return BodyZone.values.firstWhere(
    (zone) => zone.id == id || zone.name == id,
    orElse: () => BodyZone.fullBody,
  );
}
