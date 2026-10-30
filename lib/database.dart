import 'models.dart';

class AppDataSheets {
  static const List<FoodItem> foodDatabase = [
    FoodItem(id: '1', name: 'Rolled Oats (Raw)', iconEmoji: '🥣', per100gCalories: 389, per100gProtein: 16.9, per100gCarbs: 66.3, per100gFat: 6.9),
    FoodItem(id: '2', name: 'Whole Boiled Egg', iconEmoji: '🥚', per100gCalories: 144, per100gProtein: 12.6, per100gCarbs: 0.8, per100gFat: 9.6),
    FoodItem(id: '3', name: 'Egg White (Boiled)', iconEmoji: '🍳', per100gCalories: 52, per100gProtein: 11.0, per100gCarbs: 0.7, per100gFat: 0.2),
    FoodItem(id: '4', name: 'Whey Protein Isolate', iconEmoji: '🥛', per100gCalories: 400, per100gProtein: 83.3, per100gCarbs: 5.0, per100gFat: 3.3),
    FoodItem(id: '5', name: 'Soya Chunks (Raw)', iconEmoji: '🧆', per100gCalories: 345, per100gProtein: 52.0, per100gCarbs: 33.0, per100gFat: 0.5),
    FoodItem(id: '6', name: 'Moong Sprouts (Raw)', iconEmoji: '🌱', per100gCalories: 105, per100gProtein: 7.0, per100gCarbs: 19.0, per100gFat: 0.4),
    FoodItem(id: '7', name: 'Paneer (Raw)', iconEmoji: '🧀', per100gCalories: 265, per100gProtein: 18.0, per100gCarbs: 2.0, per100gFat: 20.0),
    FoodItem(id: '8', name: 'Cooked White Rice', iconEmoji: '🍚', per100gCalories: 130, per100gProtein: 2.7, per100gCarbs: 28.0, per100gFat: 0.3),
    FoodItem(id: '9', name: 'Wheat Chapati / Roti', iconEmoji: '🫓', per100gCalories: 242, per100gProtein: 8.5, per100gCarbs: 48.5, per100gFat: 1.4),
    FoodItem(id: '10', name: 'Cooked Toor Daal', iconEmoji: '🍲', per100gCalories: 80, per100gProtein: 5.0, per100gCarbs: 13.3, per100gFat: 1.0),
    FoodItem(id: '11', name: 'Peanut Butter (Roasted)', iconEmoji: '🥜', per100gCalories: 588, per100gProtein: 25.0, per100gCarbs: 20.0, per100gFat: 50.0),
    FoodItem(id: '12', name: 'Medjool Dates (Khajoor)', iconEmoji: '🌴', per100gCalories: 277, per100gProtein: 1.8, per100gCarbs: 75.0, per100gFat: 0.2),
    FoodItem(id: '13', name: 'Raisins (Kishmish)', iconEmoji: '🍇', per100gCalories: 299, per100gProtein: 3.1, per100gCarbs: 79.0, per100gFat: 0.5),
    FoodItem(id: '14', name: 'Banana (Raw)', iconEmoji: '🍌', per100gCalories: 89, per100gProtein: 1.1, per100gCarbs: 22.8, per100gFat: 0.3),
  ];

  static List<WorkoutExercise> defaultWorkouts = [
    WorkoutExercise(name: 'Barbell Back Squat', targetMuscle: 'Quads & Glutes', sets: 4, reps: '10-12 reps', restSeconds: '90s'),
    WorkoutExercise(name: 'Incline DB Bench Press', targetMuscle: 'Upper Chest', sets: 4, reps: '10-12 reps', restSeconds: '60s'),
    WorkoutExercise(name: 'Lat Pulldown', targetMuscle: 'Lats & Upper Back', sets: 4, reps: '10-12 reps', restSeconds: '60s'),
    WorkoutExercise(name: 'DB Romanian Deadlift', targetMuscle: 'Hamstrings', sets: 3, reps: '10-12 reps', restSeconds: '60s'),
    WorkoutExercise(name: 'Seated DB Shoulder Press', targetMuscle: 'Deltoids', sets: 3, reps: '10-12 reps', restSeconds: '60s'),
    WorkoutExercise(name: 'Rope Triceps Pushdown', targetMuscle: 'Triceps', sets: 3, reps: '12-15 reps', restSeconds: '45s'),
  ];
}
