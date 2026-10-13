import '../../../core/config/api_config.dart';
import '../../../core/networking/http_json_client.dart';
import '../../../shared/models/nutrition.dart';

class ExternalRecipe {
  const ExternalRecipe({
    required this.id,
    required this.name,
    required this.source,
    this.category,
    this.area,
    this.instructions,
    this.imageUrl,
    this.ingredients = const [],
  });

  final String id;
  final String name;
  final String source;
  final String? category;
  final String? area;
  final String? instructions;
  final String? imageUrl;
  final List<String> ingredients;
}

class TheMealDbClient {
  const TheMealDbClient({this.http = const HttpJsonClient()});

  final HttpJsonClient http;

  Future<List<ExternalRecipe>> searchByName(String query) async {
    final uri = Uri.parse('${ApiConfig.mealDbBase}/search.php').replace(
      queryParameters: {'s': query},
    );
    final json = await http.getJson(uri);
    final meals = json is Map ? json['meals'] : null;
    if (meals is! List) {
      return const [];
    }
    return meals
        .whereType<Map>()
        .map((item) => _mealFromJson(Map<String, Object?>.from(item)))
        .toList();
  }

  Future<ExternalRecipe?> randomRecipe() async {
    final json = await http.getJson(Uri.parse('${ApiConfig.mealDbBase}/random.php'));
    final meals = json is Map ? json['meals'] : null;
    if (meals is List && meals.isNotEmpty && meals.first is Map) {
      return _mealFromJson(Map<String, Object?>.from(meals.first as Map));
    }
    return null;
  }

  ExternalRecipe _mealFromJson(Map<String, Object?> json) {
    final ingredients = <String>[];
    for (var index = 1; index <= 20; index++) {
      final ingredient = json['strIngredient$index']?.toString().trim() ?? '';
      final measure = json['strMeasure$index']?.toString().trim() ?? '';
      if (ingredient.isNotEmpty) {
        ingredients.add([measure, ingredient].where((item) => item.isNotEmpty).join(' '));
      }
    }
    return ExternalRecipe(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? 'Receta sin nombre',
      source: 'TheMealDB',
      category: json['strCategory']?.toString(),
      area: json['strArea']?.toString(),
      instructions: json['strInstructions']?.toString(),
      imageUrl: json['strMealThumb']?.toString(),
      ingredients: ingredients,
    );
  }
}

class UsdaFoodDataClient {
  const UsdaFoodDataClient({
    this.http = const HttpJsonClient(),
    this.apiKey = ApiConfig.usdaApiKey,
  });

  final HttpJsonClient http;
  final String apiKey;

  Future<List<FoodItem>> searchFoods(String query) async {
    if (apiKey.isEmpty) {
      throw const ApiException(
        'USDA FoodData Central requiere api_key. Usa un proxy seguro para produccion.',
      );
    }
    final uri = Uri.parse('${ApiConfig.usdaBase}/foods/search').replace(
      queryParameters: {
        'api_key': apiKey,
        'query': query,
        'pageSize': '20',
      },
    );
    final json = await http.getJson(uri);
    final foods = json is Map ? json['foods'] : null;
    if (foods is! List) {
      return const [];
    }
    return foods
        .whereType<Map>()
        .map((item) => _usdaFoodToItem(Map<String, Object?>.from(item)))
        .toList();
  }

  FoodItem _usdaFoodToItem(Map<String, Object?> json) {
    final nutrients = json['foodNutrients'] is List
        ? json['foodNutrients'] as List
        : const [];
    double valueFor(String nutrientName) {
      final nutrient = nutrients.whereType<Map>().cast<Map>().firstWhere(
            (item) =>
                (item['nutrientName']?.toString().toLowerCase() ?? '')
                    .contains(nutrientName),
            orElse: () => const {},
          );
      final value = nutrient['value'];
      return value is num ? value.toDouble() : 0;
    }

    return FoodItem(
      id: 'usda_${json['fdcId']}',
      name: json['description']?.toString() ?? 'Alimento USDA',
      referenceAmount: 100,
      referenceUnit: 'g',
      nutrients: Nutrients(
        energyKcal: valueFor('energy'),
        proteinG: valueFor('protein'),
        carbsG: valueFor('carbohydrate'),
        fatG: valueFor('total lipid'),
        fiberG: valueFor('fiber'),
        sugarsG: valueFor('sugars'),
      ),
      source: 'USDA FoodData Central',
      brand: json['brandOwner']?.toString(),
    );
  }
}

class OpenFoodFactsClient {
  const OpenFoodFactsClient({this.http = const HttpJsonClient()});

  final HttpJsonClient http;

  Future<FoodItem?> productByBarcode(String barcode) async {
    final uri = Uri.parse(
      '${ApiConfig.openFoodFactsBase}/api/v3.6/product/$barcode.json',
    );
    final json = await http.getJson(
      uri,
      headers: const {'User-Agent': ApiConfig.appUserAgent},
    );
    final product = json is Map ? json['product'] : null;
    if (product is! Map) {
      return null;
    }
    return _offProductToFoodItem(barcode, Map<String, Object?>.from(product));
  }

  FoodItem _offProductToFoodItem(String barcode, Map<String, Object?> product) {
    final nutriments = product['nutriments'] is Map
        ? Map<String, Object?>.from(product['nutriments'] as Map)
        : <String, Object?>{};
    double n(String key) {
      final value = nutriments[key];
      return value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
    }

    return FoodItem(
      id: 'off_$barcode',
      name: product['product_name']?.toString().isNotEmpty == true
          ? product['product_name'].toString()
          : 'Producto envasado',
      referenceAmount: 100,
      referenceUnit: 'g',
      nutrients: Nutrients(
        energyKcal: n('energy-kcal_100g'),
        proteinG: n('proteins_100g'),
        carbsG: n('carbohydrates_100g'),
        fatG: n('fat_100g'),
        fiberG: n('fiber_100g'),
        sugarsG: n('sugars_100g'),
      ),
      source: 'Open Food Facts',
      brand: product['brands']?.toString(),
      imageUrl: product['image_front_url']?.toString(),
      ingredientsText: product['ingredients_text']?.toString() ?? '',
      allergenTags: product['allergens_tags'] is List
          ? (product['allergens_tags'] as List).map((item) => item.toString()).toList()
          : const [],
      dataWarnings: const [
        'Datos declarados por fabricante o comunidad; pueden estar incompletos.',
      ],
    );
  }
}
