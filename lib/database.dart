import 'package:flutter/material.dart';
import 'models.dart';

class AppDataSheets {
  static const List<FoodItem> foodDatabase = [
    FoodItem(id: '1', name: 'Rolled Oats (Raw)', icon: Icons.breakfast_dining, per100gCalories: 389, per100gProtein: 16.9, per100gCarbs: 66.3, per100gFat: 6.9, tbspWeight: 10.0, tspWeight: 3.5),
    FoodItem(id: '2', name: 'Whole Boiled Egg', icon: Icons.egg, per100gCalories: 144, per100gProtein: 12.6, per100gCarbs: 0.8, per100gFat: 9.6, pieceWeight: 50.0),
    FoodItem(id: '3', name: 'Egg White (Boiled)', icon: Icons.egg_outlined, per100gCalories: 52, per100gProtein: 11.0, per100gCarbs: 0.7, per100gFat: 0.2, pieceWeight: 33.0),
    FoodItem(id: '4', name: 'Whey Protein Isolate', icon: Icons.local_drink, per100gCalories: 400, per100gProtein: 83.3, per100gCarbs: 5.0, per100gFat: 3.3, pieceWeight: 33.0, tbspWeight: 12.0),
    FoodItem(id: '5', name: 'Soya Chunks (Raw)', icon: Icons.grain, per100gCalories: 345, per100gProtein: 52.0, per100gCarbs: 33.0, per100gFat: 0.5, tbspWeight: 10.0),
    FoodItem(id: '6', name: 'Moong Sprouts (Raw)', icon: Icons.eco, per100gCalories: 105, per100gProtein: 7.0, per100gCarbs: 19.0, per100gFat: 0.4, tbspWeight: 15.0),
    FoodItem(id: '7', name: 'Paneer (Raw)', icon: Icons.lunch_dining, per100gCalories: 265, per100gProtein: 18.0, per100gCarbs: 2.0, per100gFat: 20.0, tbspWeight: 20.0),
    FoodItem(id: '8', name: 'Cooked White Rice', icon: Icons.rice_bowl, per100gCalories: 130, per100gProtein: 2.7, per100gCarbs: 28.0, per100gFat: 0.3, tbspWeight: 25.0),
    FoodItem(id: '9', name: 'Wheat Chapati / Roti', icon: Icons.circle, per100gCalories: 242, per100gProtein: 8.5, per100gCarbs: 48.5, per100gFat: 1.4, pieceWeight: 35.0),
    FoodItem(id: '10', name: 'Cooked Toor Daal', icon: Icons.soup_kitchen, per100gCalories: 80, per100gProtein: 5.0, per100gCarbs: 13.3, per100gFat: 1.0, tbspWeight: 20.0),
    FoodItem(id: '11', name: 'Peanut Butter (100% Roasted)', icon: Icons.cookie, per100gCalories: 588, per100gProtein: 25.0, per100gCarbs: 20.0, per100gFat: 50.0, tbspWeight: 16.0, tspWeight: 6.0),
    FoodItem(id: '12', name: 'Medjool Dates (Khajoor)', icon: Icons.spa, per100gCalories: 277, per100gProtein: 1.8, per100gCarbs: 75.0, per100gFat: 0.2, pieceWeight: 24.0),
    FoodItem(id: '13', name: 'Raisins (Kishmish)', icon: Icons.bubble_chart, per100gCalories: 299, per100gProtein: 3.1, per100gCarbs: 79.0, per100gFat: 0.5, tbspWeight: 15.0, tspWeight: 5.0),
    FoodItem(id: '14', name: 'Banana (Raw)', icon: Icons.energy_savings_leaf, per100gCalories: 89, per100gProtein: 1.1, per100gCarbs: 22.8, per100gFat: 0.3, pieceWeight: 118.0),
  ];

  static final List<WorkoutExercise> exerciseMasterList = [
    WorkoutExercise(id: 'w1', name: 'Flat Barbell Bench Press', category: 'Chest', sets: 4, reps: '10-12 reps', restSeconds: '90s'),
    WorkoutExercise(id: 'w2', name: 'Incline Dumbbell Press', category: 'Chest', sets: 3, reps: '10-12 reps', restSeconds: '60s'),
    WorkoutExercise(id: 'w3', name: 'Cable Chest Flyes', category: 'Chest', sets: 3, reps: '12-15 reps', restSeconds: '45s'),
    WorkoutExercise(id: 'w4', name: 'Lat Pulldown', category: 'Back', sets: 4, reps: '10-12 reps', restSeconds: '60s'),
    WorkoutExercise(id: 'w5', name: 'Seated Cable Row', category: 'Back', sets: 4, reps: '10-12 reps', restSeconds: '60s'),
    WorkoutExercise(id: 'w6', name: 'Barbell Back Squat', category: 'Legs', sets: 4, reps: '10-12 reps', restSeconds: '90s'),
    WorkoutExercise(id: 'w7', name: 'Romanian Deadlift (DB/BB)', category: 'Legs', sets: 3, reps: '10-12 reps', restSeconds: '60s'),
    WorkoutExercise(id: 'w8', name: 'Seated DB Overhead Press', category: 'Shoulders', sets: 4, reps: '10-12 reps', restSeconds: '60s'),
    WorkoutExercise(id: 'w9', name: 'Dumbbell Lateral Raises', category: 'Shoulders', sets: 4, reps: '12-15 reps', restSeconds: '45s'),
    WorkoutExercise(id: 'w10', name: 'Barbell Bicep Curl', category: 'Arms', sets: 3, reps: '10-12 reps', restSeconds: '45s'),
    WorkoutExercise(id: 'w11', name: 'Rope Triceps Pushdown', category: 'Arms', sets: 3, reps: '12-15 reps', restSeconds: '45s'),
    WorkoutExercise(id: 'w12', name: 'Hanging Leg Raises', category: 'Core', sets: 3, reps: '15 reps', restSeconds: '45s'),
  ];
}
