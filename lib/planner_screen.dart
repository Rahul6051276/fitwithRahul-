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
  late TabController _tabController;
  final TextEditingController _clientNameController = TextEditingController(text: "Client");
  final TextEditingController _targetCalController = TextEditingController(text: "2000");
  final TextEditingController _waterController = TextEditingController(text: "3.5 - 4 Liters");
  final TextEditingController _notesController = TextEditingController(text: "Creatine 3-5g daily. Progressive Overload prioritize karein.");

  String _fitnessGoal = 'Fat Loss';
  final List<String> _goalsList = ['Fat Loss', 'Muscle Gain', 'Body Recomp', 'Maintenance'];

  int _mealsCount = 3;
  int _activeMealIndex = 1;
  FiveMealPlan _plan = FiveMealPlan();

  String _activeWorkoutDay = 'Monday';
  final List<String> _weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  WeeklyWorkoutRoutine _weeklyRoutine = WeeklyWorkoutRoutine();

  String _exerciseFilter = 'Chest';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initCustomData();
  }

  Future<void> _initCustomData() async {
    await AppDataSheets.loadCustomData();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _clientNameController.dispose();
    _targetCalController.dispose();
    _waterController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveCurrentClient() async {
    final prefs = await SharedPreferences.getInstance();
    final clientName = _clientNameController.text.trim();
    if (clientName.isEmpty) return;

    final clientPlan = SavedClientPlan(
      clientName: clientName,
      fitnessGoal: _fitnessGoal,
      targetCalories: double.tryParse(_targetCalController.text) ?? 2000,
      waterIntake: _waterController.text,
      coachNotes: _notesController.text,
      totalMeals: _mealsCount,
      plan: _plan,
      weeklyWorkout: _weeklyRoutine,
    );

    await prefs.setString('plan_$clientName', jsonEncode(clientPlan.toJson()));
    List<String> list = prefs.getStringList('client_list') ?? [];
    if (!list.contains(clientName)) {
      list.add(clientName);
      await prefs.setStringList('client_list', list);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Plan saved successfully for $clientName ($_fitnessGoal)!")),
      );
    }
  }

  Future<void> _loadClientDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('client_list') ?? [];

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Saved Clients", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: list.isEmpty
              ? const Text("No clients saved yet.")
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (c, idx) {
                    final name = list[idx];
                    return ListTile(
                      title: Text(name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () async {
                          await prefs.remove('plan_$name');
                          list.remove(name);
                          await prefs.setStringList('client_list', list);
                          Navigator.pop(ctx);
                          _loadClientDialog();
                        },
                      ),
                      onTap: () {
                        final raw = prefs.getString('plan_$name');
                        if (raw != null) {
                          final saved = SavedClientPlan.fromJson(jsonDecode(raw));
                          setState(() {
                            _clientNameController.text = saved.clientName;
                            _fitnessGoal = saved.fitnessGoal;
                            _targetCalController.text = saved.targetCalories.toStringAsFixed(0);
                            _waterController.text = saved.waterIntake;
                            _notesController.text = saved.coachNotes;
                            _mealsCount = saved.totalMeals;
                            _plan = saved.plan;
                            _weeklyRoutine = saved.weeklyWorkout;
                          });
                        }
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _showCreateFoodDialog(VoidCallback onDone) {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final proCtrl = TextEditingController();
    final carbCtrl = TextEditingController();
    final fatCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Food Item", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Food Name")),
              TextField(controller: calCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Calories per 100g")),
              TextField(controller: proCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Protein (g) per 100g")),
              TextField(controller: carbCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Carbs (g) per 100g")),
              TextField(controller: fatCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Fats (g) per 100g")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              final newFood = FoodItem(
                id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
                name: name,
                icon: Icons.fastfood,
                per100gCalories: double.tryParse(calCtrl.text) ?? 100,
                per100gProtein: double.tryParse(proCtrl.text) ?? 0,
                per100gCarbs: double.tryParse(carbCtrl.text) ?? 0,
                per100gFat: double.tryParse(fatCtrl.text) ?? 0,
              );
              await AppDataSheets.addCustomFood(newFood);
              Navigator.pop(ctx);
              onDone();
              setState(() {});
            },
            child: const Text("Save Food", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCreateExerciseDialog(VoidCallback onDone) {
    final nameCtrl = TextEditingController();
    final setsCtrl = TextEditingController(text: "3");
    final repsCtrl = TextEditingController(text: "10-12 reps");
    final restCtrl = TextEditingController(text: "60s");
    String selectedCat = _exerciseFilter;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: const Text("Add New Exercise", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Exercise Name")),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCat,
                  decoration: const InputDecoration(labelText: "Category"),
                  items: ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Cardio', 'Floor', 'HIIT', 'Core']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDlgState(() => selectedCat = v);
                  },
                ),
                TextField(controller: setsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Default Sets")),
                TextField(controller: repsCtrl, decoration: const InputDecoration(labelText: "Default Reps / Duration")),
                TextField(controller: restCtrl, decoration: const InputDecoration(labelText: "Rest Time")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final newEx = WorkoutExercise(
                  id: 'cust_ex_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  category: selectedCat,
                  sets: int.tryParse(setsCtrl.text) ?? 3,
                  reps: repsCtrl.text.trim().isEmpty ? "10-12 reps" : repsCtrl.text.trim(),
                  restSeconds: restCtrl.text.trim().isEmpty ? "60s" : restCtrl.text.trim(),
                );
                await AppDataSheets.addCustomExercise(newEx);
                Navigator.pop(ctx);
                onDone();
                setState(() {});
              },
              child: const Text("Save Exercise", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFoodModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final foods = AppDataSheets.foodDatabase;
          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            maxChildSize: 0.92,
            minChildSize: 0.5,
            expand: false,
            builder: (_, scrollCtrl) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Select Food Item", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                        icon: const Icon(Icons.add, size: 16, color: Colors.black),
                        label: const Text("+ Custom Food", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          _showCreateFoodDialog(() {
                            setModalState(() {});
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollCtrl,
                    itemCount: foods.length,
                    itemBuilder: (c, idx) {
                      final food = foods[idx];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFFEF3C7),
                          child: Icon(food.icon, color: const Color(0xFFF59E0B)),
                        ),
                        title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text("${food.per100gCalories.toStringAsFixed(0)} kcal / 100g | P: ${food.per100gProtein}g | C: ${food.per100gCarbs}g | F: ${food.per100gFat}g"),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                          child: const Text("Add", style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            setState(() {
                              _plan.getMealList(_activeMealIndex).add(MealEntry(food: food));
                            });
                            Navigator.pop(ctx);
                          },
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

  void _showAddWorkoutModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final categories = ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Cardio', 'Floor', 'HIIT', 'Core'];
          final filtered = AppDataSheets.exerciseMasterList.where((e) => e.category == _exerciseFilter).toList();

          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            maxChildSize: 0.92,
            minChildSize: 0.5,
            expand: false,
            builder: (_, scrollCtrl) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Select Exercises", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                        icon: const Icon(Icons.add, size: 16, color: Colors.black),
                        label: const Text("+ Custom Exercise", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          _showCreateExerciseDialog(() {
                            setModalState(() {});
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = _exerciseFilter == cat;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: const Color(0xFFF59E0B),
                          onSelected: (val) {
                            if (val) {
                              setModalState(() => _exerciseFilter = cat);
                              setState(() => _exerciseFilter = cat);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollCtrl,
                    itemCount: filtered.length,
                    itemBuilder: (c, idx) {
                      final ex = filtered[idx];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE2E8F0),
                          child: Icon(
                            ex.category == 'Cardio'
                                ? Icons.directions_run
                                : ex.category == 'HIIT'
                                    ? Icons.bolt
                                    : Icons.fitness_center,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text("Target: ${ex.sets} Sets • ${ex.reps} • Rest: ${ex.restSeconds}"),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                          child: const Text("Add", style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            setState(() {
                              _weeklyRoutine.days[_activeWorkoutDay]!.add(WorkoutExercise(
                                id: ex.id,
                                name: ex.name,
                                category: ex.category,
                                sets: ex.sets,
                                reps: ex.reps,
                                restSeconds: ex.restSeconds,
                              ));
                            });
                            Navigator.pop(ctx);
                          },
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
    final activeMealItems = _plan.getMealList(_activeMealIndex);
    final activeDayWorkouts = _weeklyRoutine.days[_activeWorkoutDay] ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text("fitwithRahul Builder", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open, color: Color(0xFFF59E0B)),
            onPressed: _loadClientDialog,
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveCurrentClient,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF59E0B),
          labelColor: const Color(0xFFF59E0B),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.restaurant_menu), text: "DIET PLAN"),
            Tab(icon: Icon(Icons.calendar_month), text: "WEEKLY WORKOUT"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // DIET TAB
          ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _clientNameController,
                      decoration: const InputDecoration(labelText: "Client Name", border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _targetCalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Target Cal", border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // FITNESS GOAL SELECTOR
              Row(
                children: [
                  const Text("Goal: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _goalsList.map((g) {
                          final isSelected = _fitnessGoal == g;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: ChoiceChip(
                              label: Text(g, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                              selected: isSelected,
                              selectedColor: const Color(0xFFF59E0B),
                              onSelected: (val) {
                                if (val) setState(() => _fitnessGoal = g);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _waterController,
                      decoration: const InputDecoration(labelText: "Daily Water Target", border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: "Coach Notes / Supplements", border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total: ${_plan.grandCalories.toStringAsFixed(0)} kcal",
                        style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      "P: ${_plan.grandProtein.toStringAsFixed(0)}g | C: ${_plan.grandCarbs.toStringAsFixed(0)}g | F: ${_plan.grandFats.toStringAsFixed(0)}g",
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Meals Count: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  ...[3, 4, 5].map((cnt) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text("$cnt"),
                          selected: _mealsCount == cnt,
                          selectedColor: const Color(0xFFFDE68A),
                          onSelected: (val) {
                            if (val) setState(() => _mealsCount = cnt);
                          },
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_mealsCount, (idx) {
                    final mealNum = idx + 1;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text("Meal $mealNum (${_plan.getMealList(mealNum).length})"),
                        selected: _activeMealIndex == mealNum,
                        selectedColor: const Color(0xFFF59E0B),
                        onSelected: (val) {
                          if (val) setState(() => _activeMealIndex = mealNum);
                        },
                      ),
                    );
                  }),
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Meal $_activeMealIndex Items", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text("Add Food", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    onPressed: _showAddFoodModal,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (activeMealItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text("Empty meal. Click '+ Add Food'.")),
                )
              else
                ...activeMealItems.asMap().entries.map((entryMap) {
                  final idx = entryMap.key;
                  final entry = entryMap.value;
                  return Card(
                    key: ValueKey('meal_${_activeMealIndex}_item_${entry.food.id}_${entry.quantity}_$idx'),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          CircleAvatar(child: Icon(entry.food.icon, size: 18)),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  "${entry.totalCalories.toStringAsFixed(0)} kcal (P:${entry.totalProtein.toStringAsFixed(0)}g C:${entry.totalCarbs.toStringAsFixed(0)}g F:${entry.totalFats.toStringAsFixed(0)}g)",
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 55,
                            child: TextFormField(
                              key: ValueKey('input_${entry.food.id}_${entry.quantity}'),
                              initialValue: entry.quantity.toStringAsFixed(0),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(isDense: true),
                              onChanged: (v) {
                                setState(() {
                                  entry.quantity = double.tryParse(v) ?? entry.quantity;
                                });
                              },
                            ),
                          ),
                          DropdownButton<PortionUnit>(
                            value: entry.unit,
                            underline: const SizedBox(),
                            items: PortionUnit.values.map((u) => DropdownMenuItem(value: u, child: Text(u.name))).toList(),
                            onChanged: (u) {
                              if (u != null) setState(() => entry.unit = u);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => setState(() => activeMealItems.remove(entry)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),

          // WORKOUT TAB
          ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Text("Select Training Day:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _weekDays.map((day) {
                    final count = _weeklyRoutine.days[day]?.length ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: ChoiceChip(
                        label: Text("$day ($count)"),
                        selected: _activeWorkoutDay == day,
                        selectedColor: const Color(0xFFF59E0B),
                        onSelected: (val) {
                          if (val) setState(() => _activeWorkoutDay = day);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("$_activeWorkoutDay Protocol", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text("Add Workout", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    onPressed: _showAddWorkoutModal,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (activeDayWorkouts.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      "No exercises added for $_activeWorkoutDay.\nTap '+ Add Workout' to add weights, cardio, or HIIT.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...activeDayWorkouts.asMap().entries.map((entryMap) {
                  final idx = entryMap.key;
                  final ex = entryMap.value;
                  return Card(
                    key: ValueKey('workout_${_activeWorkoutDay}_${ex.id}_$idx'),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text("${ex.category} • Rest: ${ex.restSeconds}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 45,
                            child: TextFormField(
                              key: ValueKey('ex_set_${ex.id}_${ex.sets}'),
                              initialValue: ex.sets.toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: "Sets", isDense: true),
                              onChanged: (v) => ex.sets = int.tryParse(v) ?? ex.sets,
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              key: ValueKey('ex_rep_${ex.id}_${ex.reps}'),
                              initialValue: ex.reps,
                              decoration: const InputDecoration(labelText: "Reps/Dur", isDense: true),
                              onChanged: (v) => ex.reps = v,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => setState(() => activeDayWorkouts.remove(ex)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.restaurant, color: Colors.white, size: 18),
                label: const Text("Share Diet PDF", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: () async {
                  await PdfService.shareDietPdf(
                    clientName: _clientNameController.text.trim().isEmpty ? "Client" : _clientNameController.text.trim(),
                    fitnessGoal: _fitnessGoal,
                    targetCalories: double.tryParse(_targetCalController.text) ?? 2000,
                    waterTarget: _waterController.text,
                    coachNotes: _notesController.text,
                    plan: _plan,
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.fitness_center, color: Colors.white, size: 18),
                label: const Text("Share Workout PDF", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: () async {
                  await PdfService.shareWorkoutPdf(
                    clientName: _clientNameController.text.trim().isEmpty ? "Client" : _clientNameController.text.trim(),
                    fitnessGoal: _fitnessGoal,
                    coachNotes: _notesController.text,
                    routine: _weeklyRoutine,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
