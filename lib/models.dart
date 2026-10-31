import 'dart:convert';

// --- CLINICAL & ENDOCRINE PROFILES ---
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

  String toJson() => json.encode(toMap());
  factory FoodItem.fromJson(dynamic source) {
    if (source is String) {
      return FoodItem.fromMap(json.decode(source));
    }
    return FoodItem.fromMap(source as Map<String, dynamic>);
  }
}

// --- MEAL ENTRY WITH ACCURATE UNIT MULTIPLIER ---
class MealEntry {
  final FoodItem food;
  double quantity;

  MealEntry({required this.food, this.quantity = 100});

  bool get isPerUnit =>
      food.unit == 'pcs' || food.unit == 'tbsp' || food.unit == 'scoop';

  double get calories => isPerUnit
      ? food.calories * quantity
      : (food.calories * quantity) / 100;

  double get protein => isPerUnit
      ? food.protein * quantity
      : (food.protein * quantity) / 100;

  double get carbs => isPerUnit
      ? food.carbs * quantity
      : (food.carbs * quantity) / 100;

  double get fats => isPerUnit
      ? food.fats * quantity
      : (food.fats * quantity) / 100;

  Map<String, dynamic> toMap() => {
    'food': food.toMap(),
    'quantity': quantity,
  };

  factory MealEntry.fromMap(Map<String, dynamic> map) => MealEntry(
    food: FoodItem.fromMap(map['food']),
    quantity: (map['quantity'] as num?)?.toDouble() ?? 100.0,
  );
}

// --- 5 MEAL PLAN MODEL ---
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

// --- WORKOUT EXERCISE (COMPATIBLE WITH DATABASE.DART & PLANNER) ---
class WorkoutExercise {
  String id;
  String name;
  String category;
  dynamic sets; // int ya String dono accept karega
  String reps;
  String restSeconds;

  WorkoutExercise({
    this.id = '',
    required this.name,
    this.category = 'General',
    this.sets = 3,
    this.reps = '12',
    this.restSeconds = '60s',
  });

  // Getter shortcuts planner_screen ke compatibility ke liye
  String get setsDisplay => sets.toString();
  String get rest => restSeconds;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'sets': sets,
    'reps': reps,
    'restSeconds': restSeconds,
  };

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) => WorkoutExercise(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    category: map['category'] ?? 'General',
    sets: map['sets'] ?? 3,
    reps: map['reps'] ?? '12',
    restSeconds: map['restSeconds'] ?? '60s',
  );

  String toJson() => json.encode(toMap());
  factory WorkoutExercise.fromJson(dynamic source) {
    if (source is String) {
      return WorkoutExercise.fromMap(json.decode(source));
    }
    return WorkoutExercise.fromMap(source as Map<String, dynamic>);
  }
}

// Alias taaki purane ExerciseEntry reference se bhi error na aaye
typedef ExerciseEntry = WorkoutExercise;

// --- CLIENT PROFILE ---
class ClientProfile {
  String name;
  int age;
  String gender;
  double weightKg;
  double heightCm;
  double activityMultiplier;
  MedicalCondition condition;
  String goal;
  double targetCalories;
  String dailyWater;
  String notes;
  FiveMealPlan dietPlan;
  Map<String, List<WorkoutExercise>> weeklyWorkout;

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
    Map<String, List<WorkoutExercise>>? weeklyWorkout,
  })  : dietPlan = dietPlan ?? FiveMealPlan(),
        weeklyWorkout = weeklyWorkout ?? {
          'Mon': [],
          'Tue': [],
          'Wed': [],
          'Thu': [],
          'Fri': [],
          'Sat': [],
        };

  double get baseBmr {
    if (gender == 'Male') {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
  }

  double get conditionMultiplier {
    switch (condition) {
      case MedicalCondition.thyroid:
        return 0.88;
      case MedicalCondition.pcod:
        return 0.90;
      case MedicalCondition.diabetes:
        return 0.92;
      case MedicalCondition.none:
      default:
        return 1.0;
    }
  }

  double get adjustedBmr => baseBmr * conditionMultiplier;
  double get adjustedTdee => adjustedBmr * activityMultiplier;

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
    Map<String, List<WorkoutExercise>> workoutMap = {};
    rawWorkout.forEach((key, val) {
      workoutMap[key] = (val as List? ?? [])
          .map((e) => WorkoutExercise.fromMap(e))
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
