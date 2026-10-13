import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../shared/models/nutrition.dart';
import '../../shared/widgets/section_card.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _food = TextEditingController();
  final _amount = TextEditingController(text: '100');
  final _kcal = TextEditingController(text: '0');
  final _protein = TextEditingController(text: '0');
  final _carbs = TextEditingController(text: '0');
  final _fat = TextEditingController(text: '0');
  MealType _mealType = MealType.breakfast;

  @override
  void dispose() {
    _food.dispose();
    _amount.dispose();
    _kcal.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = RetoFitScope.of(context);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final profile = state.profile!;
        final estimate = state.nutritionCalculator.estimate(profile);
        final consumed = state.todayConsumedNutrients;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Nutrición',
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
                    'Hoy',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${consumed.energyKcal.round()} kcal registradas',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Meta estimada: ${estimate.targetKcal?.round().toString() ?? 'pendiente'} kcal',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'P ${consumed.proteinG.round()} g · C ${consumed.carbsG.round()} g · G ${consumed.fatG.round()} g',
                  ),
                  const SizedBox(height: 8),
                  Text('Agua: ${state.todayWaterMl} ml'),
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
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hidratación',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final ml in [250, 500, 750])
                        FilledButton.tonalIcon(
                          onPressed: () => state.addWater(ml),
                          icon: const Icon(Icons.water_drop_outlined),
                          label: Text('+$ml ml'),
                        ),
                    ],
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
                    'Registro manual de alimento',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _food,
                    decoration: const InputDecoration(labelText: 'Alimento'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<MealType>(
                    value: _mealType,
                    decoration: const InputDecoration(labelText: 'Comida'),
                    items: [
                      for (final type in MealType.values)
                        DropdownMenuItem(value: type, child: Text(type.label)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _mealType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _numberField(_amount, 'Cantidad g')),
                      const SizedBox(width: 8),
                      Expanded(child: _numberField(_kcal, 'kcal/100g')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _numberField(_protein, 'Prot g')),
                      const SizedBox(width: 8),
                      Expanded(child: _numberField(_carbs, 'Carb g')),
                      const SizedBox(width: 8),
                      Expanded(child: _numberField(_fat, 'Grasa g')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      await state.addMeal(
                        name: _food.text,
                        type: _mealType,
                        amount: double.tryParse(_amount.text) ?? 0,
                        nutrientsPerReference: Nutrients(
                          energyKcal: double.tryParse(_kcal.text) ?? 0,
                          proteinG: double.tryParse(_protein.text) ?? 0,
                          carbsG: double.tryParse(_carbs.text) ?? 0,
                          fatG: double.tryParse(_fat.text) ?? 0,
                        ),
                      );
                      _food.clear();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Guardar alimento'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Comidas de hoy',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            for (final meal in state.todayMeals)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SectionCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.restaurant_menu),
                    title: Text(meal.food.name),
                    subtitle: Text(
                      '${meal.type.label} · ${meal.amount.toStringAsFixed(0)} ${meal.unit} · ${meal.food.source}',
                    ),
                    trailing: Text(
                      '${meal.consumedNutrients.energyKcal.round()} kcal',
                    ),
                  ),
                ),
              ),
            if (state.todayMeals.isEmpty)
              const SectionCard(
                child: Text('Aún no hay alimentos registrados hoy.'),
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
