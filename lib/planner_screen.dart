import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'database.dart';
import 'pdf_service.dart';
import 'client_overview_screen.dart';

class PlannerScreen extends StatefulWidget {
  final ClientProfile? initialClient;

  const PlannerScreen({Key? key, this.initialClient}) : super(key: key);

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late TextEditingController _clientNameController;
  late TextEditingController _targetCalController;
  late TextEditingController _waterController;
  late TextEditingController _notesController;

  late ClientProfile _client;
  int _selectedMealIndex = 0;
  String _selectedDay = 'Mon';

  final FiveMealPlan _dietPlan = FiveMealPlan();
  final Map<String, List<WorkoutExercise>> _weeklyWorkout = {
    'Mon': [],
    'Tue': [],
    'Wed': [],
    'Thu': [],
    'Fri': [],
    'Sat': [],
  };

  List<FoodItem> _allFoods = [];
  Map<String, List<String>> _allExercises = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _client = widget.initialClient ??
        ClientProfile(
          name: "Client",
          goal: "Fat Loss",
          targetCalories: 2000,
        );

    _clientNameController = TextEditingController(text: _client.name);
    _targetCalController =
        TextEditingController(text: _client.targetCalories.toStringAsFixed(0));
    _waterController = TextEditingController(text: _client.dailyWater);

    String defaultNotes = _client.condition != MedicalCondition.none
        ? "Medical Profile: ${_client.condition.name.toUpperCase()} (Low-GI priority). Progressive Overload maintain karein."
        : "Creatine 3-5g daily. Progressive Overload prioritize karein.";

    _notesController = TextEditingController(
        text: _client.notes.isNotEmpty ? _client.notes : defaultNotes);

    _loadDatabases();
  }

  void _loadDatabases() {
    setState(() {
      try {
        _allFoods = List.from(AppDatabase.foods);
        _allExercises = Map.from(AppDatabase.exercisesByCategory);
      } catch (_) {
        _allFoods = [
          const FoodItem(id: 'wh_egg', name: 'Whole Boiled Egg', calories: 78, protein: 6.3, carbs: 0.6, fats: 5.3, unit: 'pcs', pieceWeight: 50.0),
          const FoodItem(id: 'egg_white', name: 'Egg White (Boiled)', calories: 17, protein: 3.6, carbs: 0.2, fats: 0.1, unit: 'pcs', pieceWeight: 33.0),
          const FoodItem(id: 'soya_chunks', name: 'Soya Chunks (Raw)', calories: 345, protein: 52.0, carbs: 33.0, fats: 0.5, unit: 'g'),
          const FoodItem(id: 'low_fat_paneer', name: 'Low Fat Paneer', calories: 200, protein: 20.0, carbs: 4.0, fats: 12.0, unit: 'g'),
          const FoodItem(id: 'whey_protein', name: 'Whey Protein', calories: 120, protein: 24.0, carbs: 2.5, fats: 1.5, unit: 'scoop', scoopWeight: 30.0),
          const FoodItem(id: 'rolled_oats', name: 'Rolled Oats (Raw)', calories: 389, protein: 16.9, carbs: 66.3, fats: 6.9, unit: 'g'),
          const FoodItem(id: 'white_rice', name: 'White Rice (Cooked)', calories: 130, protein: 2.7, carbs: 28.2, fats: 0.3, unit: 'g'),
          const FoodItem(id: 'wheat_roti', name: 'Wheat Roti (Plain)', calories: 120, protein: 3.5, carbs: 22.0, fats: 2.0, unit: 'pcs', pieceWeight: 35.0),
          const FoodItem(id: 'peanut_butter', name: 'Peanut Butter (Unsweetened)', calories: 95, protein: 4.0, carbs: 3.0, fats: 8.0, unit: 'tbsp', tbspWeight: 16.0),
        ];
        _allExercises = {
          'Chest': ['Barbell Flat Bench Press', 'Incline Dumbbell Press', 'Standard Push-Ups'],
          'Back': ['Lat Pulldown (Wide Grip)', 'Barbell Bent-Over Row', 'Seated Cable Row'],
          'Legs': ['Barbell Back Squat', 'Romanian Deadlift (RDL)', 'Leg Press Machine'],
          'Shoulders': ['Overhead Dumbbell Shoulder Press', 'Dumbbell Lateral Raise', 'Cable Face Pulls'],
          'Arms': ['EZ Bar Bicep Curl', 'Triceps Rope Pushdown'],
          'Core': ['Standard Elbow Plank Hold', 'Russian Twists'],
          'HIIT': ['Burpees (Chest-to-Floor)', 'Battle Ropes Waves', 'Kettlebell Swings'],
        };
      }
    });
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

  List<MealEntry> get _currentMealList {
    switch (_selectedMealIndex) {
      case 0: return _dietPlan.meal1;
      case 1: return _dietPlan.meal2;
      case 2: return _dietPlan.meal3;
      case 3: return _dietPlan.meal4;
      case 4: return _dietPlan.meal5;
      default: return _dietPlan.meal1;
    }
  }

  // --- SAVE CLIENT RECORD ---
  Future<void> _saveCurrentClient() async {
    final name = _clientNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kripya Client Name enter karein!")),
      );
      return;
    }

    _client.name = name;
    _client.targetCalories = double.tryParse(_targetCalController.text) ?? 2000;
    _client.dailyWater = _waterController.text.trim();
    _client.notes = _notesController.text.trim();
    _client.dietPlan = _dietPlan;
    _client.weeklyWorkout = _weeklyWorkout;

    final prefs = await SharedPreferences.getInstance();
    List<String> savedList = prefs.getStringList('saved_clients_list') ?? [];
    savedList.removeWhere((item) {
      try {
        final existing = ClientProfile.fromJson(item);
        return existing.name.toLowerCase() == name.toLowerCase();
      } catch (_) {
        return false;
      }
    });

    savedList.insert(0, _client.toJson());
    await prefs.setStringList('saved_clients_list', savedList);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF10B981),
        content: Text("Client '$name' ka profile successfully save ho gaya!"),
      ),
    );
  }

  // --- SAVED CLIENTS LIST VIEW ---
  Future<void> _openSavedClientsList() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> rawList = prefs.getStringList('saved_clients_list') ?? [];

    List<ClientProfile> profiles = [];
    for (var str in rawList) {
      try {
        profiles.add(ClientProfile.fromJson(str));
      } catch (_) {}
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Saved Clients", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            if (profiles.isEmpty)
              const Expanded(
                child: Center(
                  child: Text("Abhi koi client save nahi hai.", style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: profiles.length,
                  itemBuilder: (c, idx) {
                    final item = profiles[idx];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF0F172A),
                          child: Text(
                            item.name.isNotEmpty ? item.name[0].toUpperCase() : "C",
                            style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${item.goal} | Target: ${item.targetCalories.toStringAsFixed(0)} kcal"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () async {
                            profiles.removeAt(idx);
                            List<String> updatedRaw = profiles.map((p) => p.toJson()).toList();
                            await prefs.setStringList('saved_clients_list', updatedRaw);
                            Navigator.pop(ctx);
                            _openSavedClientsList();
                          },
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClientOverviewScreen(
                                client: item,
                                onEdit: () => _loadClientIntoBuilder(item),
                              ),
                            ),
                          );
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

  void _loadClientIntoBuilder(ClientProfile client) {
    setState(() {
      _client = client;
      _clientNameController.text = client.name;
      _targetCalController.text = client.targetCalories.toStringAsFixed(0);
      _waterController.text = client.dailyWater;
      _notesController.text = client.notes;

      _dietPlan.meal1 = List.from(client.dietPlan.meal1);
      _dietPlan.meal2 = List.from(client.dietPlan.meal2);
      _dietPlan.meal3 = List.from(client.dietPlan.meal3);
      _dietPlan.meal4 = List.from(client.dietPlan.meal4);
      _dietPlan.meal5 = List.from(client.dietPlan.meal5);

      client.weeklyWorkout.forEach((k, v) {
        _weeklyWorkout[k] = List.from(v);
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${client.name} ka plan edit mode me load ho gaya!")),
    );
  }

  // --- AUTO-LOAD WORKOUT SPLITS ---
  void _loadWorkoutSplit(String splitName) {
    setState(() {
      _weeklyWorkout.forEach((k, v) => v.clear());

      if (splitName == '2-Day') {
        _weeklyWorkout['Mon'] = [
          const WorkoutExercise(name: "Barbell Flat Bench Press", sets: "4", reps: "8-10", restSeconds: "90s"),
          const WorkoutExercise(name: "Lat Pulldown (Wide Grip)", sets: "4", reps: "10-12", restSeconds: "75s"),
          const WorkoutExercise(name: "Incline Dumbbell Press", sets: "3", reps: "10-12", restSeconds: "60s"),
          const WorkoutExercise(name: "Seated Cable Row", sets: "3", reps: "10-12", restSeconds: "60s"),
          const WorkoutExercise(name: "Dumbbell Lateral Raise", sets: "4", reps: "12-15", restSeconds: "45s"),
        ];
        _weeklyWorkout['Tue'] = [
          const WorkoutExercise(name: "Barbell Back Squat", sets: "4", reps: "8-10", restSeconds: "120s"),
          const WorkoutExercise(name: "Romanian Deadlift (RDL)", sets: "3", reps: "10-12", restSeconds: "90s"),
          const WorkoutExercise(name: "Leg Press Machine", sets: "3", reps: "12", restSeconds: "75s"),
          const WorkoutExercise(name: "Standing Calf Raise", sets: "4", reps: "15-20", restSeconds: "45s"),
        ];
      } else if (splitName == '3-Day') {
        _weeklyWorkout['Mon'] = [
          const WorkoutExercise(name: "Barbell Flat Bench Press", sets: "4", reps: "8-10", restSeconds: "90s"),
          const WorkoutExercise(name: "Incline Dumbbell Press", sets: "3", reps: "10-12", restSeconds: "75s"),
          const WorkoutExercise(name: "Overhead Dumbbell Shoulder Press", sets: "4", reps: "8-10", restSeconds: "75s"),
          const WorkoutExercise(name: "Dumbbell Lateral Raise", sets: "4", reps: "12-15", restSeconds: "45s"),
          const WorkoutExercise(name: "Triceps Rope Pushdown", sets: "3", reps: "12-15", restSeconds: "60s"),
        ];
        _weeklyWorkout['Wed'] = [
          const WorkoutExercise(name: "Lat Pulldown (Wide Grip)", sets: "4", reps: "10-12", restSeconds: "75s"),
          const WorkoutExercise(name: "Barbell Bent-Over Row", sets: "4", reps: "8-10", restSeconds: "90s"),
          const WorkoutExercise(name: "Seated Cable Row", sets: "3", reps: "10-12", restSeconds: "60s"),
          const WorkoutExercise(name: "Cable Face Pulls", sets: "4", reps: "15", restSeconds: "45s"),
          const WorkoutExercise(name: "EZ Bar Bicep Curl", sets: "3", reps: "10-12", restSeconds: "60s"),
        ];
        _weeklyWorkout['Fri'] = [
          const WorkoutExercise(name: "Barbell Back Squat", sets: "4", reps: "8-10", restSeconds: "120s"),
          const WorkoutExercise(name: "Romanian Deadlift (RDL)", sets: "3", reps: "8-10", restSeconds: "90s"),
          const WorkoutExercise(name: "Leg Press Machine", sets: "3", reps: "10-12", restSeconds: "75s"),
          const WorkoutExercise(name: "Standing Calf Raise", sets: "4", reps: "15-20", restSeconds: "45s"),
        ];
      } else if (splitName == '4-Day') {
        _weeklyWorkout['Mon'] = [
          const WorkoutExercise(name: "Barbell Flat Bench Press", sets: "4", reps: "6-8", restSeconds: "90s"),
          const WorkoutExercise(name: "Lat Pulldown (Wide Grip)", sets: "4", reps: "8-10", restSeconds: "75s"),
          const WorkoutExercise(name: "Overhead Dumbbell Shoulder Press", sets: "3", reps: "8-10", restSeconds: "75s"),
        ];
        _weeklyWorkout['Tue'] = [
          const WorkoutExercise(name: "Barbell Back Squat", sets: "4", reps: "8-10", restSeconds: "120s"),
          const WorkoutExercise(name: "Romanian Deadlift (RDL)", sets: "4", reps: "8-10", restSeconds: "90s"),
          const WorkoutExercise(name: "Standing Calf Raise", sets: "4", reps: "15-20", restSeconds: "45s"),
        ];
        _weeklyWorkout['Thu'] = [
          const WorkoutExercise(name: "Incline Dumbbell Press", sets: "4", reps: "8-10", restSeconds: "75s"),
          const WorkoutExercise(name: "Cable Low-to-High Flyes", sets: "3", reps: "12-15", restSeconds: "60s"),
          const WorkoutExercise(name: "Dumbbell Lateral Raise", sets: "4", reps: "12-15", restSeconds: "45s"),
        ];
        _weeklyWorkout['Fri'] = [
          const WorkoutExercise(name: "Seated Cable Row", sets: "4", reps: "10-12", restSeconds: "75s"),
          const WorkoutExercise(name: "Cable Face Pulls", sets: "4", reps: "15", restSeconds: "45s"),
          const WorkoutExercise(name: "EZ Bar Bicep Curl", sets: "3", reps: "10-12", restSeconds: "60s"),
        ];
      } else if (splitName == 'HIIT') {
        _weeklyWorkout['Tue'] = [
          const WorkoutExercise(name: "Burpees (Chest-to-Floor)", sets: "4", reps: "40s work", restSeconds: "20s"),
          const WorkoutExercise(name: "Standard Push-Ups", sets: "4", reps: "40s work", restSeconds: "60s"),
          const WorkoutExercise(name: "Russian Twists", sets: "4", reps: "40s work", restSeconds: "20s"),
        ];
        _weeklyWorkout['Sat'] = [
          const WorkoutExercise(name: "Battle Ropes Waves", sets: "3", reps: "30s sprint", restSeconds: "30s"),
          const WorkoutExercise(name: "Kettlebell Swings", sets: "3", reps: "20 reps", restSeconds: "30s"),
          const WorkoutExercise(name: "Standard Elbow Plank Hold", sets: "2", reps: "60s hold", restSeconds: "45s"),
        ];
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFF59E0B),
        content: Text("$splitName Workout Template load ho gaya!"),
      ),
    );
  }

  // --- ADD FOOD MODAL WITH SEARCH & CUSTOM FOOD CREATOR ---
  void _openAddFoodDialog() {
    String query = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final filtered = _allFoods
              .where((f) => f.name.toLowerCase().contains(query.toLowerCase()))
              .toList();

          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.80,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search food (Oats, Rice, Egg, Paneer...)",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        query = val;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.add, color: Color(0xFFF59E0B)),
                      label: const Text(
                        "+ Create Custom Food Item",
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showCreateCustomFoodDialog();
                      },
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, idx) {
                      final food = filtered[idx];
                      String unitHint = (food.unit == 'pcs' || food.unit == 'tbsp' || food.unit == 'scoop' || food.unit == 'tsp')
                          ? "per ${food.unit}"
                          : "per 100${food.unit}";

                      return ListTile(
                        title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        subtitle: Text(
                          "${food.calories.toStringAsFixed(0)} kcal | P: ${food.protein}g | C: ${food.carbs}g | F: ${food.fats}g ($unitHint)",
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: const Icon(Icons.add_circle, color: Color(0xFFF59E0B)),
                        onTap: () {
                          setState(() {
                            double defaultQty = (food.unit == 'pcs' || food.unit == 'tbsp' || food.unit == 'scoop' || food.unit == 'tsp')
                                ? 1.0
                                : 100.0;
                            _currentMealList.add(MealEntry(food: food, quantity: defaultQty));
                          });
                          Navigator.pop(ctx);
                        },
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

  // --- DIALOG TO CREATE & ADD CUSTOM FOOD ---
  void _showCreateCustomFoodDialog() {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final proCtrl = TextEditingController();
    final carbCtrl = TextEditingController();
    final fatCtrl = TextEditingController();
    String selectedUnit = 'g';

    showDialog(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            "Add Custom Food",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Food Name (e.g. Sattu, Peanut Chikki)",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedUnit,
                  decoration: const InputDecoration(
                    labelText: "Serving Unit",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: ['g', 'pcs', 'tbsp', 'tsp', 'scoop'].map((u) {
                    return DropdownMenuItem(value: u, child: Text(u));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDlgState(() => selectedUnit = val);
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: calCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Calories", border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: proCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Protein (g)", border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: carbCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Carbs (g)", border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: fatCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Fats (g)", border: OutlineInputBorder(), isDense: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dlgCtx), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;

                final double cals = double.tryParse(calCtrl.text) ?? 0.0;
                final double pro = double.tryParse(proCtrl.text) ?? 0.0;
                final double carb = double.tryParse(carbCtrl.text) ?? 0.0;
                final double fat = double.tryParse(fatCtrl.text) ?? 0.0;

                final newFood = FoodItem(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  calories: cals,
                  protein: pro,
                  carbs: carb,
                  fats: fat,
                  unit: selectedUnit,
                );

                setState(() {
                  _allFoods.insert(0, newFood);
                  double defaultQty = (selectedUnit == 'pcs' || selectedUnit == 'tbsp' || selectedUnit == 'scoop' || selectedUnit == 'tsp')
                      ? 1.0
                      : 100.0;
                  _currentMealList.add(MealEntry(food: newFood, quantity: defaultQty));
                });

                Navigator.pop(dlgCtx);
              },
              child: const Text("Save & Add", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- ADD EXERCISE MODAL (DATABASE SELECTION + PERMANENT CUSTOM ADDON) ---
  void _openAddExerciseDialog() {
    String selectedCategory = _allExercises.keys.isNotEmpty ? _allExercises.keys.first : 'Chest';
    String selectedExName = (_allExercises[selectedCategory]?.isNotEmpty ?? false)
        ? _allExercises[selectedCategory]!.first
        : '';

    final customExNameCtrl = TextEditingController();
    final setsCtrl = TextEditingController(text: "3");
    final repsCtrl = TextEditingController(text: "12");
    final restCtrl = TextEditingController(text: "60s");
    
    bool isCreatingNew = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          List<String> currentExList = _allExercises[selectedCategory] ?? [];

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Text(
              "Add Exercise to $_selectedDay",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setDlgState(() => isCreatingNew = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: !isCreatingNew ? const Color(0xFF0F172A) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Database List",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: !isCreatingNew ? const Color(0xFFF59E0B) : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setDlgState(() => isCreatingNew = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isCreatingNew ? const Color(0xFF0F172A) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "+ New Exercise",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isCreatingNew ? const Color(0xFFF59E0B) : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: "Target Muscle / Category",
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: _allExercises.keys.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (cat) {
                      if (cat != null) {
                        setDlgState(() {
                          selectedCategory = cat;
                          selectedExName = (_allExercises[cat]?.isNotEmpty ?? false)
                              ? _allExercises[cat]!.first
                              : '';
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  if (!isCreatingNew) ...[
                    DropdownButtonFormField<String>(
                      value: currentExList.contains(selectedExName)
                          ? selectedExName
                          : (currentExList.isNotEmpty ? currentExList.first : null),
                      decoration: const InputDecoration(
                        labelText: "Select Exercise",
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      items: currentExList.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(e, style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (ex) {
                        if (ex != null) setDlgState(() => selectedExName = ex);
                      },
                    ),
                  ] else ...[
                    TextField(
                      controller: customExNameCtrl,
                      decoration: const InputDecoration(
                        labelText: "New Exercise Name",
                        hintText: "e.g. Incline Smith Press, Hammer Curls",
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: setsCtrl,
                          decoration: const InputDecoration(labelText: "Sets", isDense: true, border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: repsCtrl,
                          decoration: const InputDecoration(labelText: "Reps", isDense: true, border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: restCtrl,
                          decoration: const InputDecoration(labelText: "Rest", isDense: true, border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () {
                  String finalName = isCreatingNew
                      ? customExNameCtrl.text.trim()
                      : selectedExName;

                  if (finalName.isEmpty) return;

                  setState(() {
                    if (isCreatingNew) {
                      if (!_allExercises.containsKey(selectedCategory)) {
                        _allExercises[selectedCategory] = [];
                      }
                      if (!_allExercises[selectedCategory]!.contains(finalName)) {
                        _allExercises[selectedCategory]!.insert(0, finalName);
                      }
                    }

                    _weeklyWorkout[_selectedDay]?.add(
                      WorkoutExercise(
                        name: finalName,
                        category: selectedCategory,
                        sets: setsCtrl.text.trim(),
                        reps: repsCtrl.text.trim(),
                        restSeconds: restCtrl.text.trim(),
                      ),
                    );
                  });

                  Navigator.pop(ctx);
                },
                child: Text(
                  isCreatingNew ? "Save & Add" : "Add to Routine",
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double planCal = _dietPlan.totalCalories;
    final double targetCal = double.tryParse(_targetCalController.text) ?? 2000;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          "fitwithRahul Builder",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          IconButton(
            tooltip: "Saved Clients",
            icon: const Icon(Icons.folder, color: Color(0xFFF59E0B)),
            onPressed: _openSavedClientsList,
          ),
          IconButton(
            tooltip: "Save Client",
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveCurrentClient,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF59E0B),
          labelColor: const Color(0xFFF59E0B),
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.restaurant_menu), text: "DIET PLAN"),
            Tab(icon: Icon(Icons.fitness_center), text: "WEEKLY WORKOUT"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDietTab(planCal, targetCal),
          _buildWorkoutTab(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.share, color: Colors.white, size: 18),
                label: const Text("Share Diet PDF", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () async {
                  await PdfService.generateAndShareDietPdf(
                    clientName: _clientNameController.text.trim(),
                    fitnessGoal: _client.goal,
                    targetCalories: _targetCalController.text.trim(),
                    dailyWater: _waterController.text.trim(),
                    coachNotes: _notesController.text.trim(),
                    plan: _dietPlan,
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.sports_gymnastics, color: Colors.white, size: 18),
                label: const Text("Share Workout PDF", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () async {
                  await PdfService.generateAndShareWorkoutPdf(
                    clientName: _clientNameController.text.trim(),
                    fitnessGoal: _client.goal,
                    weeklyWorkout: _weeklyWorkout,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIET TAB BUILDER ---
  Widget _buildDietTab(double planCal, double targetCal) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _clientNameController,
                decoration: const InputDecoration(labelText: "Client Name", border: OutlineInputBorder(), isDense: true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _targetCalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Target Cal", border: OutlineInputBorder(), isDense: true),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            const Text("Goal: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ...['Fat Loss', 'Muscle Gain', 'Body Recomp'].map((g) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: ChoiceChip(
                  label: Text(g, style: const TextStyle(fontSize: 11)),
                  selected: _client.goal == g,
                  selectedColor: const Color(0xFFF59E0B),
                  onSelected: (v) => setState(() => _client.goal = g),
                ),
              );
            }).toList(),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _waterController,
                decoration: const InputDecoration(labelText: "Daily Water", border: OutlineInputBorder(), isDense: true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: "Coach Notes", border: OutlineInputBorder(), isDense: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text("Plan / Target", style: TextStyle(color: Colors.white60, fontSize: 10)),
                  Text("${planCal.toStringAsFixed(0)} / ${targetCal.toStringAsFixed(0)}",
                      style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Column(
                children: [
                  const Text("Protein", style: TextStyle(color: Colors.white60, fontSize: 10)),
                  Text("${_dietPlan.totalProtein.toStringAsFixed(0)}g",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Column(
                children: [
                  const Text("Carbs", style: TextStyle(color: Colors.white60, fontSize: 10)),
                  Text("${_dietPlan.totalCarbs.toStringAsFixed(0)}g",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Column(
                children: [
                  const Text("Fats", style: TextStyle(color: Colors.white60, fontSize: 10)),
                  Text("${_dietPlan.totalFats.toStringAsFixed(0)}g",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(5, (index) {
              final count = index == 0
                  ? _dietPlan.meal1.length
                  : index == 1
                      ? _dietPlan.meal2.length
                      : index == 2
                          ? _dietPlan.meal3.length
                          : index == 3
                              ? _dietPlan.meal4.length
                              : _dietPlan.meal5.length;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text("Meal ${index + 1} ($count)", style: const TextStyle(fontSize: 11)),
                  selected: _selectedMealIndex == index,
                  selectedColor: const Color(0xFFF59E0B),
                  onSelected: (v) => setState(() => _selectedMealIndex = index),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Meal ${_selectedMealIndex + 1} Items", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              icon: const Icon(Icons.add, size: 16, color: Colors.black),
              label: const Text("Add Food", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: _openAddFoodDialog,
            ),
          ],
        ),
        const SizedBox(height: 6),

        if (_currentMealList.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: const Text("No food added in this meal. Tap '+ Add Food'", style: TextStyle(color: Colors.grey, fontSize: 12)),
          )
        else
          ..._currentMealList.asMap().entries.map((entry) {
            int idx = entry.key;
            MealEntry item = entry.value;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(
                            "${item.calories.toStringAsFixed(0)} kcal | P: ${item.protein.toStringAsFixed(1)}g | C: ${item.carbs.toStringAsFixed(1)}g | F: ${item.fats.toStringAsFixed(1)}g",
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 55,
                      child: TextFormField(
                        initialValue: item.quantity.toStringAsFixed(0),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          setState(() {
                            item.quantity = double.tryParse(val) ?? 0.0;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    DropdownButton<String>(
                      value: ['g', 'pcs', 'tbsp', 'tsp', 'scoop'].contains(item.food.unit) ? item.food.unit : 'g',
                      isDense: true,
                      underline: const SizedBox(),
                      items: ['g', 'pcs', 'tbsp', 'tsp', 'scoop'].map((u) {
                        return DropdownMenuItem(
                          value: u,
                          child: Text(u, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                      onChanged: (newUnit) {
                        if (newUnit != null) {
                          setState(() {
                            final updatedFood = FoodItem(
                              name: item.food.name,
                              calories: item.food.calories,
                              protein: item.food.protein,
                              carbs: item.food.carbs,
                              fats: item.food.fats,
                              unit: newUnit,
                              pieceWeight: item.food.pieceWeight,
                              tbspWeight: item.food.tbspWeight,
                              tspWeight: item.food.tspWeight,
                              scoopWeight: item.food.scoopWeight,
                            );
                            _currentMealList[idx] = MealEntry(food: updatedFood, quantity: item.quantity);
                          });
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                      onPressed: () {
                        setState(() {
                          _currentMealList.removeAt(idx);
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  // --- WORKOUT TAB BUILDER ---
  Widget _buildWorkoutTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("⚡ Auto-Load Workout Splits", style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFF59E0B))),
                    onPressed: () => _loadWorkoutSplit('2-Day'),
                    child: const Text("2-Day Split", style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFF59E0B))),
                    onPressed: () => _loadWorkoutSplit('3-Day'),
                    child: const Text("3-Day PPL", style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFF59E0B))),
                    onPressed: () => _loadWorkoutSplit('4-Day'),
                    child: const Text("4-Day Hypertrophy", style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFF59E0B))),
                    onPressed: () => _loadWorkoutSplit('HIIT'),
                    child: const Text("HIIT Protocol", style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((d) {
              int count = _weeklyWorkout[d]?.length ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text("$d ($count)", style: const TextStyle(fontSize: 11)),
                  selected: _selectedDay == d,
                  selectedColor: const Color(0xFFF59E0B),
                  onSelected: (v) => setState(() => _selectedDay = d),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$_selectedDay Routine", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              icon: const Icon(Icons.add, size: 16, color: Colors.black),
              label: const Text("Add Exercise", style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: _openAddExerciseDialog,
            ),
          ],
        ),
        const SizedBox(height: 6),

        if ((_weeklyWorkout[_selectedDay] ?? []).isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: const Text("No exercises for this day (Rest / Active Recovery).", style: TextStyle(color: Colors.grey, fontSize: 12)),
          )
        else
          ...(_weeklyWorkout[_selectedDay] ?? []).asMap().entries.map((e) {
            int idx = e.key;
            WorkoutExercise ex = e.value;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                dense: true,
                title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text("${ex.sets} Sets × ${ex.reps} Reps | Rest: ${ex.restSeconds}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                  onPressed: () {
                    setState(() {
                      _weeklyWorkout[_selectedDay]?.removeAt(idx);
                    });
                  },
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
}
