import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class AppDatabase {
  // --- DEFAULT FOOD DATABASE ---
  static const List<FoodItem> initialFoodDatabase = [
    // PROTEINS & DAIRY
    FoodItem(id: 'wh_egg', name: 'Whole Boiled Egg', calories: 78, protein: 6.3, carbs: 0.6, fats: 5.3, unit: 'pcs', pieceWeight: 50.0, icon: Icons.egg),
    FoodItem(id: 'egg_white', name: 'Egg White (Boiled)', calories: 17, protein: 3.6, carbs: 0.2, fats: 0.1, unit: 'pcs', pieceWeight: 33.0, icon: Icons.egg_outlined),
    FoodItem(id: 'soya_chunks', name: 'Soya Chunks (Raw)', calories: 345, protein: 52.0, carbs: 33.0, fats: 0.5, unit: 'g', icon: Icons.grain),
    FoodItem(id: 'low_fat_paneer', name: 'Low Fat Paneer', calories: 200, protein: 20.0, carbs: 4.0, fats: 12.0, unit: 'g', icon: Icons.lunch_dining),
    FoodItem(id: 'regular_paneer', name: 'Regular Paneer', calories: 296, protein: 18.0, carbs: 4.5, fats: 23.0, unit: 'g', icon: Icons.lunch_dining),
    FoodItem(id: 'whey_protein', name: 'Whey Protein', calories: 120, protein: 24.0, carbs: 2.5, fats: 1.5, unit: 'scoop', scoopWeight: 30.0, icon: Icons.fitness_center),
    FoodItem(id: 'chicken_breast', name: 'Chicken Breast (Raw)', calories: 120, protein: 22.5, carbs: 0.0, fats: 2.6, unit: 'g', icon: Icons.restaurant),
    FoodItem(id: 'tofu_raw', name: 'Tofu (Soy Paneer)', calories: 76, protein: 8.0, carbs: 1.9, fats: 4.8, unit: 'g', icon: Icons.kitchen),

    // GRAINS & CARBS
    FoodItem(id: 'rolled_oats', name: 'Rolled Oats (Raw)', calories: 389, protein: 16.9, carbs: 66.3, fats: 6.9, unit: 'g', icon: Icons.breakfast_dining),
    FoodItem(id: 'white_rice', name: 'White Rice (Cooked)', calories: 130, protein: 2.7, carbs: 28.2, fats: 0.3, unit: 'g', icon: Icons.rice_bowl),
    FoodItem(id: 'brown_rice', name: 'Brown Rice (Cooked)', calories: 111, protein: 2.6, carbs: 23.0, fats: 0.9, unit: 'g', icon: Icons.rice_bowl),
    FoodItem(id: 'wheat_roti', name: 'Wheat Roti (Plain)', calories: 120, protein: 3.5, carbs: 22.0, fats: 2.0, unit: 'pcs', pieceWeight: 35.0, icon: Icons.circle),
    FoodItem(id: 'dalia_cooked', name: 'Wheat Dalia (Cooked)', calories: 85, protein: 3.0, carbs: 18.0, fats: 0.3, unit: 'g', icon: Icons.soup_kitchen),
    FoodItem(id: 'boiled_potato', name: 'Boiled Potato', calories: 87, protein: 1.9, carbs: 20.0, fats: 0.1, unit: 'g', icon: Icons.circle_outlined),
    FoodItem(id: 'sweet_potato', name: 'Sweet Potato (Shakarkand)', calories: 86, protein: 1.6, carbs: 20.1, fats: 0.1, unit: 'g', icon: Icons.circle_outlined),

    // LEGUMES & SPROUTS
    FoodItem(id: 'moong_sprouts', name: 'Moong Sprouts (Raw)', calories: 105, protein: 7.0, carbs: 19.0, fats: 0.4, unit: 'g', icon: Icons.spa),
    FoodItem(id: 'boiled_chana', name: 'Boiled Black Chana', calories: 164, protein: 8.9, carbs: 27.4, fats: 2.6, unit: 'g', icon: Icons.circle),

    // NUTS & HEALTHY FATS
    FoodItem(id: 'peanut_butter', name: 'Peanut Butter (Unsweetened)', calories: 95, protein: 4.0, carbs: 3.0, fats: 8.0, unit: 'tbsp', tbspWeight: 16.0, icon: Icons.breakfast_dining),
    FoodItem(id: 'almonds_raw', name: 'Raw Almonds (Badam)', calories: 579, protein: 21.0, carbs: 21.6, fats: 49.9, unit: 'pcs', pieceWeight: 1.2, icon: Icons.energy_savings_leaf),
    FoodItem(id: 'cashews_raw', name: 'Raw Cashews (Kaju)', calories: 553, protein: 18.2, carbs: 30.2, fats: 43.8, unit: 'pcs', pieceWeight: 1.5, icon: Icons.nature),
    FoodItem(id: 'olive_oil', name: 'Extra Virgin Olive Oil', calories: 884, protein: 0.0, carbs: 0.0, fats: 100.0, unit: 'tbsp', tbspWeight: 14.0, tspWeight: 4.5, icon: Icons.opacity),
    FoodItem(id: 'pure_ghee', name: 'Pure Desi Ghee', calories: 900, protein: 0.0, carbs: 0.0, fats: 100.0, unit: 'tbsp', tbspWeight: 14.0, tspWeight: 4.5, icon: Icons.format_color_fill),

    // FRUITS & SWEETS
    FoodItem(id: 'dates_khajoor', name: 'Dates (Khajoor)', calories: 20, protein: 0.2, carbs: 5.3, fats: 0.1, unit: 'pcs', pieceWeight: 10.0, icon: Icons.brightness_1),
    FoodItem(id: 'raisins_kishmish', name: 'Raisins (Kishmish)', calories: 299, protein: 3.1, carbs: 79.2, fats: 0.5, unit: 'tbsp', tbspWeight: 12.0, icon: Icons.grain),
    FoodItem(id: 'fresh_banana', name: 'Banana (Medium)', calories: 89, protein: 1.1, carbs: 23.0, fats: 0.3, unit: 'pcs', pieceWeight: 110.0, icon: Icons.food_bank),
    FoodItem(id: 'fresh_apple', name: 'Fresh Apple', calories: 52, protein: 0.3, carbs: 13.8, fats: 0.2, unit: 'pcs', pieceWeight: 150.0, icon: Icons.apple),
    FoodItem(id: 'cucumber_salad', name: 'Cucumber (Kheera)', calories: 15, protein: 0.7, carbs: 3.6, fats: 0.1, unit: 'pcs', pieceWeight: 120.0, icon: Icons.grass),
    FoodItem(id: 'roasted_makhana', name: 'Roasted Makhana', calories: 350, protein: 9.7, carbs: 76.0, fats: 0.1, unit: 'g', icon: Icons.grain),
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
