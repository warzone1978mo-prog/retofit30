import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../features/workouts/data/local_exercise_catalog.dart';
import '../../shared/models/body_zone.dart';
import '../../shared/models/user_profile.dart';
import '../../shared/widgets/section_card.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _alias = TextEditingController(text: 'Atleta');
  final _age = TextEditingController(text: '30');
  final _height = TextEditingController(text: '170');
  final _weight = TextEditingController(text: '70');
  final _targetWeight = TextEditingController();
  final _days = TextEditingController(text: '3');
  final _minutes = TextEditingController(text: '35');
  final _limitations = TextEditingController();
  final _disliked = TextEditingController();
  final _activities = TextEditingController();
  final _allergies = TextEditingController();
  final _intolerances = TextEditingController();
  final _avoided = TextEditingController();
  final _preferred = TextEditingController();
  final _meals = TextEditingController(text: '3');
  final _budget = TextEditingController();
  final _cooking = TextEditingController(text: '20');
  final _availableFoods = TextEditingController();
  final _region = TextEditingController(text: 'México');
  final _medicalNotes = TextEditingController();

  int _step = 0;
  TrainingGoal _goal = TrainingGoal.habit;
  ActivityLevel _activity = ActivityLevel.light;
  TrainingExperience _experience = TrainingExperience.beginner;
  TrainingPlace _place = TrainingPlace.home;
  SessionIntensity _intensity = SessionIntensity.moderate;
  FeedingStyle _feedingStyle = FeedingStyle.omnivore;
  BiologicalSex _sex = BiologicalSex.unspecified;
  final Set<String> _equipment = {'sin_equipo'};
  final Set<BodyZone> _zones = {BodyZone.fullBody};

  @override
  void dispose() {
    for (final controller in [
      _alias,
      _age,
      _height,
      _weight,
      _targetWeight,
      _days,
      _minutes,
      _limitations,
      _disliked,
      _activities,
      _allergies,
      _intolerances,
      _avoided,
      _preferred,
      _meals,
      _budget,
      _cooking,
      _availableFoods,
      _region,
      _medicalNotes,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'RetoFit 30',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Configura tu perfil para generar recomendaciones locales y ajustables.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(value: (_step + 1) / 4),
              const SizedBox(height: 20),
              IndexedStack(
                index: _step,
                children: [
                  _generalStep(),
                  _trainingStep(),
                  _nutritionStep(),
                  _reviewStep(),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (_step > 0)
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _step--),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Regresar'),
                    ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _saveDraft,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Guardar avance'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _step == 3 ? _finish : _next,
                    icon: Icon(_step == 3 ? Icons.check : Icons.arrow_forward),
                    label: Text(_step == 3 ? 'Finalizar' : 'Continuar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _generalStep() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('Información general'),
          TextFormField(
            controller: _alias,
            decoration: const InputDecoration(labelText: 'Nombre o alias'),
            validator: _required,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _numberField(_age, 'Edad', min: 10, max: 100)),
              const SizedBox(width: 12),
              Expanded(
                child: _numberField(_height, 'Estatura (cm)', min: 80, max: 240),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _numberField(_weight, 'Peso actual (kg)', min: 25, max: 300),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _targetWeight,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Peso objetivo (opcional)',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _enumDropdown(
            label: 'Objetivo principal',
            value: _goal,
            values: TrainingGoal.values,
            labelFor: (value) => value.label,
            onChanged: (value) => setState(() => _goal = value),
          ),
          const SizedBox(height: 12),
          _enumDropdown(
            label: 'Actividad cotidiana',
            value: _activity,
            values: ActivityLevel.values,
            labelFor: (value) => value.label,
            onChanged: (value) => setState(() => _activity = value),
          ),
          const SizedBox(height: 12),
          _enumDropdown(
            label: 'Parametro opcional para formula energetica',
            value: _sex,
            values: BiologicalSex.values,
            labelFor: (value) => switch (value) {
              BiologicalSex.unspecified => 'No especificar',
              BiologicalSex.female => 'Femenino',
              BiologicalSex.male => 'Masculino',
            },
            onChanged: (value) => setState(() => _sex = value),
          ),
        ],
      ),
    );
  }

  Widget _trainingStep() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('Entrenamiento'),
          Row(
            children: [
              Expanded(
                child: _enumDropdown(
                  label: 'Experiencia',
                  value: _experience,
                  values: TrainingExperience.values,
                  labelFor: (value) => value.label,
                  onChanged: (value) => setState(() => _experience = value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _enumDropdown(
                  label: 'Lugar',
                  value: _place,
                  values: TrainingPlace.values,
                  labelFor: (value) =>
                      value == TrainingPlace.home ? 'Casa' : 'Gimnasio',
                  onChanged: (value) => setState(() => _place = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _numberField(_days, 'Días/semana', min: 1, max: 7)),
              const SizedBox(width: 12),
              Expanded(
                child: _numberField(_minutes, 'Min/sesión', min: 10, max: 120),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _enumDropdown(
            label: 'Esfuerzo preferido',
            value: _intensity,
            values: SessionIntensity.values,
            labelFor: (value) => value.label,
            onChanged: (value) => setState(() => _intensity = value),
          ),
          const SizedBox(height: 16),
          _subtitle('Equipo disponible'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in equipmentOptions)
                FilterChip(
                  label: Text(option.label),
                  selected: _equipment.contains(option.id),
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? _equipment.add(option.id)
                          : _equipment.remove(option.id);
                      if (_equipment.isEmpty) {
                        _equipment.add('sin_equipo');
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          _subtitle('Zonas prioritarias'),
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
          const SizedBox(height: 12),
          TextFormField(
            controller: _limitations,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Limitaciones o molestias',
              helperText: 'No se diagnostica; se usan reglas conservadoras.',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _disliked,
            decoration: const InputDecoration(
              labelText: 'Ejercicios que no te gustan',
              helperText: 'Separa por comas',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _activities,
            decoration: const InputDecoration(
              labelText: 'Actividades que disfrutas',
              helperText: 'Separa por comas',
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutritionStep() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('Nutrición'),
          _enumDropdown(
            label: 'Tipo de alimentación',
            value: _feedingStyle,
            values: FeedingStyle.values,
            labelFor: (value) => value.label,
            onChanged: (value) => setState(() => _feedingStyle = value),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _numberField(_meals, 'Comidas/día', min: 1, max: 8)),
              const SizedBox(width: 12),
              Expanded(
                child: _numberField(_cooking, 'Min para cocinar', min: 0, max: 180),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _allergies,
            decoration: const InputDecoration(
              labelText: 'Alergias',
              helperText: 'Restricción obligatoria. Separa por comas',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _intolerances,
            decoration: const InputDecoration(
              labelText: 'Intolerancias',
              helperText: 'Separa por comas',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _avoided,
            decoration: const InputDecoration(
              labelText: 'Alimentos que no consumes',
              helperText: 'Separa por comas',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _preferred,
            decoration: const InputDecoration(
              labelText: 'Alimentos preferidos',
              helperText: 'Separa por comas',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _availableFoods,
            decoration: const InputDecoration(
              labelText: 'Alimentos disponibles en casa',
              helperText: 'Separa por comas',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _budget,
                  decoration: const InputDecoration(
                    labelText: 'Presupuesto aproximado',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _region,
                  decoration: const InputDecoration(labelText: 'Región'),
                  validator: _required,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _medicalNotes,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Condiciones relevantes opcionales',
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewStep() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('Resumen'),
          _review('Perfil', '${_alias.text}, ${_age.text} años'),
          _review('Peso y estatura', '${_weight.text} kg / ${_height.text} cm'),
          _review('Objetivo', _goal.label),
          _review('Experiencia', _experience.label),
          _review('Entrenamiento', '${_days.text} días, ${_minutes.text} min'),
          _review('Intensidad', _intensity.label),
          _review(
            'Zonas',
            _zones.map((zone) => zone.label).join(', '),
          ),
          _review('Alimentación', _feedingStyle.label),
          _review(
            'Restricciones',
            [
              ..._csv(_allergies.text),
              ..._csv(_intolerances.text),
              ..._csv(_avoided.text),
            ].join(', ').ifEmpty('Sin restricciones registradas'),
          ),
          const SizedBox(height: 12),
          Text(
            'Las recomendaciones son orientacion general. Si hay dolor, alergias, embarazo, lactancia, antecedentes de TCA o condiciones medicas, consulta a un profesional cualificado.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }

  Widget _subtitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label, {
    required num min,
    required num max,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final parsed = num.tryParse(value ?? '');
        if (parsed == null || parsed < min || parsed > max) {
          return 'Valor $min-$max';
        }
        return null;
      },
    );
  }

  Widget _enumDropdown<T extends Enum>({
    required String label,
    required T value,
    required List<T> values,
    required String Function(T value) labelFor,
    required ValueChanged<T> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in values)
          DropdownMenuItem<T>(
            value: item,
            child: Text(labelFor(item)),
          ),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }

  Widget _review(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Campo requerido' : null;
  }

  List<String> _csv(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  UserProfile _buildProfile() {
    final now = DateTime.now();
    return UserProfile(
      alias: _alias.text.trim(),
      age: int.parse(_age.text),
      heightCm: double.parse(_height.text),
      weightKg: double.parse(_weight.text),
      targetWeightKg: double.tryParse(_targetWeight.text),
      goal: _goal,
      activityLevel: _activity,
      experience: _experience,
      trainingPlace: _place,
      equipment: _equipment.toList(),
      desiredZones: _zones.toList(),
      daysPerWeek: int.parse(_days.text),
      minutesPerSession: int.parse(_minutes.text),
      intensityPreference: _intensity,
      dislikedExercises: _csv(_disliked.text),
      limitations: _limitations.text.trim(),
      activitiesEnjoyed: _csv(_activities.text),
      feedingStyle: _feedingStyle,
      allergies: _csv(_allergies.text),
      intolerances: _csv(_intolerances.text),
      avoidedFoods: _csv(_avoided.text),
      preferredFoods: _csv(_preferred.text),
      mealsPerDay: int.parse(_meals.text),
      groceryBudget: _budget.text.trim(),
      cookingMinutes: int.parse(_cooking.text),
      availableFoods: _csv(_availableFoods.text),
      region: _region.text.trim(),
      medicalNotes: _medicalNotes.text.trim(),
      sexForFormula: _sex,
      createdAt: now,
      updatedAt: now,
      challengeStartedAt: now,
    );
  }

  void _next() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    setState(() => _step++);
  }

  Future<void> _saveDraft() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    await RetoFitScope.of(context).saveDraft(_buildProfile());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avance guardado localmente.')),
      );
    }
  }

  Future<void> _finish() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    await RetoFitScope.of(context).saveProfile(_buildProfile());
  }
}

extension _StringEmpty on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
