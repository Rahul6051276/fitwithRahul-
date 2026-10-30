class FoodItem {
  final String id;
  final String name;
  final String servingUnit;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;

  const FoodItem({
    required this.id,
    required this.name,
    required this.servingUnit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });
}

class MealEntry {
  final FoodItem food;
  double quantity;

  MealEntry({required this.food, this.quantity = 1.0});

  double get totalCalories => food.calories * quantity;
  double get totalProtein => food.protein * quantity;
  double get totalCarbs => food.carbs * quantity;
  double get totalFats => food.fats * quantity;
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
  final String name;
  final String targetMuscle;
  final int sets;
  final String reps;
  final String restSeconds;

  WorkoutExercise({
    required this.name,
    required this.targetMuscle,
    required this.sets,
    required this.reps,
    this.restSeconds = "60s",
  });
}
