import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  FiveMealPlan _plan = FiveMealPlan();
  List<WorkoutExercise> _selectedWorkouts = [];

  int _totalMealsToAssign = 3;
  int _activeMealIndex = 1;

  final TextEditingController _clientName = TextEditingController();
  final TextEditingController _targetCal = TextEditingController(text: "2000");
  final TextEditingController _waterTarget = TextEditingController(text: "3.5 - 4 Liters");
  final TextEditingController _coachNotes = TextEditingController(text: "Creatine 3-5g post workout. Sleep 7-8 hours daily.");

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

  final List<String> _restOptions = ["30s", "45s", "60s", "90s", "120s"];

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
  }

  // Save Plan Locally
  Future<void> _saveCurrentPlan() async {
    final name = _clientName.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pehle Client ka naam daalein!")),
      );
      return;
    }

    final sp = await SharedPreferences.getInstance();
    final clientPlan = SavedClientPlan(
      clientName: name,
      targetCalories: double.tryParse(_targetCal.text) ?? 2000.0,
      waterIntake: _waterTarget.text.trim(),
      coachNotes: _coachNotes.text.trim(),
      totalMeals: _totalMealsToAssign,
      plan: _plan,
      workouts: _selectedWorkouts,
    );

    await sp.setString('client_$name', jsonEncode(clientPlan.toJson()));

    List<String> list = sp.getStringList('all_clients') ?? [];
    if (!list.contains(name)) {
      list.add(name);
      await sp.setStringList('all_clients', list);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$name ka plan phone me save ho gaya! ✅")),
      );
    }
  }

  // Load Saved Client Modal
  Future<void> _openSavedClientsList() async {
    final sp = await SharedPreferences.getInstance();
    List<String> clients = sp.getStringList('all_clients') ?? [];

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (c, setSheet) => Column(
          children: [
            const SizedBox(height: 14),
            const Text("Saved Client Plans", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            Expanded(
              child: clients.isEmpty
                  ? const Center(child: Text("Abhi koi saved client nahi hai."))
                  : ListView.builder(
                      itemCount: clients.length,
                      itemBuilder: (context, i) {
                        final cName = clients[i];
                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF1E293B),
                            child: Icon(Icons.person, color: Color(0xFFF59E0B)),
                          ),
                          title: Text(cName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text("Tap to load full diet & workout"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () async {
                              await sp.remove('client_$cName');
                              clients.remove(cName);
                              await sp.setStringList('all_clients', clients);
                              setSheet(() {});
                              setState(() {});
                            },
                          ),
                          onTap: () {
                            final raw = sp.getString('client_$cName');
                            if (raw != null) {
                              final saved = SavedClientPlan.fromJson(jsonDecode(raw));
                              setState(() {
                                _clientName.text = saved.clientName;
                                _targetCal.text = saved.targetCalories.toStringAsFixed(0);
                                _waterTarget.text = saved.waterIntake;
                                _coachNotes.text = saved.coachNotes;
                                _totalMealsToAssign = saved.totalMeals;
                                _plan = saved.plan;
                                _selectedWorkouts = saved.workouts;
                              });
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("$cName ka data load ho gaya!")),
                              );
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_shared, color: Color(0xFFF59E0B)),
            tooltip: "Saved Clients",
            onPressed: _openSavedClientsList,
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            tooltip: "Save Plan",
            onPressed: _saveCurrentPlan,
          ),
        ],
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
          // Client Details Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _clientName,
                    decoration: const InputDecoration(
                      labelText: "Client Name",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _targetCal,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Target Cal",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Water & Notes Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _waterTarget,
                    decoration: const InputDecoration(
                      labelText: "Daily Water Target",
                      prefixIcon: Icon(Icons.water_drop, color: Colors.blueAccent, size: 20),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _coachNotes,
                    decoration: const InputDecoration(
                      labelText: "Coach Notes / Supps",
                      prefixIcon: Icon(Icons.note_alt, color: Colors.amber, size: 20),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Tab Bar Views
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: [
                // TAB 1: DIET PLANNER
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

                // TAB 2: WORKOUT PLANNER
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
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
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
                                            DropdownButton<String>(
                                              value: _repOptions.contains(ex.reps) ? ex.reps : _repOptions[2],
                                              underline: const SizedBox(),
                                              isDense: true,
                                              items: _repOptions.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)))).toList(),
                                              onChanged: (val) {
                                                if (val != null) setState(() => ex.reps = val);
                                              },
                                            ),
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

          // Bottom WhatsApp PDF Share Button
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
                  waterTarget: _waterTarget.text.trim(),
                  coachNotes: _coachNotes.text.trim(),
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
