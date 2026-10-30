class FoodItem {
  final String id;
  final String name;
  final String iconEmoji; // Chhota logo/icon
  final double per100gCalories;
  final double per100gProtein;
  final double per100gCarbs;
  final double per100gFat;

  const FoodItem({
    required this.id,
    required this.name,
    required this.iconEmoji,
    required this.per100gCalories,
    required this.per100gProtein,
    required this.per100gCarbs,
    required this.per100gFat,
  });
}

class MealEntry {
  final FoodItem food;
  double grams; // Grams input (e.g., 50g, 100g)

  MealEntry({required this.food, this.grams = 100.0});

  // Grams ke hisab se exact live macros calculation
  double get totalCalories => (food.per100gCalories * grams) / 100.0;
  double get totalProtein => (food.per100gProtein * grams) / 100.0;
  double get totalCarbs => (food.per100gCarbs * grams) / 100.0;
  double get totalFats => (food.per100gFat * grams) / 100.0;
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
