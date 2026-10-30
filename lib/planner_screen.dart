import 'package:flutter/material.dart';
import 'models.dart';
import 'database.dart';
import 'pdf_service.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({Key? key}) : super(key: key);

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final FiveMealPlan _plan = FiveMealPlan();
  int _totalMealsToAssign = 3;
  int _activeMealIndex = 1;

  final TextEditingController _clientName = TextEditingController();
  final TextEditingController _targetCal = TextEditingController(text: "2000");

  final List<String> _titles = [
    "Meal 1 (Breakfast)",
    "Meal 2 (Mid-Morning)",
    "Meal 3 (Lunch)",
    "Meal 4 (Evening Snack)",
    "Meal 5 (Dinner)"
  ];

  void _openFoodSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.75,
        child: ListView.builder(
          itemCount: AppDataSheets.foodDatabase.length,
          itemBuilder: (ctx, i) {
            final food = AppDataSheets.foodDatabase[i];
            return ListTile(
              title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${food.servingUnit} | ${food.calories} kcal | P: ${food.protein}g"),
              trailing: IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFFF59E0B)),
                onPressed: () {
                  setState(() {
                    _plan.getMealList(_activeMealIndex).add(MealEntry(food: food, quantity: 1.0));
                  });
                  Navigator.pop(ctx);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<MealEntry> currentItems = _plan.getMealList(_activeMealIndex);

    return Scaffold(
      appBar: AppBar(title: const Text("fitwithRahul Builder"), backgroundColor: const Color(0xFF1E293B)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(flex: 2, child: TextField(controller: _clientName, decoration: const InputDecoration(labelText: "Client Name", border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(flex: 1, child: TextField(controller: _targetCal, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Target Cal", border: OutlineInputBorder()))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF0F172A),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total: ${_plan.grandCalories.toStringAsFixed(0)} kcal", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
                Text("P: ${_plan.grandProtein.toStringAsFixed(0)}g | C: ${_plan.grandCarbs.toStringAsFixed(0)}g | F: ${_plan.grandFats.toStringAsFixed(0)}g", style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Select Meals:", style: TextStyle(fontWeight: FontWeight.bold)),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 3, label: Text("3")),
                    ButtonSegment(value: 4, label: Text("4")),
                    ButtonSegment(value: 5, label: Text("5")),
                  ],
                  selected: {_totalMealsToAssign},
                  onSelectionChanged: (val) {
                    setState(() {
                      _totalMealsToAssign = val.first;
                      if (_activeMealIndex > _totalMealsToAssign) _activeMealIndex = 1;
                    });
                  },
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_totalMealsToAssign, (idx) {
                int mealNum = idx + 1;
                bool sel = _activeMealIndex == mealNum;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text("Meal $mealNum (${_plan.getMealList(mealNum).length})"),
                    selected: sel,
                    selectedColor: const Color(0xFFF59E0B),
                    onSelected: (_) => setState(() => _activeMealIndex = mealNum),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_titles[_activeMealIndex - 1], style: const TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton.icon(onPressed: _openFoodSheet, icon: const Icon(Icons.add, size: 16), label: const Text("Add Food")),
              ],
            ),
          ),
          Expanded(
            child: currentItems.isEmpty
                ? const Center(child: Text("Empty meal. Click '+ Add Food'."))
                : ListView.builder(
                    itemCount: currentItems.length,
                    itemBuilder: (ctx, i) {
                      final item = currentItems[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(item.food.name),
                          subtitle: Text("${item.totalCalories.toStringAsFixed(0)} kcal | P: ${item.totalProtein.toStringAsFixed(1)}g"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => setState(() {
                                  if (item.quantity > 0.5) {
                                    item.quantity -= 0.5;
                                  } else {
                                    currentItems.removeAt(i);
                                  }
                                }),
                              ),
                              Text("${item.quantity}x"),
                              IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => item.quantity += 0.5)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text("Share PDF to WhatsApp", style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () {
                PdfService.sharePdf(
                  clientName: _clientName.text.isEmpty ? "Client" : _clientName.text,
                  targetCalories: double.tryParse(_targetCal.text) ?? 2000.0,
                  plan: _plan,
                  workouts: AppDataSheets.defaultWorkouts,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
