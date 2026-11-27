import 'package:flutter/material.dart';
import 'models.dart';

class AppDatabase {
  static const List<FoodItem> initialFoodDatabase = [
    // Grains, Oats, Rice & Flours (100g)
    FoodItem(id: 'f1', name: 'Oats (Uncooked)', calories: 381.9, protein: 13.15, carbs: 67.7, fats: 6.5, unit: 'g', icon: Icons.breakfast_dining),
    FoodItem(id: 'f2', name: 'Oats (Cooked)', calories: 73.5, protein: 3.0, carbs: 12.0, fats: 1.5, unit: 'g', icon: Icons.breakfast_dining),
    FoodItem(id: 'f3', name: 'Daliya (Uncooked)', calories: 359.7, protein: 12.0, carbs: 75.0, fats: 1.3, unit: 'g', icon: Icons.soup_kitchen),
    FoodItem(id: 'f4', name: 'Daliya (Cooked)', calories: 105.5, protein: 3.0, carbs: 20.0, fats: 1.5, unit: 'g', icon: Icons.soup_kitchen),
    FoodItem(id: 'f5', name: 'Poha (Uncooked)', calories: 341.9, protein: 7.0, carbs: 76.0, fats: 1.1, unit: 'g', icon: Icons.grain),
    FoodItem(id: 'f6', name: 'Poha (Cooked)', calories: 131.9, protein: 2.5, carbs: 28.0, fats: 1.1, unit: 'g', icon: Icons.grain),
    FoodItem(id: 'f7', name: 'Wheat Flakes (Uncooked)', calories: 353.5, protein: 10.0, carbs: 75.0, fats: 1.5, unit: 'g', icon: Icons.grain),
    FoodItem(id: 'f8', name: 'Muesli (Uncooked)', calories: 365.0, protein: 10.0, carbs: 70.0, fats: 5.0, unit: 'g', icon: Icons.breakfast_dining),
    FoodItem(id: 'f9', name: 'White Rice (Uncooked)', calories: 364.0, protein: 7.0, carbs: 78.0, fats: 2.7, unit: 'g', icon: Icons.rice_bowl),
    FoodItem(id: 'f10', name: 'White Rice (Cooked)', calories: 125.5, protein: 2.7, carbs: 28.0, fats: 0.3, unit: 'g', icon: Icons.rice_bowl),
    FoodItem(id: 'f11', name: 'Brown Rice (Uncooked)', calories: 358.3, protein: 7.5, carbs: 76.0, fats: 2.7, unit: 'g', icon: Icons.rice_bowl),
    FoodItem(id: 'f12', name: 'Brown Rice (Cooked)', calories: 114.7, protein: 3.0, carbs: 25.0, fats: 0.3, unit: 'g', icon: Icons.rice_bowl),
    FoodItem(id: 'f14', name: 'Wheat Flour (Uncooked)', calories: 350.5, protein: 12.0, carbs: 70.0, fats: 2.5, unit: 'g', icon: Icons.grain),
    FoodItem(id: 'f53', name: 'Besan', calories: 381.9, protein: 22.4, carbs: 58.0, fats: 6.7, unit: 'g', icon: Icons.grain),

    // Roti / Breads (pcs)
    FoodItem(id: 'f15', name: 'Roti (Cooked)', calories: 116.5, protein: 3.0, carbs: 25.0, fats: 0.5, unit: 'pcs', pieceWeight: 35.0, icon: Icons.circle),
    FoodItem(id: 'f65', name: 'Hotel Roti', calories: 85.0, protein: 1.4, carbs: 19.0, fats: 0.2, unit: 'pcs', pieceWeight: 45.0, icon: Icons.circle),
    FoodItem(id: 'f66', name: 'Chapati Cooked (35gm)', calories: 92.0, protein: 3.0, carbs: 19.5, fats: 0.5, unit: 'pcs', pieceWeight: 35.0, icon: Icons.circle),

    // Core Proteins, Eggs & Supplements
    FoodItem(id: 'f16', name: 'Paneer (Raw)', calories: 258.0, protein: 18.0, carbs: 1.5, fats: 20.0, unit: 'g', icon: Icons.lunch_dining),
    FoodItem(id: 'f17', name: 'Egg (Boiled)', calories: 70.2, protein: 6.3, carbs: 0.0, fats: 5.0, unit: 'pcs', pieceWeight: 50.0, icon: Icons.egg),
    FoodItem(id: 'f31', name: 'Egg Whites', calories: 14.0, protein: 3.5, carbs: 0.0, fats: 0.0, unit: 'pcs', pieceWeight: 33.0, icon: Icons.egg_outlined),
    FoodItem(id: 'f18', name: 'Chicken (Raw)', calories: 156.4, protein: 31.0, carbs: 0.0, fats: 3.6, unit: 'g', icon: Icons.restaurant),
    FoodItem(id: 'f19', name: 'Whey Protein', calories: 385.0, protein: 80.0, carbs: 5.0, fats: 5.0, unit: 'g', scoopWeight: 30.0, icon: Icons.fitness_center),
    FoodItem(id: 'f49', name: 'Nakpro Perform Whey Protein', calories: 394.0, protein: 70.0, carbs: 16.69, fats: 5.28, unit: 'g', scoopWeight: 30.0, icon: Icons.fitness_center),
    FoodItem(id: 'f64', name: 'Herbalife Whey Protein', calories: 349.5, protein: 48.0, carbs: 36.0, fats: 1.5, unit: 'g', scoopWeight: 30.0, icon: Icons.fitness_center),
    FoodItem(id: 'f29', name: 'Soya Chunks', calories: 349.0, protein: 52.0, carbs: 33.0, fats: 1.0, unit: 'g', icon: Icons.grain),

    // Lentils, Legumes & Chana (100g)
    FoodItem(id: 'f20', name: 'Toor Daal (Uncooked)', calories: 335.3, protein: 22.0, carbs: 58.0, fats: 1.7, unit: 'g', icon: Icons.circle),
    FoodItem(id: 'f21', name: 'Toor Daal (Cooked)', calories: 107.7, protein: 7.0, carbs: 18.8, fats: 0.5, unit: 'g', icon: Icons.soup_kitchen),
    FoodItem(id: 'f30', name: 'Roasted Chana', calories: 370.0, protein: 19.0, carbs: 60.0, fats: 6.0, unit: 'g', icon: Icons.circle),
    FoodItem(id: 'f32', name: 'Chickpeas White Small', calories: 365.0, protein: 20.0, carbs: 60.0, fats: 5.0, unit: 'g', icon: Icons.circle),
    FoodItem(id: 'f33', name: 'Chickpeas White Big', calories: 370.0, protein: 19.0, carbs: 60.0, fats: 6.0, unit: 'g', icon: Icons.circle),
    FoodItem(id: 'f34', name: 'Whole Moong Daal', calories: 354.0, protein: 24.0, carbs: 62.0, fats: 1.2, unit: 'g', icon: Icons.spa),
    FoodItem(id: 'f35', name: 'Kaala Desi Chana', calories: 357.0, protein: 18.0, carbs: 60.0, fats: 5.0, unit: 'g', icon: Icons.circle),
    FoodItem(id: 'f36', name: 'Red Kidney Beans', calories: 345.0, protein: 24.0, carbs: 60.0, fats: 1.0, unit: 'g', icon: Icons.circle),

    // Fruits & Veggies
    FoodItem(id: 'f22', name: 'Apple', calories: 64.7, protein: 0.5, carbs: 15.0, fats: 0.3, unit: 'pcs', pieceWeight: 150.0, icon: Icons.apple),
    FoodItem(id: 'f23', name: 'Banana', calories: 99.1, protein: 1.1, carbs: 23.0, fats: 0.3, unit: 'pcs', pieceWeight: 110.0, icon: Icons.food_bank),
    FoodItem(id: 'f24', name: 'Orange', calories: 64.5, protein: 0.9, carbs: 15.0, fats: 0.1, unit: 'pcs', pieceWeight: 130.0, icon: Icons.circle_outlined),
    FoodItem(id: 'f25', name: 'Pear', calories: 60.9, protein: 0.0, carbs: 15.0, fats: 0.1, unit: 'pcs', pieceWeight: 150.0, icon: Icons.eco),
    FoodItem(id: 'f26', name: 'Papaya', calories: 52.7, protein: 0.5, carbs: 12.0, fats: 0.3, unit: 'g', icon: Icons.eco),
    FoodItem(id: 'f27', name: 'Guava', calories: 73.0, protein: 2.0, carbs: 14.0, fats: 1.0, unit: 'pcs', pieceWeight: 100.0, icon: Icons.eco),
    FoodItem(id: 'f48', name: 'Fox Nuts (Makhana)', calories: 352.0, protein: 9.0, carbs: 76.0, fats: 0.5, unit: 'g', icon: Icons.grain),
    FoodItem(id: 'f54', name: 'Potato', calories: 88.5, protein: 1.9, carbs: 20.0, fats: 0.1, unit: 'g', icon: Icons.circle_outlined),
    FoodItem(id: 'f56', name: 'Green Veggies', calories: 43.8, protein: 1.5, carbs: 9.0, fats: 0.2, unit: 'g', icon: Icons.grass),

    // Fats, Nut Butters, Nuts & Seeds
    FoodItem(id: 'f13', name: 'Oil (Any)', calories: 900.0, protein: 0.0, carbs: 0.0, fats: 100.0, unit: 'g', tbspWeight: 15.0, tspWeight: 5.0, icon: Icons.opacity),
    FoodItem(id: 'f57', name: 'Oil (Any) tsp', calories: 45.0, protein: 0.0, carbs: 0.0, fats: 5.0, unit: 'tsp', tbspWeight: 15.0, tspWeight: 5.0, icon: Icons.opacity),
    FoodItem(id: 'f28', name: 'Peanut Butter', calories: 626.0, protein: 25.0, carbs: 19.0, fats: 50.0, unit: 'g', tbspWeight: 16.0, tspWeight: 5.3, icon: Icons.breakfast_dining),
    FoodItem(id: 'f37', name: 'Peanut', calories: 609.0, protein: 26.0, carbs: 16.0, fats: 49.0, unit: 'g', icon: Icons.grain),
    FoodItem(id: 'f45', name: 'Almonds (Per pc)', calories: 7.4, protein: 0.25, carbs: 0.25, fats: 0.6, unit: 'pcs', pieceWeight: 1.2, icon: Icons.energy_savings_leaf),
    FoodItem(id: 'f55', name: 'Almonds (100g)', calories: 622.0, protein: 21.0, carbs: 22.0, fats: 50.0, unit: 'g', icon: Icons.energy_savings_leaf),
    FoodItem(id: 'f46', name: 'Dates (Per pc)', calories: 24.8, protein: 0.2, carbs: 6.0, fats: 0.0, unit: 'pcs', pieceWeight: 10.0, icon: Icons.brightness_1),
    FoodItem(id: 'f47', name: 'Raisins (100g)', calories: 328.0, protein: 3.1, carbs: 79.0, fats: 0.0, unit: 'g', icon: Icons.grain),
    FoodItem(id: 'f50', name: 'Raisins (Per pc)', calories: 1.7, protein: 0.02, carbs: 0.4, fats: 0.003, unit: 'pcs', pieceWeight: 0.5, icon: Icons.grain),
    FoodItem(id: 'f58', name: 'Chia Seeds (tsp)', calories: 24.0, protein: 0.8, carbs: 2.1, fats: 1.6, unit: 'tsp', tspWeight: 5.0, icon: Icons.spa),
    FoodItem(id: 'f59', name: 'Flaxseeds (tsp)', calories: 27.0, protein: 0.9, carbs: 1.4, fats: 2.1, unit: 'tsp', tspWeight: 5.0, icon: Icons.spa),
    FoodItem(id: 'f60', name: 'Pumpkin Seeds (tsp)', calories: 28.0, protein: 1.5, carbs: 0.7, fats: 2.4, unit: 'tsp', tspWeight: 5.0, icon: Icons.spa),
    FoodItem(id: 'f61', name: 'Sunflower Seeds (tsp)', calories: 29.0, protein: 1.1, carbs: 1.0, fats: 2.6, unit: 'tsp', tspWeight: 5.0, icon: Icons.spa),
    FoodItem(id: 'f62', name: 'Sesame Seeds (tsp)', calories: 26.0, protein: 0.9, carbs: 1.2, fats: 2.4, unit: 'tsp', tspWeight: 5.0, icon: Icons.spa),
    FoodItem(id: 'f63', name: 'Watermelon Seeds (tsp)', calories: 28.0, protein: 1.4, carbs: 0.8, fats: 2.3, unit: 'tsp', tspWeight: 5.0, icon: Icons.spa),

    // Dairy & Sweeteners
    FoodItem(id: 'f38', name: 'Curd / Dahi', calories: 83.6, protein: 8.0, carbs: 3.45, fats: 4.2, unit: 'g', icon: Icons.icecream),
    FoodItem(id: 'f39', name: 'Milk', calories: 50.0, protein: 3.29, carbs: 4.71, fats: 2.0, unit: 'g', icon: Icons.local_drink),
    FoodItem(id: 'f40', name: 'Amul Milk', calories: 61.0, protein: 3.5, carbs: 5.0, fats: 3.0, unit: 'g', icon: Icons.local_drink),
    FoodItem(id: 'f41', name: 'Amul Dahi Masti', calories: 62.0, protein: 3.5, carbs: 5.0, fats: 3.1, unit: 'g', icon: Icons.icecream),
    FoodItem(id: 'f42', name: 'Amul Butter Milk', calories: 28.2, protein: 1.9, carbs: 2.9, fats: 1.0, unit: 'g', icon: Icons.local_drink),
    FoodItem(id: 'f43', name: 'Amul Butter', calories: 722.0, protein: 0.5, carbs: 0.0, fats: 80.0, unit: 'g', tbspWeight: 14.0, tspWeight: 4.7, icon: Icons.format_color_fill),
    FoodItem(id: 'f44', name: 'Amul Cheese Slice', calories: 314.0, protein: 20.0, carbs: 1.4, fats: 25.0, unit: 'g', pieceWeight: 20.0, icon: Icons.lunch_dining),
    FoodItem(id: 'f51', name: 'Sugar (Per unit)', calories: 60.0, protein: 0.0, carbs: 15.0, fats: 0.0, unit: 'pcs', pieceWeight: 15.0, icon: Icons.grain),
    FoodItem(id: 'f52', name: 'Jaggery Powder', calories: 382.5, protein: 0.4, carbs: 95.0, fats: 0.1, unit: 'g', icon: Icons.grain),
  ];

  // --- DEFAULT EXERCISE MASTER DATABASE ---
  static const List<WorkoutExercise> initialExerciseDatabase = [
    // CHEST
    WorkoutExercise(id: 'ch1', name: 'Barbell Flat Bench Press', category: 'Chest', sets: 4, reps: '8-10', restSeconds: '90s'),
    WorkoutExercise(id: 'ch2', name: 'Incline Dumbbell Press', category: 'Chest', sets: 3, reps: '10-12', restSeconds: '75s'),
    WorkoutExercise(id: 'ch3', name: 'Cable Low-to-High Flyes', category: 'Chest', sets: 3, reps: '12-15', restSeconds: '60s'),
    WorkoutExercise(id: 'ch4', name: 'Standard Push-Ups', category: 'Chest', sets: 3, reps: '15-20', restSeconds: '60s'),

    // BACK
    WorkoutExercise(id: 'bk1', name: 'Lat Pulldown (Wide Grip)', category: 'Back', sets: 4, reps: '10-12', restSeconds: '75s'),
    WorkoutExercise(id: 'bk2', name: 'Barbell Bent-Over Row', category: 'Back', sets: 4, reps: '8-10', restSeconds: '90s'),
    WorkoutExercise(id: 'bk3', name: 'Seated Cable Row', category: 'Back', sets: 3, reps: '10-12', restSeconds: '60s'),
    WorkoutExercise(id: 'bk4', name: 'One-Arm Dumbbell Row', category: 'Back', sets: 3, reps: '10-12', restSeconds: '60s'),

    // LEGS
    WorkoutExercise(id: 'lg1', name: 'Barbell Back Squat', category: 'Legs', sets: 4, reps: '8-10', restSeconds: '120s'),
    WorkoutExercise(id: 'lg2', name: 'Romanian Deadlift (RDL)', category: 'Legs', sets: 3, reps: '8-10', restSeconds: '90s'),
    WorkoutExercise(id: 'lg3', name: 'Leg Press Machine', category: 'Legs', sets: 3, reps: '10-12', restSeconds: '75s'),
    WorkoutExercise(id: 'lg4', name: 'Lying Hamstring Leg Curls', category: 'Legs', sets: 3, reps: '12-15', restSeconds: '60s'),
    WorkoutExercise(id: 'lg5', name: 'Standing Calf Raise', category: 'Legs', sets: 4, reps: '15-20', restSeconds: '45s'),

    // SHOULDERS
    WorkoutExercise(id: 'sh1', name: 'Overhead Dumbbell Shoulder Press', category: 'Shoulders', sets: 4, reps: '8-10', restSeconds: '75s'),
    WorkoutExercise(id: 'sh2', name: 'Dumbbell Lateral Raise', category: 'Shoulders', sets: 4, reps: '12-15', restSeconds: '45s'),
    WorkoutExercise(id: 'sh3', name: 'Cable Face Pulls', category: 'Shoulders', sets: 4, reps: '15', restSeconds: '45s'),

    // ARMS
    WorkoutExercise(id: 'ar1', name: 'EZ Bar Bicep Curl', category: 'Arms', sets: 3, reps: '10-12', restSeconds: '60s'),
    WorkoutExercise(id: 'ar2', name: 'Incline Dumbbell Hammer Curl', category: 'Arms', sets: 3, reps: '10-12', restSeconds: '60s'),
    WorkoutExercise(id: 'ar3', name: 'Triceps Rope Pushdown', category: 'Arms', sets: 3, reps: '12-15', restSeconds: '60s'),

    // CORE & HIIT
    WorkoutExercise(id: 'cr1', name: 'Standard Elbow Plank Hold', category: 'Core', sets: 3, reps: '60s hold', restSeconds: '45s'),
    WorkoutExercise(id: 'cr2', name: 'Russian Twists', category: 'Core', sets: 3, reps: '20 reps', restSeconds: '45s'),
    WorkoutExercise(id: 'cr3', name: 'Hanging Knee Raises', category: 'Core', sets: 3, reps: '12-15', restSeconds: '45s'),
    WorkoutExercise(id: 'ht1', name: 'Burpees (Chest-to-Floor)', category: 'HIIT', sets: 4, reps: '40s work', restSeconds: '20s'),
    WorkoutExercise(id: 'ht2', name: 'Battle Ropes Waves', category: 'HIIT', sets: 4, reps: '30s sprint', restSeconds: '30s'),
    WorkoutExercise(id: 'ht3', name: 'Kettlebell Swings', category: 'HIIT', sets: 4, reps: '20 reps', restSeconds: '30s'),
  ];

  static List<FoodItem> foods = [...initialFoodDatabase];
  static List<WorkoutExercise> exercises = [...initialExerciseDatabase];

  static Map<String, List<String>> get exercisesByCategory {
    Map<String, List<String>> map = {};
    for (var ex in exercises) {
      if (!map.containsKey(ex.category)) {
        map[ex.category] = [];
      }
      map[ex.category]!.add(ex.name);
    }
    return map;
  }
}