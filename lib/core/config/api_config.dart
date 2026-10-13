class ApiConfig {
  const ApiConfig._();

  static const exerciseDbBase = 'https://oss.exercisedb.dev/api/v1';
  static const wgerBase = 'https://wger.de/api/v2';
  static const mealDbBase = 'https://www.themealdb.com/api/json/v1/1';
  static const usdaBase = 'https://api.nal.usda.gov/fdc/v1';
  static const openFoodFactsBase = 'https://world.openfoodfacts.org';

  static const usdaApiKey = String.fromEnvironment('USDA_API_KEY');
  static const appUserAgent = 'RetoFit30/0.1 (personal-use; no-email)';
}
