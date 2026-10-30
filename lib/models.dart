import 'package:flutter/material.dart';

// Serving unit enum
enum PortionUnit { gm, tbsp, tsp, piece, scoop }

class FoodItem {
  final String id;
  final String name;
  final IconData icon;
  final double per100gCalories;
  final double per100gProtein;
  final double per100gCarbs;
  final double per100gFat;
  final double tbspWeight; // 1 tbsp kitne gram ka hota hai
  final double tspWeight;  // 1 tsp kitne gram ka hota hai
  final double pieceWeight;// 1 piece/egg/scoop kitne gram ka hota hai

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

  // Selected Unit ke hisab se total gram nikalna
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

  // Exact automatic macros calculation
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
}

class FiveMealPlan {
  List<MealEntry> meal1 = [];
  List<MealEntry> meal2 = [];
  List<MealEntry> meal3 = [];
  List<MealEntry> meal4 = [];
  List<MealEntry> meal5 = [];

  List<MealEntry> getMealList(int index) {
    switch (index) {
      case 1: return meal1;
      case 2: return meal2;
      case 3: return meal3;
      case 4: return meal4;
      case 5: return meal5;
      default: return meal1;
    }
  }

  double get grandCalories => _sum(meal1) + _sum(meal2) + _sum(meal3) + _sum(meal4) + _sum(meal5);
  double get grandProtein => _sumP(meal1) + _sumP(meal2) + _sumP(meal3) + _sumP(meal4) + _sumP(meal5);
  double get grandCarbs => _sumC(meal1) + _sumC(meal2) + _sumC(meal3) + _sumC(meal4) + _sumC(meal5);
  double get grandFats => _sumF(meal1) + _sumF(meal2) + _sumF(meal3) + _sumF(meal4) + _sumF(meal5);

  double _sum(List<MealEntry> l) => l.fold(0, (s, i) => s + i.totalCalories);
  double _sumP(List<MealEntry> l) => l.fold(0, (s, i) => s + i.totalProtein);
  double _sumC(List<MealEntry> l) => l.fold(0, (s, i) => s + i.totalCarbs);
  double _sumF(List<MealEntry> l) => l.fold(0, (s, i) => s + i.totalFats);
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
}
