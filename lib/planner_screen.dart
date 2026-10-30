import 'package:flutter/material.dart';
import 'models.dart';
import 'database.dart';
import 'pdf_service.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({Key? key}) : super(key: key);

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  final FiveMealPlan _plan = FiveMealPlan();
  final List<WorkoutExercise> _selectedWorkouts = [];

  int _totalMealsToAssign = 3;
  int _activeMealIndex = 1;

  final TextEditingController _clientName = TextEditingController();
  final TextEditingController _targetCal = TextEditingController(text: "2000");

  final List<String> _mealTitles = [
    "Meal 1 (Breakfast)",
    "Meal 2 (Mid-Morning)",
    "Meal 3 (Lunch)",
    "Meal 4 (Evening Snack)",
    "Meal 5 (Dinner)"
  ];

  final List<String> _repOptions = [
    "6-8 reps (Strength)",
    "8-10 reps",
    "10-12 reps (Hypertrophy)",
    "12-15 reps",
    "15-20 reps (Endurance)",
    "Till Failure",
    "45-60 sec hold",
  ];

  final List<String> _restOptions = [
    "30s",
    "45s",
    "60s",
    "90s",
    "120s",
  ];

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
  }

  void _openFoodSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.75,
        child: Column(
          children: [
            const SizedBox(height: 14),
            Text("Add Food to ${_mealTitles[_activeMealIndex - 1]}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: AppDataSheets.foodDatabase.length,
                itemBuilder: (ctx, i) {
                  final food = AppDataSheets.foodDatabase[i];
                  return ListTile(
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                      child: Icon(food.icon, color: const Color(0xFF1E293B)),
                    ),
                    title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text("Per 100g: ${food.per100gCalories.toStringAsFixed(0)} kcal | P: ${food.per100gProtein}g"),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.black),
                      onPressed: () {
                        setState(() {
                          PortionUnit defaultUnit = PortionUnit.gm;
                          double defQty = 100.0;
                          if (food.id == '2' || food.id == '3' || food.id == '9' || food.id == '14') {
                            defaultUnit = PortionUnit.piece;
                            defQty = 1.0;
                          } else if (food.id == '11') {
                            defaultUnit = PortionUnit.tbsp;
                            defQty = 1.0;
                          } else if (food.id == '4') {
                            defaultUnit = PortionUnit.scoop;
                            defQty = 1.0;
                          }
                          _plan.getMealList(_activeMealIndex).add(MealEntry(food: food, quantity: defQty, unit: defaultUnit));
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text("Add", style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _openWorkoutSheet() {
    String selectedCategory = "Chest";
    final categories = ["Chest", "Back", "Legs", "Shoulders", "Arms", "Core"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final filteredExercises = AppDataSheets.exerciseMasterList
              .where((e) => e.category.toLowerCase() == selectedCategory.toLowerCase())
              .toList();

          return FractionallySizedBox(
            heightFactor: 0.85,
            child: Column(
              children: [
                const SizedBox(height: 14),
                const Text("Select Workout Exercises", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: categories.map((cat) {
                      bool isSel = selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSel,
                          selectedColor: const Color(0xFFF59E0B),
                          onSelected: (_) => setSheetState(() => selectedCategory = cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredExercises.length,
                    itemBuilder: (c, i) {
                      final ex = filteredExercises[i];
                      bool alreadyAdded = _selectedWorkouts.any((w) => w.name == ex.name);

                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE2E8F0),
                          child: Icon(Icons.fitness_center, color: Color(0xFF1E293B), size: 20),
                        ),
                        title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text("Default: ${ex.sets} Sets • ${ex.reps}"),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: alreadyAdded ? Colors.grey : const Color(0xFF1E293B),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: alreadyAdded
                              ? null
                              : () {
                                  setState(() {
                                    _selectedWorkouts.add(WorkoutExercise(
                                      id: ex.id,
                                      name: ex.name,
                                      category: ex.category,
                                      sets: ex.sets,
                                      reps: ex.reps,
                                      restSeconds: ex.restSeconds,
                                    ));
                                  });
                                  setSheetState(() {});
                                },
                          child: Text(alreadyAdded ? "Added" : "Add"),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<MealEntry> currentMealItems = _plan.getMealList(_activeMealIndex);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("fitwithRahul Builder", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E293B),
        centerTitle: true,
        bottom: TabBar(
          controller: _mainTabController,
          indicatorColor: const Color(0xFFF59E0B),
          labelColor: const Color(0xFFF59E0B),
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.restaurant), text: "DIET PLAN"),
            Tab(icon: Icon(Icons.fitness_center), text: "WORKOUT PLAN"),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(flex: 2, child: TextField(controller: _clientName, decoration: const InputDecoration(labelText: "Client Name", border: OutlineInputBorder(), filled: true, fillColor: Colors.white))),
                const SizedBox(width: 8),
                Expanded(flex: 1, child: TextField(controller: _targetCal, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Target Cal", border: OutlineInputBorder(), filled: true, fillColor: Colors.white))),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: [
                // TAB 1: DIET PLAN
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: const Color(0xFF0F172A),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total: ${_plan.grandCalories.toStringAsFixed(0)} kcal", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
                          Text("P: ${_plan.grandProtein.toStringAsFixed(0)}g | C: ${_plan.grandCarbs.toStringAsFixed(0)}g | F: ${_plan.grandFats.toStringAsFixed(0)}g", style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Meals Count:", style: TextStyle(fontWeight: FontWeight.bold)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: List.generate(_totalMealsToAssign, (idx) {
                          int m = idx + 1;
                          bool sel = _activeMealIndex == m;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text("Meal $m (${_plan.getMealList(m).length})"),
                              selected: sel,
                              selectedColor: const Color(0xFFF59E0B),
                              onSelected: (_) => setState(() => _activeMealIndex = m),
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
                          Text(_mealTitles[_activeMealIndex - 1], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                      child: currentMealItems.isEmpty
                          ? const Center(child: Text("Empty meal. Click '+ Add Food'."))
                          : ListView.builder(
                              itemCount: currentMealItems.length,
                              itemBuilder: (ctx, i) {
                                final item = currentMealItems[i];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 38,
                                              height: 38,
                                              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                                              child: Icon(item.food.icon, size: 22, color: const Color(0xFF1E293B)),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(item.food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                  Text(item.displayPortion, style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.w600)),
                                                ],
                                              ),
                                            ),
                                            DropdownButton<PortionUnit>(
                                              value: item.unit,
                                              underline: const SizedBox(),
                                              isDense: true,
                                              items: PortionUnit.values.map((u) {
                                                return DropdownMenuItem(value: u, child: Text(u.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)));
                                              }).toList(),
                                              onChanged: (newUnit) {
                                                if (newUnit != null) {
                                                  setState(() {
                                                    item.unit = newUnit;
                                                    item.quantity = newUnit == PortionUnit.gm ? 50.0 : 1.0;
                                                  });
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                                              onPressed: () => setState(() {
                                                double step = item.unit == PortionUnit.gm ? 25.0 : 1.0;
                                                if (item.quantity > step) {
                                                  item.quantity -= step;
                                                } else {
                                                  currentMealItems.removeAt(i);
                                                }
                                              }),
                                            ),
                                            Text(
                                              "${item.quantity.toStringAsFixed(0)}",
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
                                              onPressed: () => setState(() {
                                                double step = item.unit == PortionUnit.gm ? 25.0 : 1.0;
                                                item.quantity += step;
                                              }),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("🔥 ${item.totalCalories.toStringAsFixed(0)} kcal", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706), fontSize: 11)),
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
                  ],
                ),

                // TAB 2: WORKOUT PLANNER (Custom Sets, Reps & Rest Control)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Assigned Exercises (${_selectedWorkouts.length})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ElevatedButton.icon(
                            onPressed: _openWorkoutSheet,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text("Select Workouts"),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _selectedWorkouts.isEmpty
                          ? const Center(child: Text("No exercises added yet.\nClick 'Select Workouts' above.", textAlign: TextAlign.center))
                          : ListView.builder(
                              itemCount: _selectedWorkouts.length,
                              itemBuilder: (ctx, i) {
                                final ex = _selectedWorkouts[i];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Title & Delete
                                        Row(
                                          children: [
                                            Chip(
                                              label: Text(ex.category, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                              backgroundColor: const Color(0xFF1E293B),
                                              visualDensity: VisualDensity.compact,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                              onPressed: () => setState(() => _selectedWorkouts.removeAt(i)),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 10),

                                        // Sets, Reps, Rest Adjustment Bar
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Sets Controls (+ / -)
                                            Row(
                                              children: [
                                                const Text("Sets: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                IconButton(
                                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 18),
                                                  onPressed: () => setState(() {
                                                    if (ex.sets > 1) ex.sets -= 1;
                                                  }),
                                                ),
                                                Text("${ex.sets}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                IconButton(
                                                  icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 18),
                                                  onPressed: () => setState(() {
                                                    if (ex.sets < 10) ex.sets += 1;
                                                  }),
                                                ),
                                              ],
                                            ),

                                            // Reps Dropdown
                                            DropdownButton<String>(
                                              value: _repOptions.contains(ex.reps) ? ex.reps : _repOptions[2],
                                              underline: const SizedBox(),
                                              isDense: true,
                                              items: _repOptions.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)))).toList(),
                                              onChanged: (val) {
                                                if (val != null) setState(() => ex.reps = val);
                                              },
                                            ),

                                            // Rest Dropdown
                                            DropdownButton<String>(
                                              value: _restOptions.contains(ex.restSeconds) ? ex.restSeconds : _restOptions[2],
                                              underline: const SizedBox(),
                                              isDense: true,
                                              items: _restOptions.map((rest) => DropdownMenuItem(value: rest, child: Text("Rest: $rest", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)))).toList(),
                                              onChanged: (val) {
                                                if (val != null) setState(() => ex.restSeconds = val);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            color: Colors.white,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text("Share Plan to WhatsApp", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), padding: const EdgeInsets.symmetric(vertical: 12)),
              onPressed: () {
                PdfService.sharePdf(
                  clientName: _clientName.text.isEmpty ? "Client" : _clientName.text,
                  targetCalories: double.tryParse(_targetCal.text) ?? 2000.0,
                  plan: _plan,
                  workouts: _selectedWorkouts.isEmpty ? AppDataSheets.exerciseMasterList.take(6).toList() : _selectedWorkouts,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
