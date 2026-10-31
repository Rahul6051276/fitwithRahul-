import 'package:flutter/material.dart';
import 'models.dart';
import 'pdf_service.dart';

class ClientOverviewScreen extends StatelessWidget {
  final ClientProfile client;
  final VoidCallback onEdit;

  const ClientOverviewScreen({
    Key? key,
    required this.client,
    required this.onEdit,
  }) : super(key: key);

  String get _conditionDisplay {
    switch (client.condition) {
      case MedicalCondition.thyroid:
        return "Hypothyroidism (-12% Meta)";
      case MedicalCondition.pcod:
        return "PCOD / PCOS (-10% Meta)";
      case MedicalCondition.diabetes:
        return "Diabetes Type-2 (-8%)";
      case MedicalCondition.none:
      default:
        return "Normal / Healthy";
    }
  }

  @override
  Widget build(BuildContext context) {
    final diet = client.dietPlan;
    final totalCal = diet.totalCalories;
    final totalPro = diet.totalProtein;
    final totalCarb = diet.totalCarbs;
    final totalFat = diet.totalFats;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Text(
          "${client.name} - Plan Overview",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            tooltip: "Edit Plan",
            icon: const Icon(Icons.edit, color: Color(0xFFF59E0B)),
            onPressed: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // 1. CLIENT METRIC & CLINICAL CARD
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      client.name.toUpperCase(),
                      style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        client.goal.toUpperCase(),
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Age: ${client.age} yrs | Weight: ${client.weightKg} kg | Height: ${client.heightCm} cm",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  "Medical / Endocrine Profile: $_conditionDisplay",
                  style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const Divider(color: Colors.white24, height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Target Cal: ${client.targetCalories.toStringAsFixed(0)} kcal",
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    Text("Actual Plan: ${totalCal.toStringAsFixed(0)} kcal",
                        style: TextStyle(
                          color: (totalCal > client.targetCalories + 100)
                              ? Colors.redAccent
                              : const Color(0xFF10B981),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Daily Macros: P: ${totalPro.toStringAsFixed(0)}g | C: ${totalCarb.toStringAsFixed(0)}g | F: ${totalFat.toStringAsFixed(0)}g",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. MEALS BREAKDOWN (CLEAN READ-ONLY LIST)
          _buildMealSection("MEAL 1 (Breakfast)", diet.meal1),
          _buildMealSection("MEAL 2 (Mid-Morning)", diet.meal2),
          _buildMealSection("MEAL 3 (Lunch)", diet.meal3),
          _buildMealSection("MEAL 4 (Evening Snack)", diet.meal4),
          _buildMealSection("MEAL 5 (Dinner)", diet.meal5),

          // 3. COACH NOTES CARD
          if (client.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Coach Notes & Hydration:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Text(client.notes, style: const TextStyle(fontSize: 11, color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text("Water Target: ${client.dailyWater}",
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0284C7))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 80), // Bottom bar spacing
        ],
      ),

      // BOTTOM ACTION BUTTONS
      bottomSheet: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.edit_note, color: Colors.black),
                label: const Text("EDIT / ADJUST",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text("SHARE PDF",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: () async {
                  await PdfService.generateAndShareDietPdf(
                    clientName: client.name,
                    fitnessGoal: client.goal,
                    targetCalories: client.targetCalories.toStringAsFixed(0),
                    dailyWater: client.dailyWater,
                    coachNotes: client.notes,
                    plan: client.dietPlan,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(String title, List<MealEntry> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    double mealCals = entries.fold(0.0, (prev, e) => prev + e.calories);
    double mealPro = entries.fold(0.0, (prev, e) => prev + e.protein);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
              Text(
                "${mealCals.toStringAsFixed(0)} kcal | P: ${mealPro.toStringAsFixed(0)}g",
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFF59E0B)),
              ),
            ],
          ),
          const Divider(height: 12),
          ...entries.map((entry) {
            String qtyText = entry.food.unit == 'pcs' || entry.food.unit == 'tbsp' || entry.food.unit == 'scoop'
                ? "${entry.quantity.toStringAsFixed(0)} ${entry.food.unit}"
                : "${entry.quantity.toStringAsFixed(0)}g";

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.5),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "${entry.food.name} ($qtyText)",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    "${entry.calories.toStringAsFixed(0)} kcal (P: ${entry.protein.toStringAsFixed(0)}g)",
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
