import 'package:flutter/material.dart';
import 'models.dart';
import 'planner_screen.dart';

class ClientIntakeScreen extends StatefulWidget {
  const ClientIntakeScreen({Key? key}) : super(key: key);

  @override
  State<ClientIntakeScreen> createState() => _ClientIntakeScreenState();
}

class _ClientIntakeScreenState extends State<ClientIntakeScreen> {
  final _nameCtrl = TextEditingController(text: "Rahul Dhruw");
  final _ageCtrl = TextEditingController(text: "26");
  final _weightCtrl = TextEditingController(text: "75");
  final _heightCtrl = TextEditingController(text: "172");

  String _gender = 'Male';
  double _activity = 1.4; // Standard resistance training multiplier
  MedicalCondition _condition = MedicalCondition.none;
  String _goal = 'Fat Loss';

  ClientProfile get _currentAssessment {
    return ClientProfile(
      name: _nameCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text) ?? 25,
      gender: _gender,
      weightKg: double.tryParse(_weightCtrl.text) ?? 70,
      heightCm: double.tryParse(_heightCtrl.text) ?? 170,
      activityMultiplier: _activity,
      condition: _condition,
      goal: _goal,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final client = _currentAssessment;
    final bmr = client.adjustedBmr;
    final tdee = client.adjustedTdee;
    final targetCal = client.calculatedTargetCalories;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          "Clinical Assessment & BMR",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: "Client Full Name", border: OutlineInputBorder(), isDense: true),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Age (Years)", border: OutlineInputBorder(), isDense: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(labelText: "Gender", border: OutlineInputBorder(), isDense: true),
                  items: ['Male', 'Female'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _gender = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Weight (kg)", border: OutlineInputBorder(), isDense: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _heightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Height (cm)", border: OutlineInputBorder(), isDense: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Medical Profile Selector
          const Text("Medical / Endocrine Profile:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ChoiceChip(
                label: const Text("Normal / Healthy", style: TextStyle(fontSize: 11)),
                selected: _condition == MedicalCondition.none,
                selectedColor: const Color(0xFFF59E0B),
                onSelected: (_) => setState(() => _condition = MedicalCondition.none),
              ),
              ChoiceChip(
                label: const Text("Thyroid (-12% Meta)", style: TextStyle(fontSize: 11)),
                selected: _condition == MedicalCondition.thyroid,
                selectedColor: const Color(0xFFF59E0B),
                onSelected: (_) => setState(() => _condition = MedicalCondition.thyroid),
              ),
              ChoiceChip(
                label: const Text("PCOD / PCOS (-10% Meta)", style: TextStyle(fontSize: 11)),
                selected: _condition == MedicalCondition.pcod,
                selectedColor: const Color(0xFFF59E0B),
                onSelected: (_) => setState(() => _condition = MedicalCondition.pcod),
              ),
              ChoiceChip(
                label: const Text("Diabetes Type-2 (-8%)", style: TextStyle(fontSize: 11)),
                selected: _condition == MedicalCondition.diabetes,
                selectedColor: const Color(0xFFF59E0B),
                onSelected: (_) => setState(() => _condition = MedicalCondition.diabetes),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Goal Selector
          const Text("Target Fitness Goal:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          Row(
            children: ['Fat Loss', 'Muscle Gain', 'Body Recomp'].map((g) {
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: ChoiceChip(
                  label: Text(g, style: const TextStyle(fontSize: 11)),
                  selected: _goal == g,
                  selectedColor: const Color(0xFFF59E0B),
                  onSelected: (_) => setState(() => _goal = g),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Science Calculation Output Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("METABOLIC SCIENCE REPORT", style: TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 13)),
                const Divider(color: Colors.white24, height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Base BMR: ${client.baseBmr.toStringAsFixed(0)} kcal", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    Text("Adjusted BMR: ${bmr.toStringAsFixed(0)} kcal", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Maintenance (TDEE): ${tdee.toStringAsFixed(0)} kcal", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    Text("Calibrated Target: ${targetCal.toStringAsFixed(0)} kcal", style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Proceed Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.arrow_forward, color: Colors.black),
            label: const Text(
              "PROCEED TO DIET & WORKOUT BUILDER",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: () {
              String conditionNote = _condition != MedicalCondition.none
                  ? "Medical Profile: ${_condition.name.toUpperCase()} (Low-GI prioritized). "
                  : "";

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => PlannerScreen(
                    initialClientName: client.name,
                    initialTargetCalories: targetCal,
                    initialGoal: client.goal,
                    initialNotes: "${conditionNote}Creatine 3-5g daily. Progressive Overload prioritize karein.",
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
