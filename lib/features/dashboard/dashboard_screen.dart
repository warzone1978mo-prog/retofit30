import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/models/body_zone.dart';
import '../../shared/models/user_profile.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/section_card.dart';
import '../workouts/active_workout_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = RetoFitScope.of(context);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final profile = state.profile!;
        final stats = state.challengeStats!;
        final workout = state.todayWorkout;
        final nutrients = state.todayConsumedNutrients;
        final estimate = state.nutritionCalculator.estimate(profile);
        final bmi = state.bodyMetrics.evaluateAdultBmi(
          age: profile.age,
          weightKg: state.latestMeasurement?.weightKg ?? profile.weightKg,
          heightCm: profile.heightCm,
        );
        final completed = state.sessions.where((s) => s.isCompleted).length;
        final minutes = state.sessions.fold(
          0,
          (total, session) => total + session.actualDurationMinutes,
        );

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _Header(profile: profile),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Día ${stats.currentDay} de 30',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Text('${(stats.progress * 100).round()}%'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: stats.progress),
                  const SizedBox(height: 12),
                  Text(
                    '${stats.completedDays} días cumplidos · racha ${stats.streak}',
                    style: Theme.of(context).textTheme.bodyMedium,
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
                    'Entrenamiento del día',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (workout == null) ...[
                    const Text(
                      'No hay rutina planificada para hoy. Genera una con tus datos actuales.',
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () async {
                        final result = await state.generateWorkout();
                        if (context.mounted && result.warning != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result.warning!)),
                          );
                        }
                      },
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Generar rutina'),
                    ),
                  ] else ...[
                    Text(
                      workout.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${workout.primaryZones.map((z) => z.label).join(', ')} · '
                      '${workout.intensity.label} · ${workout.plannedDurationMinutes} min · '
                      '${workout.exercises.length} ejercicios',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: workout.isCompleted
                              ? null
                              : () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ActiveWorkoutScreen(sessionId: workout.id),
                                    ),
                                  ),
                          icon: const Icon(Icons.play_arrow),
                          label: Text(
                            workout.isCompleted ? 'Completada' : 'Iniciar',
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ActiveWorkoutScreen(sessionId: workout.id),
                            ),
                          ),
                          icon: const Icon(Icons.visibility_outlined),
                          label: const Text('Revisar'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen nutricional',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${nutrients.energyKcal.round()} kcal registradas'
                    '${estimate.targetKcal == null ? '' : ' de ${estimate.targetKcal!.round()} kcal estimadas'}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Proteína ${nutrients.proteinG.round()} g · Carbohidratos ${nutrients.carbsG.round()} g · Grasas ${nutrients.fatG.round()} g',
                  ),
                  const SizedBox(height: 8),
                  Text('Agua: ${(state.todayWaterMl / 1000).toStringAsFixed(1)} L'),
                  if (!estimate.available) ...[
                    const SizedBox(height: 8),
                    Text(
                      estimate.explanation,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.sizeOf(context).width > 640 ? 4 : 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: [
                MetricCard(
                  label: 'Último peso',
                  value:
                      '${(state.latestMeasurement?.weightKg ?? profile.weightKg).toStringAsFixed(1)} kg',
                  icon: Icons.monitor_weight_outlined,
                ),
                MetricCard(
                  label: 'IMC',
                  value: bmi == null ? 'N/D' : bmi.value.toStringAsFixed(1),
                  subtitle: bmi?.category,
                  icon: Icons.accessibility_new,
                ),
                MetricCard(
                  label: 'Minutos',
                  value: '$minutes',
                  icon: Icons.timer_outlined,
                ),
                MetricCard(
                  label: 'Sesiones',
                  value: '$completed',
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, ${profile.alias}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${formatShortDate(DateTime.now())} · ${_message(profile)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Ajustes',
        ),
      ],
    );
  }

  String _message(UserProfile profile) {
    if (profile.hasSafetyFlags) {
      return 'hoy con margen conservador';
    }
    return switch (profile.goal) {
      TrainingGoal.habit => 'un día más para construir el hábito',
      TrainingGoal.fatLoss => 'constancia antes que extremos',
      TrainingGoal.mobility => 'mueve con calma y control',
      _ => 'entrena con intención',
    };
  }
}
