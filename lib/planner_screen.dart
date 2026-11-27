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

class _PlannerScreenState extends State<PlannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late TextEditingController _clientNameController;
  late TextEditingController _targetCalController;
  late TextEditingController _waterController;
  late TextEditingController _notesController;

  late ClientProfile _client;
  int _selectedMealIndex = 0;
  String _selectedDay = 'Mon';
  String _activeSplit = '2-Day';

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
  static const List<String> _unitOptions = ['g', 'pcs', 'tbsp', 'tsp', 'scoop'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _client = widget.initialClient ??
        ClientProfile(
          name: 'Client',
          goal: 'Fat Loss',
          targetCalories: 2000,
        );

    _clientNameController = TextEditingController(text: _client.name);
    _targetCalController =
        TextEditingController(text: _client.targetCalories.toStringAsFixed(0));
    _waterController = TextEditingController(text: _client.dailyWater);

    final defaultNotes = _client.condition != MedicalCondition.none
        ? 'Medical Profile: ${_client.condition.name.toUpperCase()} (Low-GI priority). Progressive Overload maintain karein.'
        : 'Creatine 3-5g daily. Progressive Overload prioritize karein.';

    _notesController = TextEditingController(
        text: _client.notes.isNotEmpty ? _client.notes : defaultNotes);

    _loadDatabases();
    _loadWorkoutSplit('2-Day', showSnack: false);
  }

  void _loadDatabases() {
    setState(() {
      try {
        _allFoods = List.from(AppDatabase.foods);
        _allExercises = Map.from(AppDatabase.exercisesByCategory);
      } catch (_) {
        _allFoods = [
          const FoodItem(
            id: 'wh_egg',
            name: 'Whole Boiled Egg',
            calories: 78,
            protein: 6.3,
            carbs: 0.6,
            fats: 5.3,
            unit: 'pcs',
            pieceWeight: 50.0,
          ),
          const FoodItem(
            id: 'egg_white',
            name: 'Egg White (Boiled)',
            calories: 17,
            protein: 3.6,
            carbs: 0.2,
            fats: 0.1,
            unit: 'pcs',
            pieceWeight: 33.0,
          ),
          const FoodItem(
            id: 'soya_chunks',
            name: 'Soya Chunks (Raw)',
            calories: 345,
            protein: 52.0,
            carbs: 33.0,
            fats: 0.5,
            unit: 'g',
          ),
          const FoodItem(
            id: 'low_fat_paneer',
            name: 'Low Fat Paneer',
            calories: 200,
            protein: 20.0,
            carbs: 4.0,
            fats: 12.0,
            unit: 'g',
          ),
          const FoodItem(
            id: 'whey_protein',
            name: 'Whey Protein',
            calories: 120,
            protein: 24.0,
            carbs: 2.5,
            fats: 1.5,
            unit: 'scoop',
            scoopWeight: 30.0,
          ),
          const FoodItem(
            id: 'rolled_oats',
            name: 'Rolled Oats (Raw)',
            calories: 389,
            protein: 16.9,
            carbs: 66.3,
            fats: 6.9,
            unit: 'g',
          ),
          const FoodItem(
            id: 'white_rice',
            name: 'White Rice (Cooked)',
            calories: 130,
            protein: 2.7,
            carbs: 28.2,
            fats: 0.3,
            unit: 'g',
          ),
          const FoodItem(
            id: 'wheat_roti',
            name: 'Wheat Roti (Plain)',
            calories: 120,
            protein: 3.5,
            carbs: 22.0,
            fats: 2.0,
            unit: 'pcs',
            pieceWeight: 35.0,
          ),
          const FoodItem(
            id: 'peanut_butter',
            name: 'Peanut Butter (Unsweetened)',
            calories: 95,
            protein: 4.0,
            carbs: 3.0,
            fats: 8.0,
            unit: 'tbsp',
            tbspWeight: 16.0,
          ),
        ];
        _allExercises = {
          'Chest': [
            'Barbell Flat Bench Press',
            'Incline Dumbbell Press',
            'Standard Push-Ups',
          ],
          'Back': [
            'Lat Pulldown (Wide Grip)',
            'Barbell Bent-Over Row',
            'Seated Cable Row',
          ],
          'Legs': [
            'Barbell Back Squat',
            'Romanian Deadlift (RDL)',
            'Leg Press Machine',
            'Lying Hamstring Leg Curls',
            'Standing Calf Raise',
          ],
          'Shoulders': [
            'Overhead Dumbbell Shoulder Press',
            'Dumbbell Lateral Raise',
            'Cable Face Pulls',
          ],
          'Arms': [
            'EZ Bar Bicep Curl',
            'Triceps Rope Pushdown',
          ],
          'Core': [
            'Standard Elbow Plank Hold',
            'Russian Twists',
          ],
          'HIIT': [
            'Burpees (Chest-to-Floor)',
            'Battle Ropes Waves',
            'Kettlebell Swings',
          ],
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
      case 0:
        return _dietPlan.meal1;
      case 1:
        return _dietPlan.meal2;
      case 2:
        return _dietPlan.meal3;
      case 3:
        return _dietPlan.meal4;
      case 4:
        return _dietPlan.meal5;
      default:
        return _dietPlan.meal1;
    }
  }

  double _unitMultiplier(FoodItem food, String selectedUnit) {
    final baseUnit = food.unit.toLowerCase();
    final targetUnit = selectedUnit.toLowerCase();
    if (baseUnit == targetUnit) return 1.0;

    final pieceGrams = food.pieceWeight ?? 50.0;
    final tbspGrams = food.tbspWeight ?? 15.0;
    final tspGrams = food.tspWeight ?? 5.0;
    final scoopGrams = food.scoopWeight ?? 30.0;

    double gramsPerBaseUnit;
    if (baseUnit == 'pcs') {
      gramsPerBaseUnit = pieceGrams;
    } else if (baseUnit == 'tbsp') {
      gramsPerBaseUnit = tbspGrams;
    } else if (baseUnit == 'tsp') {
      gramsPerBaseUnit = tspGrams;
    } else if (baseUnit == 'scoop') {
      gramsPerBaseUnit = scoopGrams;
    } else {
      gramsPerBaseUnit = 100.0;
    }

    double gramsPerTargetUnit;
    if (targetUnit == 'pcs') {
      gramsPerTargetUnit = pieceGrams;
    } else if (targetUnit == 'tbsp') {
      gramsPerTargetUnit = tbspGrams;
    } else if (targetUnit == 'tsp') {
      gramsPerTargetUnit = tspGrams;
    } else if (targetUnit == 'scoop') {
      gramsPerTargetUnit = scoopGrams;
    } else {
      gramsPerTargetUnit = 100.0;
    }

    return gramsPerTargetUnit / gramsPerBaseUnit;
  }

  void _updateMealEntry(int index, {double? newQty, String? newUnit}) {
    final current = _currentMealList[index];
    final updatedQty = newQty ?? current.quantity;
    final updatedUnit = newUnit ?? current.food.unit;
    final factor = _unitMultiplier(current.food, updatedUnit);

    final adjustedFood = FoodItem(
      id: current.food.id,
      name: current.food.name,
      calories: current.food.calories * factor,
      protein: current.food.protein * factor,
      carbs: current.food.carbs * factor,
      fats: current.food.fats * factor,
      unit: updatedUnit,
      pieceWeight: current.food.pieceWeight,
      tbspWeight: current.food.tbspWeight,
      tspWeight: current.food.tspWeight,
      scoopWeight: current.food.scoopWeight,
      icon: current.food.icon,
    );

    setState(() {
      _currentMealList[index] = MealEntry(
        food: adjustedFood,
        quantity: updatedQty < 0 ? 0 : updatedQty,
      );
    });
  }

  Future<void> _saveCurrentClient() async {
    final name = _clientNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kripya Client Name enter karein!')),
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
                const Text('Saved Clients',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                IconButton(
                    icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            if (profiles.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Abhi koi client save nahi hai.',
                      style: TextStyle(color: Colors.grey)),
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
                            item.name.isNotEmpty ? item.name[0].toUpperCase() : 'C',
                            style: const TextStyle(
                                color: Color(0xFFF59E0B), fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '${item.goal} | Target: ${item.targetCalories.toStringAsFixed(0)} kcal'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () async {
                            profiles.removeAt(idx);
                            List<String> updatedRaw =
                                profiles.map((p) => p.toJson()).toList();
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
      SnackBar(content: Text('${client.name} ka plan edit mode me load ho gaya!')),
    );
  }

  void _loadWorkoutSplit(String splitName, {bool showSnack = true}) {
    setState(() {
      _activeSplit = splitName;
      _weeklyWorkout.forEach((k, v) => v.clear());

      if (splitName == '2-Day') {
        // Upper Body (Mon) & Lower Body (Tue)
        _weeklyWorkout['Mon'] = [
          const WorkoutExercise(
              name: 'Barbell Flat Bench Press',
              category: 'Chest',
              sets: '4',
              reps: '8-10',
              restSeconds: '90s'),
          const WorkoutExercise(
              name: 'Lat Pulldown (Wide Grip)',
              category: 'Back',
              sets: '4',
              reps: '10-12',
              restSeconds: '75s'),
          const WorkoutExercise(
              name: 'Incline Dumbbell Press',
              category: 'Chest',
              sets: '3',
              reps: '10-12',
              restSeconds: '60s'),
          const WorkoutExercise(
              name: 'Seated Cable Row',
              category: 'Back',
              sets: '3',
              reps: '10-12',
              restSeconds: '60s'),
          const WorkoutExercise(
              name: 'Dumbbell Lateral Raise',
              category: 'Shoulders',
              sets: '4',
              reps: '12-15',
              restSeconds: '45s'),
          const WorkoutExercise(
              name: 'EZ Bar Bicep Curl',
              category: 'Arms',
              sets: '3',
              reps: '10-12',
              restSeconds: '60s'),
          const WorkoutExercise(
              name: 'Triceps Rope Pushdown',
              category: 'Arms',
              sets: '3',
              reps: '12-15',
              restSeconds: '60s'),
        ];
        _weeklyWorkout['Tue'] = [
          const WorkoutExercise(
              name: 'Barbell Back Squat',
              category: 'Legs',
              sets: '4',
              reps: '8-10',
              restSeconds: '120s'),
          const WorkoutExercise(
              name: 'Romanian Deadlift (RDL)',
              category: 'Legs',
              sets: '3',
              reps: '10-12',
              restSeconds: '90s'),
          const WorkoutExercise(
              name: 'Leg Press Machine',
              category: 'Legs',
              sets: '3',
              reps: '12',
              restSeconds: '75s'),
          const WorkoutExercise(
              name: 'Lying Hamstring Leg Curls',
              category: 'Legs',
              sets: '3',
              reps: '12-15',
              restSeconds: '60s'),
          const WorkoutExercise(
              name: 'Standing Calf Raise',
              category: 'Legs',
              sets: '4',
              reps: '15-20',
              restSeconds: '45s'),
          const WorkoutExercise(
              name: 'Standard Elbow Plank Hold',
              category: 'Core',
              sets: '3',
              reps: '60s hold',
              restSeconds: '45s'),
        ];
        _selectedDay = 'Mon';
      } else if (splitName == '3-Day') {
        // Push (Mon), Pull (Wed), Legs (Fri)
        _weeklyWorkout['Mon'] = [
          const WorkoutExercise(
              name: 'Barbell Flat Bench Press',
              category: 'Chest',
              sets: '4',
              reps: '8-10',
              restSeconds: '90s'),
          const WorkoutExercise(
              name: 'Incline Dumbbell Press',
              category: 'Chest',
              sets: '3',
              reps: '10-12',
              restSeconds: '75s'),
          const WorkoutExercise(
              name: 'Overhead Dumbbell Shoulder Press',
              category: 'Shoulders',
              sets: '4',
              reps: '8-10',
              restSeconds: '75s'),
          const WorkoutExercise(
              name: 'Dumbbell Lateral Raise',
              category: 'Shoulders',
              sets: '4',
              reps: '12-15',
              restSeconds: '45s'),
          const WorkoutExercise(
              name: 'Triceps Rope Pushdown',
              category: 'Arms',
              sets: '3',
              reps: '12-15',
              restSeconds: '60s'),
        ];
        _weeklyWorkout['Wed'] = [
          const WorkoutExercise(
              name: 'Lat Pulldown (Wide Grip)',
              category: 'Back',
              sets: '4',
              reps: '10-12',
              restSeconds: '75s'),
          const WorkoutExercise(
              name: 'Barbell Bent-Over Row',
              category: 'Back',
              sets: '4',
              reps: '8-10',
              restSeconds: '90s'),
          const WorkoutExercise(
              name: 'Seated Cable Row',
              category: 'Back',
              sets: '3',
              reps: '10-12',
              restSeconds: '60s'),
          const WorkoutExercise(
              name: 'Cable Face Pulls',
              category: 'Shoulders',
              sets: '4',
              reps: '15',
              restSeconds: '45s'),
          const WorkoutExercise(
              name: 'EZ Bar Bicep Curl',
              category: 'Arms',
              sets: '3',
              reps: '10-12',
              restSeconds: '60s'),
        ];
        _weeklyWorkout['Fri'] = [
          const WorkoutExercise(
              name: 'Barbell Back Squat',
              category: 'Legs',
              sets: '4',
              reps: '8-10',
              restSeconds: '120s'),
          const WorkoutExercise(
              name: 'Romanian Deadlift (RDL)',
              category: 'Legs',
              sets: '3',
              reps: '8-10',
              restSeconds: '90s'),
          const WorkoutExercise(
              name: 'Leg Press Machine',
              category: 'Legs',
              sets: '3',
              reps: '10-12',
              restSeconds: '75s'),
          const WorkoutExercise(
              name: 'Lying Hamstring Leg Curls',
              category: 'Legs',
              sets: '3',
              reps: '12-15',
              restSeconds: '60s'),
          const WorkoutExercise(
              name: 'Standing Calf Raise',
              category: 'Legs',
              sets: '4',
              reps: '15-20',
              restSeconds: '45s'),
        ];
        _selectedDay = 'Mon';
      } else if (splitName == '4-Day') {
        // Upper A (Mon), Lower A (Tue), Upper B (Thu), Lower B (Fri)
        _weeklyWorkout['Mon'] = [
          const WorkoutExercise(
              name: 'Barbell Flat Bench Press',
              category: 'Chest',
              sets: '4',
              reps: '6-8',
              restSeconds: '90s'),
          const WorkoutExercise(
              name: 'Lat Pulldown (Wide Grip)',
              category: 'Back',
              sets: '4',
              reps: '8-10',
              restSeconds: '75s'),
          const WorkoutExercise(
              name: 'Overhead Dumbbell Shoulder Press',
              category: 'Shoulders',
              sets: '3',
              reps: '8-10',
              restSeconds: '75s'),
          const WorkoutExercise(
              name: 'EZ Bar Bicep Curl',
              category: 'Arms',
              sets: '3',
              reps: '10-12',
              restSeconds: '60s'),
        ];
        _weeklyWorkout['Tue'] = [
          const WorkoutExercise(
              name: 'Barbell Back Squat',
              category: 'Legs',
              sets: '4',
              reps: '8-10',
              restSeconds: '120s'),
          const WorkoutExercise(
              name: 'Romanian Deadlift (RDL)',
              category: 'Legs',
              sets: '4',
              reps: '8-10',
              restSeconds: '90s'),
          const WorkoutExercise(
              name: 'Standing Calf Raise',
              category: 'Legs',
              sets: '4',
              reps: '15-20',
              restSeconds: '45s'),
          const WorkoutExercise(
              name: 'Russian Twists',
              category: 'Core',
              sets: '3',
              reps: '20 reps',
              restSeconds: '45s'),
        ];
        _weeklyWorkout['Thu'] = [
          const WorkoutExercise(
              name: 'Incline Dumbbell Press',
              category: 'Chest',
              sets: '4',
              reps: '8-10',
              restSeconds: '75s'),
          const WorkoutExercise(
              name: 'Seated Cable Row',
              category: 'Back',
              sets: '4',
              reps: '8-10',
              restSeconds: '75s'),
          const WorkoutExercise(
              name: 'Dumbbell Lateral Raise',
              category: 'Shoulders',
              sets: '4',
              reps: '12-15',
              restSeconds: '45s'),
          const WorkoutExercise(
              name: 'Triceps Rope Pushdown',
              category: 'Arms',
              sets: '3',
              reps: '12-15',
              restSeconds: '60s'),
        ];
        _weeklyWorkout['Fri'] = [
          const WorkoutExercise(
              name: 'Leg Press Machine',
              category: 'Legs',
              sets: '4',
              reps: '10-12',
              restSeconds: '75s'),
          const WorkoutExercise(
              name: 'Lying Hamstring Leg Curls',
              category: 'Legs',
              sets: '4',
              reps: '12-15',
              restSeconds: '60s'),
          const WorkoutExercise(
              name: 'Standing Calf Raise',
              category: 'Legs',
              sets: '4',
              reps: '15-20',
              restSeconds: '45s'),
          const WorkoutExercise(
              name: 'Standard Elbow Plank Hold',
              category: 'Core',
              sets: '3',
              reps: '60s hold',
              restSeconds: '45s'),
        ];
        _selectedDay = 'Mon';
      } else if (splitName == 'HIIT') {
        _weeklyWorkout['Tue'] = [
          const WorkoutExercise(
              name: 'Burpees (Chest-to-Floor)',
              category: 'HIIT',
              sets: '4',
              reps: '40s work',
              restSeconds: '20s'),
          const WorkoutExercise(
              name: 'Standard Push-Ups',
              category: 'Chest',
              sets: '4',
              reps: '40s work',
              restSeconds: '60s'),
          const WorkoutExercise(
              name: 'Russian Twists',
              category: 'Core',
              sets: '4',
              reps: '40s work',
              restSeconds: '20s'),
        ];
        _weeklyWorkout['Sat'] = [
          const WorkoutExercise(
              name: 'Battle Ropes Waves',
              category: 'HIIT',
              sets: '3',
              reps: '30s sprint',
              restSeconds: '30s'),
          const WorkoutExercise(
              name: 'Kettlebell Swings',
              category: 'HIIT',
              sets: '3',
              reps: '20 reps',
              restSeconds: '30s'),
          const WorkoutExercise(
              name: 'Standard Elbow Plank Hold',
              category: 'Core',
              sets: '2',
              reps: '60s hold',
              restSeconds: '45s'),
        ];
        _selectedDay = 'Tue';
      }
    });

    if (showSnack && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFF59E0B),
          content: Text('$splitName Split active ho gaya!'),
        ),
      );
    }
  }

  String _getDayFocusLabel(String day) {
    if (_activeSplit == '2-Day') {
      if (day == 'Mon') return 'Upper Body';
      if (day == 'Tue') return 'Lower Body';
      return 'Rest / Active Recovery';
    } else if (_activeSplit == '3-Day') {
      if (day == 'Mon') return 'Push (Chest / Shoulders / Triceps)';
      if (day == 'Wed') return 'Pull (Back / Rear Delt / Biceps)';
      if (day == 'Fri') return 'Legs (Quads / Hamstrings / Calves)';
      return 'Rest / Recovery';
    } else if (_activeSplit == '4-Day') {
      if (day == 'Mon') return 'Upper A (Strength Focus)';
      if (day == 'Tue') return 'Lower A (Quads / Glutes / Core)';
      if (day == 'Thu') return 'Upper B (Hypertrophy Focus)';
      if (day == 'Fri') return 'Lower B (Hamstrings / Glutes / Core)';
      return 'Rest / Cardio';
    } else if (_activeSplit == 'HIIT') {
      if (day == 'Tue' || day == 'Sat') return 'Conditioning & HIIT';
      return 'Strength / Mobility';
    }
    return 'Custom Session';
  }

  void _showMoveEntireDayDialog(String sourceDay) {
    final currentList = List<WorkoutExercise>.from(_weeklyWorkout[sourceDay] ?? []);
    if (currentList.isEmpty) return;

    final availableTargets = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
        .where((d) => d != sourceDay)
        .toList();
    String targetDay = availableTargets.first;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Move Entire $sourceDay Workout',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: StatefulBuilder(
          builder: (context, setDlgState) => DropdownButtonFormField<String>(
            value: targetDay,
            decoration: const InputDecoration(
                labelText: 'Select Target Day',
                border: OutlineInputBorder(),
                isDense: true),
            items: availableTargets
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (val) {
              if (val != null) setDlgState(() => targetDay = val);
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
            onPressed: () {
              setState(() {
                final existingTarget =
                    List<WorkoutExercise>.from(_weeklyWorkout[targetDay] ?? []);
                _weeklyWorkout[targetDay] = [...existingTarget, ...currentList];
                _weeklyWorkout[sourceDay] = [];
                _selectedDay = targetDay;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Move Day',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showMoveExerciseDialog(WorkoutExercise exercise, String currentDay) {
    final availableTargets = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
        .where((d) => d != currentDay)
        .toList();
    String targetDay = availableTargets.first;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Move '${exercise.name}'",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: StatefulBuilder(
          builder: (context, setDlgState) => DropdownButtonFormField<String>(
            value: targetDay,
            decoration: const InputDecoration(
                labelText: 'Target Day',
                border: OutlineInputBorder(),
                isDense: true),
            items: availableTargets
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (val) {
              if (val != null) setDlgState(() => targetDay = val);
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
            onPressed: () {
              setState(() {
                _weeklyWorkout[currentDay]?.remove(exercise);
                _weeklyWorkout.putIfAbsent(targetDay, () => []);
                _weeklyWorkout[targetDay]?.add(exercise);
              });
              Navigator.pop(ctx);
            },
            child: const Text('Move',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openAddFoodDialog() {
    String query = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
                      hintText: 'Search food (Oats, Rice, Egg, Paneer...)',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (val) => setModalState(() => query = val),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, idx) {
                      final food = filtered[idx];
                      return ListTile(
                        title: Text(food.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        subtitle: Text(
                            '${food.calories.toStringAsFixed(0)} kcal | P: ${food.protein}g (${food.unit})',
                            style: const TextStyle(fontSize: 11)),
                        trailing:
                            const Icon(Icons.add_circle, color: Color(0xFFF59E0B)),
                        onTap: () {
                          setState(() {
                            double defaultQty = (food.unit == 'pcs' ||
                                    food.unit == 'tbsp' ||
                                    food.unit == 'scoop' ||
                                    food.unit == 'tsp')
                                ? 1.0
                                : 100.0;
                            _currentMealList
                                .add(MealEntry(food: food, quantity: defaultQty));
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

  void _openAddExerciseDialog() {
    String selectedCategory =
        _allExercises.keys.isNotEmpty ? _allExercises.keys.first : 'Chest';
    String selectedExName = (_allExercises[selectedCategory]?.isNotEmpty ?? false)
        ? _allExercises[selectedCategory]!.first
        : '';

    final customExNameCtrl = TextEditingController();
    final setsCtrl = TextEditingController(text: '3');
    final repsCtrl = TextEditingController(text: '12');
    final restCtrl = TextEditingController(text: '60s');
    bool isCreatingNew = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          List<String> currentExList = _allExercises[selectedCategory] ?? [];

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Text('Add Exercise to $_selectedDay',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label:
                              const Text('Database', style: TextStyle(fontSize: 11)),
                          selected: !isCreatingNew,
                          onSelected: (_) =>
                              setDlgState(() => isCreatingNew = false),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ChoiceChip(
                          label:
                              const Text('+ New', style: TextStyle(fontSize: 11)),
                          selected: isCreatingNew,
                          onSelected: (_) =>
                              setDlgState(() => isCreatingNew = true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                        labelText: 'Category',
                        isDense: true,
                        border: OutlineInputBorder()),
                    items: _allExercises.keys
                        .map((cat) =>
                            DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (cat) {
                      if (cat != null) {
                        setDlgState(() {
                          selectedCategory = cat;
                          selectedExName =
                              (_allExercises[cat]?.isNotEmpty ?? false)
                                  ? _allExercises[cat]!.first
                                  : '';
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  if (!isCreatingNew)
                    DropdownButtonFormField<String>(
                      value: currentExList.contains(selectedExName)
                          ? selectedExName
                          : (currentExList.isNotEmpty
                              ? currentExList.first
                              : null),
                      decoration: const InputDecoration(
                          labelText: 'Exercise',
                          isDense: true,
                          border: OutlineInputBorder()),
                      items: currentExList
                          .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e,
                                  style: const TextStyle(fontSize: 12))))
                          .toList(),
                      onChanged: (ex) {
                        if (ex != null) setDlgState(() => selectedExName = ex);
                      },
                    )
                  else
                    TextField(
                      controller: customExNameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'New Exercise Name',
                          isDense: true,
                          border: OutlineInputBorder()),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                              controller: setsCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Sets',
                                  isDense: true,
                                  border: OutlineInputBorder()))),
                      const SizedBox(width: 6),
                      Expanded(
                          child: TextField(
                              controller: repsCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Reps',
                                  isDense: true,
                                  border: OutlineInputBorder()))),
                      const SizedBox(width: 6),
                      Expanded(
                          child: TextField(
                              controller: restCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Rest',
                                  isDense: true,
                                  border: OutlineInputBorder()))),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B)),
                onPressed: () {
                  String finalName = isCreatingNew
                      ? customExNameCtrl.text.trim()
                      : selectedExName;
                  if (finalName.isEmpty) return;
                  setState(() {
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
                child: const Text('Add',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
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
        title: const Text('fitwithRahul Builder',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          IconButton(
              icon: const Icon(Icons.folder, color: Color(0xFFF59E0B)),
              onPressed: _openSavedClientsList),
          IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _saveCurrentClient),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF59E0B),
          labelColor: const Color(0xFFF59E0B),
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.restaurant_menu), text: 'DIET PLAN'),
            Tab(icon: Icon(Icons.fitness_center), text: 'WEEKLY WORKOUT'),
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
                    padding: const EdgeInsets.symmetric(vertical: 12)),
                icon: const Icon(Icons.share, color: Colors.white, size: 18),
                label: const Text('Share Diet PDF',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
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
                    padding: const EdgeInsets.symmetric(vertical: 12)),
                icon: const Icon(Icons.sports_gymnastics,
                    color: Colors.white, size: 18),
                label: const Text('Share Workout PDF',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
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

  Widget _buildDietTab(double planCal, double targetCal) {
    final mealLists = [
      _dietPlan.meal1,
      _dietPlan.meal2,
      _dietPlan.meal3,
      _dietPlan.meal4,
      _dietPlan.meal5,
    ];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _clientNameController,
                decoration: const InputDecoration(
                    labelText: 'Client Name',
                    border: OutlineInputBorder(),
                    isDense: true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _targetCalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Target Cal',
                    border: OutlineInputBorder(),
                    isDense: true),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                  '${planCal.toStringAsFixed(0)} / ${targetCal.toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                      color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
              Text('P: ${_dietPlan.totalProtein.toStringAsFixed(0)}g',
                  style: const TextStyle(color: Colors.white)),
              Text('C: ${_dietPlan.totalCarbs.toStringAsFixed(0)}g',
                  style: const TextStyle(color: Colors.white)),
              Text('F: ${_dietPlan.totalFats.toStringAsFixed(0)}g',
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(5, (index) {
              final count = mealLists[index].length;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text('Meal ${index + 1} ($count)',
                      style: const TextStyle(fontSize: 11)),
                  selected: _selectedMealIndex == index,
                  selectedColor: const Color(0xFFF59E0B),
                  onSelected: (v) => setState(() => _selectedMealIndex = index),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Meal ${_selectedMealIndex + 1} Items',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B)),
              icon: const Icon(Icons.add, size: 16, color: Colors.black),
              label: const Text('Add Food',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              onPressed: _openAddFoodDialog,
            ),
          ],
        ),
        ..._currentMealList.asMap().entries.map((entry) {
          final int idx = entry.key;
          final MealEntry item = entry.value;
          final String currentUnit =
              _unitOptions.contains(item.food.unit) ? item.food.unit : 'g';

          return Card(
            key: ValueKey('meal_card_${_selectedMealIndex}_${item.food.id}_$idx'),
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(item.food.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () =>
                            setState(() => _currentMealList.removeAt(idx)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      SizedBox(
                        width: 78,
                        child: TextFormField(
                          key: ValueKey('qty_${_selectedMealIndex}_${item.food.id}_$idx'),
                          initialValue: item.quantity % 1 == 0
                              ? item.quantity.toStringAsFixed(0)
                              : item.quantity.toStringAsFixed(1),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Qty',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) {
                            final parsed = double.tryParse(val.trim());
                            if (parsed != null) {
                              _updateMealEntry(idx, newQty: parsed);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 96,
                        child: DropdownButtonFormField<String>(
                          value: currentUnit,
                          isDense: true,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            border: OutlineInputBorder(),
                          ),
                          items: _unitOptions
                              .map((u) => DropdownMenuItem(
                                    value: u,
                                    child: Text(u,
                                        style: const TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              _updateMealEntry(idx, newUnit: val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item.calories.toStringAsFixed(0)} kcal',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFFD97706)),
                            ),
                            Text(
                              'P: ${item.protein.toStringAsFixed(1)}g | C: ${item.carbs.toStringAsFixed(1)}g | F: ${item.fats.toStringAsFixed(1)}g',
                              style: const TextStyle(
                                  fontSize: 10.5, color: Colors.black54),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildWorkoutTab() {
    final currentDayExercises = _weeklyWorkout[_selectedDay] ?? [];
    final splits = ['2-Day', '3-Day', '4-Day', 'HIIT'];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Split: $_activeSplit  •  ${_getDayFocusLabel(_selectedDay)}',
                style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: splits.map((s) {
                  final isSelected = _activeSplit == s;
                  final label = s == '3-Day'
                      ? '3-Day PPL'
                      : s == '4-Day'
                          ? '4-Day Hypertrophy'
                          : s == 'HIIT'
                              ? 'HIIT Protocol'
                              : '2-Day Split';
                  return ChoiceChip(
                    label: Text(label,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black : Colors.white)),
                    selected: isSelected,
                    selectedColor: const Color(0xFFF59E0B),
                    backgroundColor: const Color(0xFF1E293B),
                    onSelected: (_) => _loadWorkoutSplit(s),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((d) {
              int count = _weeklyWorkout[d]?.length ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text('$d ($count)', style: const TextStyle(fontSize: 11)),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$_selectedDay Routine',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(_getDayFocusLabel(_selectedDay),
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
            Row(
              children: [
                if (currentDayExercises.isNotEmpty)
                  OutlinedButton(
                    onPressed: () => _showMoveEntireDayDialog(_selectedDay),
                    child:
                        const Text('Move Day', style: TextStyle(fontSize: 11)),
                  ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B)),
                  icon: const Icon(Icons.add, size: 16, color: Colors.black),
                  label: const Text('Add Exercise',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                  onPressed: _openAddExerciseDialog,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (currentDayExercises.isEmpty)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '$_selectedDay (${_getDayFocusLabel(_selectedDay)}) — Abhi koi exercise add nahi hai. Upar se split switch karein ya "+ Add Exercise" dabayein.',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          )
        else
          ...currentDayExercises.asMap().entries.map((e) {
            int idx = e.key;
            WorkoutExercise ex = e.value;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(ex.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(
                    '${ex.sets} Sets × ${ex.reps} Reps | Rest: ${ex.restSeconds}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.drive_file_move_outlined,
                          color: Color(0xFF0284C7)),
                      onPressed: () => _showMoveExerciseDialog(ex, _selectedDay),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => setState(
                          () => _weeklyWorkout[_selectedDay]?.removeAt(idx)),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
}