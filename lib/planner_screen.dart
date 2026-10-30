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
        SnackBar(content: Text("Plan saved successfully for $clientName!")),
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

  void _showAddFoodModal() {
    final foods = AppDataSheets.foodDatabase;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Select Food Item", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
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
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Select Exercises & Protocols", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          // ================= DIET TAB =================
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
                ...activeMealItems.map((entry) => Card(
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
                                  Text("${entry.totalCalories.toStringAsFixed(0)} kcal (P:${entry.totalProtein.toStringAsFixed(0)}g C:${entry.totalCarbs.toStringAsFixed(0)}g F:${entry.totalFats.toStringAsFixed(0)}g)",
                                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              child: TextFormField(
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
                    )),
            ],
          ),

          // ================= WORKOUT TAB =================
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
                ...activeDayWorkouts.map((ex) => Card(
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
                    )),
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
