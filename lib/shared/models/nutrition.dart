import '../../core/utils/date_utils.dart';
import 'user_profile.dart';

enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeLabels on MealType {
  String get label => switch (this) {
        MealType.breakfast => 'Desayuno',
        MealType.lunch => 'Comida',
        MealType.dinner => 'Cena',
        MealType.snack => 'Colación',
      };
}

class Nutrients {
  const Nutrients({
    this.energyKcal = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
    this.fiberG = 0,
    this.sugarsG = 0,
  });

  final double energyKcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double sugarsG;

  Nutrients scale(double factor) {
    return Nutrients(
      energyKcal: energyKcal * factor,
      proteinG: proteinG * factor,
      carbsG: carbsG * factor,
      fatG: fatG * factor,
      fiberG: fiberG * factor,
      sugarsG: sugarsG * factor,
    );
  }

  Nutrients operator +(Nutrients other) {
    return Nutrients(
      energyKcal: energyKcal + other.energyKcal,
      proteinG: proteinG + other.proteinG,
      carbsG: carbsG + other.carbsG,
      fatG: fatG + other.fatG,
      fiberG: fiberG + other.fiberG,
      sugarsG: sugarsG + other.sugarsG,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'energyKcal': energyKcal,
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatG': fatG,
      'fiberG': fiberG,
      'sugarsG': sugarsG,
    };
  }

  factory Nutrients.fromJson(Map<String, Object?> json) {
    return Nutrients(
      energyKcal: json.doubleValue('energyKcal'),
      proteinG: json.doubleValue('proteinG'),
      carbsG: json.doubleValue('carbsG'),
      fatG: json.doubleValue('fatG'),
      fiberG: json.doubleValue('fiberG'),
      sugarsG: json.doubleValue('sugarsG'),
    );
  }
}

class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.referenceAmount,
    required this.referenceUnit,
    required this.nutrients,
    required this.source,
    this.brand,
    this.imageUrl,
    this.allergenTags = const [],
    this.ingredientsText = '',
    this.dataWarnings = const [],
  });

  final String id;
  final String name;
  final double referenceAmount;
  final String referenceUnit;
  final Nutrients nutrients;
  final String source;
  final String? brand;
  final String? imageUrl;
  final List<String> allergenTags;
  final String ingredientsText;
  final List<String> dataWarnings;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'referenceAmount': referenceAmount,
      'referenceUnit': referenceUnit,
      'nutrients': nutrients.toJson(),
      'source': source,
      'brand': brand,
      'imageUrl': imageUrl,
      'allergenTags': allergenTags,
      'ingredientsText': ingredientsText,
      'dataWarnings': dataWarnings,
    };
  }

  factory FoodItem.fromJson(Map<String, Object?> json) {
    return FoodItem(
      id: json.stringValue('id'),
      name: json.stringValue('name'),
      referenceAmount: json.doubleValue('referenceAmount', fallback: 100),
      referenceUnit: json.stringValue('referenceUnit', fallback: 'g'),
      nutrients: Nutrients.fromJson(
        Map<String, Object?>.from(json['nutrients'] as Map),
      ),
      source: json.stringValue('source', fallback: 'manual'),
      brand: json['brand']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      allergenTags: json.stringList('allergenTags'),
      ingredientsText: json.stringValue('ingredientsText'),
      dataWarnings: json.stringList('dataWarnings'),
    );
  }
}

class MealEntry {
  const MealEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.food,
    required this.amount,
    required this.unit,
  });

  final String id;
  final DateTime date;
  final MealType type;
  final FoodItem food;
  final double amount;
  final String unit;

  Nutrients get consumedNutrients {
    if (unit != food.referenceUnit || food.referenceAmount <= 0) {
      return const Nutrients();
    }
    return food.nutrients.scale(amount / food.referenceAmount);
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'date': toIsoDateTime(date),
      'type': type.name,
      'food': food.toJson(),
      'amount': amount,
      'unit': unit,
    };
  }

  factory MealEntry.fromJson(Map<String, Object?> json) {
    return MealEntry(
      id: json.stringValue('id'),
      date: parseDateTime(json['date']) ?? DateTime.now(),
      type: enumByName(MealType.values, json['type'], MealType.snack),
      food: FoodItem.fromJson(
        Map<String, Object?>.from(json['food'] as Map),
      ),
      amount: json.doubleValue('amount'),
      unit: json.stringValue('unit', fallback: 'g'),
    );
  }
}

class HydrationLog {
  const HydrationLog({
    required this.id,
    required this.date,
    required this.milliliters,
  });

  final String id;
  final DateTime date;
  final int milliliters;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'date': toIsoDateTime(date),
      'milliliters': milliliters,
    };
  }

  factory HydrationLog.fromJson(Map<String, Object?> json) {
    return HydrationLog(
      id: json.stringValue('id'),
      date: parseDateTime(json['date']) ?? DateTime.now(),
      milliliters: json.intValue('milliliters'),
    );
  }
}

class BodyMeasurement {
  const BodyMeasurement({
    required this.id,
    required this.date,
    required this.weightKg,
    this.waistCm,
    this.hipCm,
    this.notes = '',
  });

  final String id;
  final DateTime date;
  final double weightKg;
  final double? waistCm;
  final double? hipCm;
  final String notes;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'date': toIsoDateTime(date),
      'weightKg': weightKg,
      'waistCm': waistCm,
      'hipCm': hipCm,
      'notes': notes,
    };
  }

  factory BodyMeasurement.fromJson(Map<String, Object?> json) {
    return BodyMeasurement(
      id: json.stringValue('id'),
      date: parseDateTime(json['date']) ?? DateTime.now(),
      weightKg: json.doubleValue('weightKg'),
      waistCm: json.optionalDouble('waistCm'),
      hipCm: json.optionalDouble('hipCm'),
      notes: json.stringValue('notes'),
    );
  }
}
