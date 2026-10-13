import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../shared/models/body_zone.dart';
import '../../shared/models/user_profile.dart';
import '../../shared/models/workout_session.dart';
import '../../shared/widgets/section_card.dart';
import 'active_workout_screen.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  SessionIntensity _intensity = SessionIntensity.moderate;
  final Set<BodyZone> _zones = {BodyZone.fullBody};

  @override
  Widget build(BuildContext context) {
    final state = RetoFitScope.of(context);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final sessions = [...state.sessions]
          ..sort((a, b) => b.plannedAt.compareTo(a.plannedAt));
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Entrenamiento',
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
                    'Generar rutina',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<SessionIntensity>(
                    segments: [
                      for (final intensity in SessionIntensity.values)
                        ButtonSegment(
                          value: intensity,
                          label: Text(intensity.label),
                        ),
                    ],
                    selected: {_intensity},
                    onSelectionChanged: (value) {
                      setState(() => _intensity = value.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final zone in BodyZone.values)
                        FilterChip(
                          label: Text(zone.label),
                          selected: _zones.contains(zone),
                          onSelected: (selected) {
                            setState(() {
                              selected ? _zones.add(zone) : _zones.remove(zone);
                              if (_zones.isEmpty) {
                                _zones.add(BodyZone.fullBody);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () async {
                      final result = await state.generateWorkout(
                        zones: _zones.toList(),
                        intensity: _intensity,
                      );
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result.session == null
                                ? result.warning ?? 'No se pudo generar rutina.'
                                : result.warning ?? 'Rutina generada.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Crear rutina compatible'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Historial y calendario',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            for (final session in sessions)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SessionTile(session: session),
              ),
            if (sessions.isEmpty)
              const SectionCard(
                child: Text('Todavía no hay sesiones guardadas.'),
              ),
          ],
        );
      },
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final statusColor = session.isCompleted
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return SectionCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.16),
          child: Icon(
            session.isCompleted ? Icons.check : Icons.event_note,
            color: statusColor,
          ),
        ),
        title: Text(session.name),
        subtitle: Text(
          '${session.status.label} · ${session.primaryZones.map((z) => z.label).join(', ')}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ActiveWorkoutScreen(sessionId: session.id),
          ),
        ),
      ),
    );
  }
}
