import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../shared/models/exercise.dart';
import '../../shared/models/workout_session.dart';
import '../../shared/widgets/section_card.dart';

class ActiveWorkoutScreen extends StatelessWidget {
  const ActiveWorkoutScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final state = RetoFitScope.of(context);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final session = state.sessions.firstWhere((item) => item.id == sessionId);
        return Scaffold(
          appBar: AppBar(title: Text(session.name)),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.status.label,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${session.type.label} · ${session.intensity.label} · ${session.plannedDurationMinutes} min',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Zonas: ${session.primaryZones.map((z) => z.label).join(', ')}',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: session.status == WorkoutStatus.planned
                              ? () => state.startSession(session.id)
                              : null,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Iniciar'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: session.isCompleted
                              ? null
                              : () async {
                                  await state.completeSessionWithDefaults(session.id);
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                          icon: const Icon(Icons.check),
                          label: const Text('Finalizar y guardar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              for (final plan in session.exercises)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: plan.exercise.gifUrl == null
                                  ? const Icon(Icons.fitness_center)
                                  : Image.network(
                                      plan.exercise.gifUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.broken_image_outlined),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan.exercise.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${plan.phase} · ${plan.exercise.difficulty.label}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(_setSummary(plan)),
                        const SizedBox(height: 12),
                        for (final instruction in plan.exercise.instructions)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text('• $instruction'),
                          ),
                        const Divider(height: 24),
                        Text(
                          'Errores frecuentes: ${plan.exercise.commonMistakes.join(', ')}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan.exercise.safetyTips.first,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _setSummary(WorkoutExercisePlan plan) {
    final sets = plan.plannedSets;
    if (sets.isEmpty) {
      return 'Sin series planificadas';
    }
    final first = sets.first;
    if (first.durationSeconds != null) {
      return '${sets.length} bloque(s) de ${(first.durationSeconds! / 60).round()} min · descanso ${first.restSeconds} s';
    }
    return '${sets.length} x ${first.repetitions} repeticiones · descanso ${first.restSeconds} s';
  }
}
