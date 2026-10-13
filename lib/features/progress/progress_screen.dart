import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/models/body_zone.dart';
import '../../shared/models/workout_session.dart';
import '../../shared/widgets/section_card.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  BodyZone _selectedZone = BodyZone.fullBody;
  final _weight = TextEditingController();
  final _waist = TextEditingController();
  final _hip = TextEditingController();

  @override
  void dispose() {
    _weight.dispose();
    _waist.dispose();
    _hip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = RetoFitScope.of(context);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final profile = state.profile!;
        final stats = state.challengeStats!;
        final latest = state.latestMeasurement;
        final bmi = latest == null
            ? null
            : state.bodyMetrics.evaluateAdultBmi(
                age: profile.age,
                weightKg: latest.weightKg,
                heightCm: profile.heightCm,
              );
        final zoneSessions = state.sessions.where((session) {
          if (!session.isCompleted) {
            return false;
          }
          if (_selectedZone == BodyZone.fullBody) {
            return true;
          }
          return session.primaryZones.contains(_selectedZone) ||
              session.secondaryZones.contains(_selectedZone);
        }).toList();

        final zoneMinutes = zoneSessions.fold(
          0,
          (total, session) => total + session.actualDurationMinutes,
        );
        final zoneSets = zoneSessions.fold(
          0,
          (total, session) => total + session.completedSets,
        );
        final zoneReps = zoneSessions.fold(
          0,
          (total, session) => total + session.completedRepetitions,
        );

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Progreso',
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
                    'Reto de 30 días',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: stats.progress),
                  const SizedBox(height: 12),
                  Text(
                    'Día ${stats.currentDay} · ${stats.completedDays} días cumplidos · quedan ${stats.remainingDays}',
                  ),
                  const SizedBox(height: 16),
                  _CalendarStrip(sessions: state.sessions),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medidas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    latest == null
                        ? 'Sin mediciones registradas.'
                        : 'Último peso: ${latest.weightKg.toStringAsFixed(1)} kg · ${formatShortDate(latest.date)}',
                  ),
                  if (bmi != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'IMC ${bmi.value.toStringAsFixed(1)} kg/m² · ${bmi.category}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bmi.note,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _numberField(_weight, 'Peso kg')),
                      const SizedBox(width: 8),
                      Expanded(child: _numberField(_waist, 'Cintura cm')),
                      const SizedBox(width: 8),
                      Expanded(child: _numberField(_hip, 'Cadera cm')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      state.addMeasurement(
                        weightKg: double.tryParse(_weight.text) ?? 0,
                        waistCm: double.tryParse(_waist.text),
                        hipCm: double.tryParse(_hip.text),
                      );
                      _weight.clear();
                      _waist.clear();
                      _hip.clear();
                    },
                    icon: const Icon(Icons.add_chart),
                    label: const Text('Guardar medida'),
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
                    'Estadísticas por zona',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<BodyZone>(
                    value: _selectedZone,
                    decoration: const InputDecoration(labelText: 'Zona'),
                    items: [
                      for (final zone in BodyZone.values)
                        DropdownMenuItem(value: zone, child: Text(zone.label)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedZone = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('Sesiones: ${zoneSessions.length}'),
                  Text('Minutos acumulados: $zoneMinutes'),
                  Text('Series completadas: $zoneSets'),
                  Text('Repeticiones registradas: $zoneReps'),
                  const SizedBox(height: 8),
                  Text(
                    'El volumen en kg se conserva por ejercicio y no se mezcla como una sola medida comparable entre movimientos distintos.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _CalendarStrip extends StatelessWidget {
  const _CalendarStrip({required this.sessions});

  final List<WorkoutSession> sessions;

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        final day = today.subtract(Duration(days: today.day - 1)).add(
              Duration(days: index),
            );
        final daySessions = sessions
            .where((session) => isSameCalendarDay(session.plannedAt, day))
            .toList();
        final completed = daySessions.any((session) => session.isCompleted);
        final planned = daySessions.isNotEmpty;
        final color = completed
            ? Theme.of(context).colorScheme.primary
            : planned
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.surfaceContainerHighest;
        return Tooltip(
          message: completed
              ? 'Entrenamiento completado'
              : planned
                  ? 'Entrenamiento planificado'
                  : 'Sin sesión',
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color.withOpacity(completed ? 0.9 : 0.24),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        );
      },
    );
  }
}
