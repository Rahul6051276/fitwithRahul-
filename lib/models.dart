import 'package:flutter/material.dart';

enum PortionUnit { gm, tbsp, tsp, piece, scoop }

class FoodItem {
  final String id;
  final String name;
  final IconData icon;
  final double per100gCalories;
  final double per100gProtein;
  final double per100gCarbs;
  final double per100gFat;
  final double tbspWeight;
  final double tspWeight;
  final double pieceWeight;

  const FoodItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.per100gCalories,
    required this.per100gProtein,
    required this.per100gCarbs,
    required this.per100gFat,
    this.tbspWeight = 15.0,
    this.tspWeight = 5.0,
    this.pieceWeight = 50.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconCode': icon.codePoint,
        'cal': per100gCalories,
        'pro': per100gProtein,
        'carb': per100gCarbs,
        'fat': per100gFat,
        'tbsp': tbspWeight,
        'tsp': tspWeight,
        'piece': pieceWeight,
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: IconData(json['iconCode'] as int? ?? 0xe25a, fontFamily: 'MaterialIcons'),
        per100gCalories: (json['cal'] as num).toDouble(),
        per100gProtein: (json['pro'] as num).toDouble(),
        per100gCarbs: (json['carb'] as num).toDouble(),
        per100gFat: (json['fat'] as num).toDouble(),
        tbspWeight: (json['tbsp'] as num?)?.toDouble() ?? 15.0,
        tspWeight: (json['tsp'] as num?)?.toDouble() ?? 5.0,
        pieceWeight: (json['piece'] as num?)?.toDouble() ?? 50.0,
      );
}

class MealEntry {
  final FoodItem food;
  double quantity;
  PortionUnit unit;

  MealEntry({
    required this.food,
    this.quantity = 100.0,
    this.unit = PortionUnit.gm,
  });

  double get totalGrams {
    switch (unit) {
      case PortionUnit.gm:
        return quantity;
      case PortionUnit.tbsp:
        return quantity * food.tbspWeight;
      case PortionUnit.tsp:
        return quantity * food.tspWeight;
      case PortionUnit.piece:
      case PortionUnit.scoop:
        return quantity * food.pieceWeight;
    }
  }

  double get totalCalories => (food.per100gCalories * totalGrams) / 100.0;
  double get totalProtein => (food.per100gProtein * totalGrams) / 100.0;
  double get totalCarbs => (food.per100gCarbs * totalGrams) / 100.0;
  double get totalFats => (food.per100gFat * totalGrams) / 100.0;

  String get displayPortion {
    String unitName = unit.name;
    if (unit == PortionUnit.gm) {
      return "${quantity.toStringAsFixed(0)} gm";
    }
    return "${quantity.toStringAsFixed(quantity % 1 == 0 ? 0 : 1)} $unitName (${totalGrams.toStringAsFixed(0)}g)";
  }

  Map<String, dynamic> toJson() => {
        'food': food.toJson(),
        'qty': quantity,
        'unit': unit.name,
      };

  factory MealEntry.fromJson(Map<String, dynamic> json) => MealEntry(
        food: FoodItem.fromJson(json['food'] as Map<String, dynamic>),
        quantity: (json['qty'] as num).toDouble(),
        unit: PortionUnit.values.firstWhere(
          (u) => u.name == json['unit'],
          orElse: () => PortionUnit.gm,
        ),
      );
}

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

  List<MealEntry> getMealList(int index) {
    switch (index) {
      case 1:
        return meal1;
      case 2:
        return meal2;
      case 3:
        return meal3;
      case 4:
        return meal4;
      case 5:
        return meal5;
      default:
        return meal1;
    }
  }

  double get grandCalories => _sum(meal1) + _sum(meal2) + _sum(meal3) + _sum(meal4) + _sum(meal5);
  double get grandProtein => _sumP(meal1) + _sumP(meal2) + _sumP(meal3) + _sumP(meal4) + _sumP(meal5);
  double get grandCarbs => _sumC(meal1) + _sumC(meal2) + _sumC(meal3) + _sumC(meal4) + _sumC(meal5);
  double get grandFats => _sumF(meal1) + _sumF(meal2) + _sumF(meal3) + _sumF(meal4) + _sumF(meal5);

  double _sum(List<MealEntry> l) => l.fold(0.0, (s, i) => s + i.totalCalories);
  double _sumP(List<MealEntry> l) => l.fold(0.0, (s, i) => s + i.totalProtein);
  double _sumC(List<MealEntry> l) => l.fold(0.0, (s, i) => s + i.totalCarbs);
  double _sumF(List<MealEntry> l) => l.fold(0.0, (s, i) => s + i.totalFats);

  Map<String, dynamic> toJson() => {
        'm1': meal1.map((e) => e.toJson()).toList(),
        'm2': meal2.map((e) => e.toJson()).toList(),
        'm3': meal3.map((e) => e.toJson()).toList(),
        'm4': meal4.map((e) => e.toJson()).toList(),
        'm5': meal5.map((e) => e.toJson()).toList(),
      };

  factory FiveMealPlan.fromJson(Map<String, dynamic> json) => FiveMealPlan(
        meal1: json['m1'] != null ? (json['m1'] as List).map((e) => MealEntry.fromJson(e as Map<String, dynamic>)).toList() : [],
        meal2: json['m2'] != null ? (json['m2'] as List).map((e) => MealEntry.fromJson(e as Map<String, dynamic>)).toList() : [],
        meal3: json['m3'] != null ? (json['m3'] as List).map((e) => MealEntry.fromJson(e as Map<String, dynamic>)).toList() : [],
        meal4: json['m4'] != null ? (json['m4'] as List).map((e) => MealEntry.fromJson(e as Map<String, dynamic>)).toList() : [],
        meal5: json['m5'] != null ? (json['m5'] as List).map((e) => MealEntry.fromJson(e as Map<String, dynamic>)).toList() : [],
      );
}

class WorkoutExercise {
  final String id;
  final String name;
  final String category;
  int sets;
  String reps;
  String restSeconds;

  WorkoutExercise({
    required this.id,
    required this.name,
    required this.category,
    this.sets = 3,
    this.reps = "10-12 reps",
    this.restSeconds = "60s",
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cat': category,
        'sets': sets,
        'reps': reps,
        'rest': restSeconds,
      };

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) => WorkoutExercise(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['cat'] as String,
        sets: (json['sets'] as num?)?.toInt() ?? 3,
        reps: json['reps'] as String? ?? "10-12 reps",
        restSeconds: json['rest'] as String? ?? "60s",
      );
}

class SavedClientPlan {
  final String clientName;
  final double targetCalories;
  final String waterIntake;
  final String coachNotes;
  final int totalMeals;
  final FiveMealPlan plan;
  final List<WorkoutExercise> workouts;

  SavedClientPlan({
    required this.clientName,
    required this.targetCalories,
    required this.waterIntake,
    required this.coachNotes,
    required this.totalMeals,
    required this.plan,
    required this.workouts,
  });

  Map<String, dynamic> toJson() => {
        'clientName': clientName,
        'targetCal': targetCalories,
        'water': waterIntake,
        'notes': coachNotes,
        'totalMeals': totalMeals,
        'plan': plan.toJson(),
        'workouts': workouts.map((w) => w.toJson()).toList(),
      };

  factory SavedClientPlan.fromJson(Map<String, dynamic> json) => SavedClientPlan(
        clientName: json['clientName'] as String,
        targetCalories: (json['targetCal'] as num).toDouble(),
        waterIntake: json['water'] as String? ?? "3.5 - 4 Liters",
        coachNotes: json['notes'] as String? ?? "",
        totalMeals: (json['totalMeals'] as num?)?.toInt() ?? 3,
        plan: FiveMealPlan.fromJson(json['plan'] as Map<String, dynamic>),
        workouts: (json['workouts'] as List).map((w) => WorkoutExercise.fromJson(w as Map<String, dynamic>)).toList(),
      );
}
