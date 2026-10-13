# RetoFit 30

Base Flutter modular para una app personal de acondicionamiento fisico y nutricion en español de Mexico.

## Estado de esta entrega

No habia un proyecto Flutter existente en el workspace recibido. Esta carpeta contiene una base funcional creada desde cero para continuar el desarrollo:

- Onboarding inicial sin registro ni inicio de sesion.
- Perfil fisico, entrenamiento y preferencias alimentarias.
- Persistencia local versionada con `shared_preferences`.
- Dashboard, entrenamiento, nutricion, progreso y perfil con navegacion inferior.
- Generador local de rutinas filtrado por objetivo, zonas, equipo, tiempo, experiencia e intensidad.
- Registro de sesiones completadas, comida, agua, peso y medidas.
- Calculo de IMC y estimacion energetica con Mifflin-St Jeor cuando los datos requeridos existen.
- Adaptadores iniciales para ExerciseDB OSS, TheMealDB, USDA FoodData Central, Open Food Facts y wger.
- Pruebas unitarias de la logica principal.

## Fuentes de API verificadas

- ExerciseDB OSS: `https://oss.exercisedb.dev/api/v1/exercises`, respuesta con `exerciseId`, `name`, `gifUrl`, `targetMuscles`, `bodyParts`, `equipments`, `secondaryMuscles` e `instructions`. Uso no comercial y atribucion requerida.
- TheMealDB: endpoints V1 como `/api/json/v1/1/search.php?s=`, `/lookup.php?i=`, `/random.php`, `/categories.php` y filtros por ingrediente/categoria/area.
- USDA FoodData Central: `/fdc/v1/foods/search` y `/fdc/v1/food/{fdcId}` requieren `api_key`; no se guarda ninguna clave en el repositorio.
- Open Food Facts: produccion en `https://world.openfoodfacts.org`, API v3.6 recomendada para lectura de producto, API v2 para busqueda estructurada, `User-Agent` personalizado obligatorio.
- wger: endpoints publicos JSON bajo `https://wger.de/api/v2/`; la autenticacion solo se reserva para objetos del usuario.

## Comandos esperados

Ejecutar desde esta carpeta cuando Flutter este instalado:

```powershell
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

En la sesion actual no fue posible ejecutarlos porque `flutter` y `dart` no estan disponibles en el PATH.

## Configuracion externa

La app no incluye secretos. Para desarrollo con USDA puede compilarse con:

```powershell
flutter run --dart-define=USDA_API_KEY=TU_CLAVE
```

Para produccion, la clave USDA debe vivir en un proxy o funcion de servidor; una variable compilada en una app movil no es un secreto fuerte.
