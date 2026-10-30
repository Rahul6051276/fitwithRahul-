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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.75,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text("Add Food to ${_titles[_activeMealIndex - 1]}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: AppDataSheets.foodDatabase.length,
                itemBuilder: (ctx, i) {
                  final food = AppDataSheets.foodDatabase[i];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                      child: Text(food.iconEmoji, style: const TextStyle(fontSize: 22)),
                    ),
                    title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Per 100g: ${food.per100gCalories.toStringAsFixed(0)} kcal | P: ${food.per100gProtein}g"),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                      onPressed: () {
                        setState(() {
                          _plan.getMealList(_activeMealIndex).add(MealEntry(food: food, grams: 100.0));
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text("Add", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
          ],
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
                Text("Total: ${_plan.grandCalories.toStringAsFixed(0)} kcal", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 15)),
                Text("P: ${_plan.grandProtein.toStringAsFixed(0)}g | C: ${_plan.grandCarbs.toStringAsFixed(0)}g | F: ${_plan.grandFats.toStringAsFixed(0)}g", style: const TextStyle(color: Colors.white, fontSize: 13)),
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
                Text(_titles[_activeMealIndex - 1], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ElevatedButton.icon(
                  onPressed: _openFoodSheet,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Add Food"),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.black),
                ),
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
                        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                                    child: Text(item.food.iconEmoji, style: const TextStyle(fontSize: 20)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        Text("Portion: ${item.grams.toStringAsFixed(0)} gm", style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                                        onPressed: () => setState(() {
                                          if (item.grams > 25) {
                                            item.grams -= 25;
                                          } else {
                                            currentItems.removeAt(i);
                                          }
                                        }),
                                      ),
                                      Text("${item.grams.toStringAsFixed(0)}g", style: const TextStyle(fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
                                        onPressed: () => setState(() => item.grams += 25),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("🔥 ${item.totalCalories.toStringAsFixed(0)} kcal", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706), fontSize: 12)),
                                  Text("P: ${item.totalProtein.toStringAsFixed(1)}g", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue, fontSize: 11)),
                                  Text("C: ${item.totalCarbs.toStringAsFixed(1)}g", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green, fontSize: 11)),
                                  Text("F: ${item.totalFats.toStringAsFixed(1)}g", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent, fontSize: 11)),
                                ],
                              ),
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
