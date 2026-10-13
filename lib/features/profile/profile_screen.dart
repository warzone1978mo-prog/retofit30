import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../features/workouts/data/local_exercise_catalog.dart';
import '../../shared/models/body_zone.dart';
import '../../shared/models/user_profile.dart';
import '../../shared/widgets/section_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = RetoFitScope.of(context);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final profile = state.profile!;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Perfil',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.alias,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _row('Edad', '${profile.age} años'),
                  _row('Peso', '${profile.weightKg.toStringAsFixed(1)} kg'),
                  _row('Estatura', '${profile.heightCm.toStringAsFixed(0)} cm'),
                  _row('Objetivo', profile.goal.label),
                  _row('Actividad', profile.activityLevel.label),
                  _row('Experiencia', profile.experience.label),
                  _row('Intensidad', profile.intensityPreference.label),
                  _row(
                    'Equipo',
                    equipmentOptions
                        .where((item) => profile.equipment.contains(item.id))
                        .map((item) => item.label)
                        .join(', '),
                  ),
                  _row(
                    'Zonas',
                    profile.desiredZones.map((zone) => zone.label).join(', '),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alimentación y seguridad',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _row('Tipo', profile.feedingStyle.label),
                  _row(
                    'Alergias',
                    profile.allergies.isEmpty
                        ? 'Sin alergias registradas'
                        : profile.allergies.join(', '),
                  ),
                  _row(
                    'Intolerancias',
                    profile.intolerances.isEmpty
                        ? 'Sin intolerancias registradas'
                        : profile.intolerances.join(', '),
                  ),
                  _row('Región', profile.region),
                  if (profile.limitations.isNotEmpty)
                    _row('Limitaciones', profile.limitations),
                  if (profile.medicalNotes.isNotEmpty)
                    _row('Notas', profile.medicalNotes),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fuentes preparadas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('ExerciseDB OSS para ejercicios y GIFs.'),
                  const Text('TheMealDB para recetas y fotografias.'),
                  const Text('USDA FoodData Central para composicion nutricional.'),
                  const Text('Open Food Facts para productos envasados.'),
                  const Text('wger como fuente alternativa de ejercicios.'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Control de datos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Los datos se guardan localmente en este dispositivo. No hay inicio de sesion visible ni subida automatica de informacion personal.',
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context, state),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Borrar perfil y registros'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? 'No registrado' : value)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, RetoFitState state) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar datos'),
        content: const Text(
          'Esta accion elimina perfil, sesiones, comidas, agua y medidas locales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await state.clearAllData();
    }
  }
}
