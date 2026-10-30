import 'models.dart';

class AppDataSheets {
  static const List<FoodItem> foodDatabase = [
    FoodItem(id: '1', name: 'Whole Boiled Egg', servingUnit: '1 egg (~50g)', calories: 72, protein: 6.3, carbs: 0.4, fats: 4.8),
    FoodItem(id: '2', name: 'Egg White (Boiled)', servingUnit: '1 egg white', calories: 17, protein: 3.6, carbs: 0.2, fats: 0.1),
    FoodItem(id: '3', name: 'Whey Protein Isolate', servingUnit: '1 scoop (30g)', calories: 120, protein: 25.0, carbs: 1.5, fats: 1.0),
    FoodItem(id: '4', name: 'Soya Chunks (Raw)', servingUnit: '100g', calories: 345, protein: 52.0, carbs: 33.0, fats: 0.5),
    FoodItem(id: '5', name: 'Moong Sprouts (Raw)', servingUnit: '100g', calories: 105, protein: 7.0, carbs: 19.0, fats: 0.4),
    FoodItem(id: '6', name: 'Paneer (Raw)', servingUnit: '100g', calories: 265, protein: 18.0, carbs: 2.0, fats: 20.0),
    FoodItem(id: '7', name: 'Rolled Oats (Raw)', servingUnit: '100g', calories: 389, protein: 16.9, carbs: 66.3, fats: 6.9),
    FoodItem(id: '8', name: 'Cooked White Rice', servingUnit: '100g', calories: 130, protein: 2.7, carbs: 28.0, fats: 0.3),
    FoodItem(id: '9', name: 'Wheat Chapati / Roti', servingUnit: '1 medium (35g)', calories: 85, protein: 3.0, carbs: 17.0, fats: 0.5),
    FoodItem(id: '10', name: 'Cooked Toor Daal', servingUnit: '1 bowl (150g)', calories: 120, protein: 7.5, carbs: 20.0, fats: 1.5),
    FoodItem(id: '11', name: 'Peanut Butter (Roasted)', servingUnit: '1 tbsp (32g)', calories: 190, protein: 8.0, carbs: 6.0, fats: 16.0),
    FoodItem(id: '12', name: 'Medjool Dates (Khajoor)', servingUnit: '2 dates (~48g)', calories: 133, protein: 0.9, carbs: 36.0, fats: 0.1),
    FoodItem(id: '13', name: 'Raisins (Kishmish)', servingUnit: '1 tbsp (15g)', calories: 45, protein: 0.5, carbs: 12.0, fats: 0.1),
    FoodItem(id: '14', name: 'Banana (Raw)', servingUnit: '1 medium (118g)', calories: 105, protein: 1.3, carbs: 27.0, fats: 0.3),
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
