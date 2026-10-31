import 'dart:convert';

// --- MEDICAL & CLINICAL CONDITIONS ---
enum MedicalCondition { none, thyroid, pcod, diabetes }

// --- FOOD ITEM MODEL ---
class FoodItem {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final String unit; // 'g', 'ml', 'pcs', 'tbsp', 'scoop'

  FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.unit = 'g',
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fats': fats,
    'unit': unit,
  };

  factory FoodItem.fromMap(Map<String, dynamic> map) => FoodItem(
    name: map['name'] ?? '',
    calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
    protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
    carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
    fats: (map['fats'] as num?)?.toDouble() ?? 0.0,
    unit: map['unit'] ?? 'g',
  );
}

// --- MEAL ENTRY (FOOD + QUANTITY) ---
class MealEntry {
  final FoodItem food;
  double quantity; // Default base 100g ya 1 piece

  MealEntry({required this.food, this.quantity = 100});

  double get calories => (food.calories * quantity) / 100;
  double get protein => (food.protein * quantity) / 100;
  double get carbs => (food.carbs * quantity) / 100;
  double get fats => (food.fats * quantity) / 100;

  Map<String, dynamic> toMap() => {
    'food': food.toMap(),
    'quantity': quantity,
  };

  factory MealEntry.fromMap(Map<String, dynamic> map) => MealEntry(
    food: FoodItem.fromMap(map['food']),
    quantity: (map['quantity'] as num?)?.toDouble() ?? 100.0,
  );
}

// --- 5 MEAL PLAN STRUCTURE ---
class FiveMealPlan {
  List<MealEntry> meal1;
  List<MealEntry> meal2;
  List<MealEntry> meal3;
  List<MealEntry> meal4;
  List<MealEntry> meal5;

  FiveMealPlan({
    List<MealEntry>? meal1,
    List<MealEntry>? meal2,
    List<MealEntry>? meal3,
    List<MealEntry>? meal4,
    List<MealEntry>? meal5,
  })  : meal1 = meal1 ?? [],
        meal2 = meal2 ?? [],
        meal3 = meal3 ?? [],
        meal4 = meal4 ?? [],
        meal5 = meal5 ?? [];

  double get totalCalories =>
      _sum(meal1, (e) => e.calories) +
      _sum(meal2, (e) => e.calories) +
      _sum(meal3, (e) => e.calories) +
      _sum(meal4, (e) => e.calories) +
      _sum(meal5, (e) => e.calories);

  double get totalProtein =>
      _sum(meal1, (e) => e.protein) +
      _sum(meal2, (e) => e.protein) +
      _sum(meal3, (e) => e.protein) +
      _sum(meal4, (e) => e.protein) +
      _sum(meal5, (e) => e.protein);

  double get totalCarbs =>
      _sum(meal1, (e) => e.carbs) +
      _sum(meal2, (e) => e.carbs) +
      _sum(meal3, (e) => e.carbs) +
      _sum(meal4, (e) => e.carbs) +
      _sum(meal5, (e) => e.carbs);

  double get totalFats =>
      _sum(meal1, (e) => e.fats) +
      _sum(meal2, (e) => e.fats) +
      _sum(meal3, (e) => e.fats) +
      _sum(meal4, (e) => e.fats) +
      _sum(meal5, (e) => e.fats);

  double _sum(List<MealEntry> list, double Function(MealEntry) selector) =>
      list.fold(0.0, (prev, elem) => prev + selector(elem));

  Map<String, dynamic> toMap() => {
    'meal1': meal1.map((e) => e.toMap()).toList(),
    'meal2': meal2.map((e) => e.toMap()).toList(),
    'meal3': meal3.map((e) => e.toMap()).toList(),
    'meal4': meal4.map((e) => e.toMap()).toList(),
    'meal5': meal5.map((e) => e.toMap()).toList(),
  };

  factory FiveMealPlan.fromMap(Map<String, dynamic> map) => FiveMealPlan(
    meal1: (map['meal1'] as List? ?? []).map((e) => MealEntry.fromMap(e)).toList(),
    meal2: (map['meal2'] as List? ?? []).map((e) => MealEntry.fromMap(e)).toList(),
    meal3: (map['meal3'] as List? ?? []).map((e) => MealEntry.fromMap(e)).toList(),
    meal4: (map['meal4'] as List? ?? []).map((e) => MealEntry.fromMap(e)).toList(),
    meal5: (map['meal5'] as List? ?? []).map((e) => MealEntry.fromMap(e)).toList(),
  );
}

// --- EXERCISE ENTRY MODEL ---
class ExerciseEntry {
  String name;
  String sets;
  String reps;
  String rest;

  ExerciseEntry({
    required this.name,
    this.sets = '3',
    this.reps = '12',
    this.rest = '60s',
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'sets': sets,
    'reps': reps,
    'rest': rest,
  };

  factory ExerciseEntry.fromMap(Map<String, dynamic> map) => ExerciseEntry(
    name: map['name'] ?? '',
    sets: map['sets'] ?? '3',
    reps: map['reps'] ?? '12',
    rest: map['rest'] ?? '60s',
  );
}

// --- CLIENT FULL PROFILE (FOR SAVE, OVERVIEW & EDIT) ---
class ClientProfile {
  String name;
  int age;
  String gender;
  double weightKg;
  double heightCm;
  double activityMultiplier;
  MedicalCondition condition;
  String goal; // 'Fat Loss', 'Muscle Gain', 'Body Recomp'
  double targetCalories;
  String dailyWater;
  String notes;
  FiveMealPlan dietPlan;
  Map<String, List<ExerciseEntry>> weeklyWorkout; // Mon, Tue, etc.

  ClientProfile({
    required this.name,
    this.age = 25,
    this.gender = 'Male',
    this.weightKg = 70.0,
    this.heightCm = 170.0,
    this.activityMultiplier = 1.4,
    this.condition = MedicalCondition.none,
    this.goal = 'Fat Loss',
    this.targetCalories = 2000.0,
    this.dailyWater = '3.5 - 4 Liters',
    this.notes = 'Creatine 3-5g daily. Progressive Overload prioritize karein.',
    FiveMealPlan? dietPlan,
    Map<String, List<ExerciseEntry>>? weeklyWorkout,
  })  : dietPlan = dietPlan ?? FiveMealPlan(),
        weeklyWorkout = weeklyWorkout ?? {
          'Mon': [],
          'Tue': [],
          'Wed': [],
          'Thu': [],
          'Fri': [],
          'Sat': [],
        };

  // 1. Scientific Base BMR (Mifflin-St Jeor)
  double get baseBmr {
    if (gender == 'Male') {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
  }

  // 2. Clinical Condition Metabolic Correction Multiplier
  double get conditionMultiplier {
    switch (condition) {
      case MedicalCondition.thyroid:
        return 0.88; // 12% reduction for slow metabolism
      case MedicalCondition.pcod:
        return 0.90; // 10% reduction for insulin resistance
      case MedicalCondition.diabetes:
        return 0.92; // 8% reduction
      case MedicalCondition.none:
      default:
        return 1.0;
    }
  }

  // 3. Adjusted BMR & TDEE
  double get adjustedBmr => baseBmr * conditionMultiplier;
  double get adjustedTdee => adjustedBmr * activityMultiplier;

  // 4. Auto Recommended Target Calories
  double get calculatedTargetCalories {
    switch (goal) {
      case 'Fat Loss':
        return adjustedTdee - 400;
      case 'Muscle Gain':
        return adjustedTdee + 300;
      case 'Body Recomp':
      default:
        return adjustedTdee;
    }
  }

  // Serialization for SharedPreferences
  Map<String, dynamic> toMap() => {
    'name': name,
    'age': age,
    'gender': gender,
    'weightKg': weightKg,
    'heightCm': heightCm,
    'activityMultiplier': activityMultiplier,
    'condition': condition.name,
    'goal': goal,
    'targetCalories': targetCalories,
    'dailyWater': dailyWater,
    'notes': notes,
    'dietPlan': dietPlan.toMap(),
    'weeklyWorkout': weeklyWorkout.map(
      (k, v) => MapEntry(k, v.map((e) => e.toMap()).toList()),
    ),
  };

  factory ClientProfile.fromMap(Map<String, dynamic> map) {
    var rawWorkout = map['weeklyWorkout'] as Map<String, dynamic>? ?? {};
    Map<String, List<ExerciseEntry>> workoutMap = {};
    rawWorkout.forEach((key, val) {
      workoutMap[key] = (val as List? ?? [])
          .map((e) => ExerciseEntry.fromMap(e))
          .toList();
    });

    return ClientProfile(
      name: map['name'] ?? '',
      age: (map['age'] as num?)?.toInt() ?? 25,
      gender: map['gender'] ?? 'Male',
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 70.0,
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 170.0,
      activityMultiplier: (map['activityMultiplier'] as num?)?.toDouble() ?? 1.4,
      condition: MedicalCondition.values.firstWhere(
        (c) => c.name == map['condition'],
        orElse: () => MedicalCondition.none,
      ),
      goal: map['goal'] ?? 'Fat Loss',
      targetCalories: (map['targetCalories'] as num?)?.toDouble() ?? 2000.0,
      dailyWater: map['dailyWater'] ?? '3.5 - 4 Liters',
      notes: map['notes'] ?? '',
      dietPlan: FiveMealPlan.fromMap(map['dietPlan'] ?? {}),
      weeklyWorkout: workoutMap,
    );
  }

  String toJson() => json.encode(toMap());
  factory ClientProfile.fromJson(String source) =>
      ClientProfile.fromMap(json.decode(source));
}
