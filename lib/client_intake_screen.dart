import 'package:flutter/material.dart';
import 'models.dart';
import 'planner_screen.dart';

class ClientIntakeScreen extends StatefulWidget {
  const ClientIntakeScreen({Key? key}) : super(key: key);

  @override
  State<ClientIntakeScreen> createState() => _ClientIntakeScreenState();
}

class _ClientIntakeScreenState extends State<ClientIntakeScreen> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController(text: "28");
  final _weightCtrl = TextEditingController(text: "75.0");
  final _heightCtrl = TextEditingController(text: "172.0");
  final _waterCtrl = TextEditingController(text: "3.5 - 4 Liters");
  final _notesCtrl = TextEditingController(
      text: "Creatine 3-5g daily. Progressive Overload prioritize karein.");

  String _gender = "Male";
  String _goal = "Fat Loss";
  double _activityMultiplier = 1.4;
  MedicalCondition _condition = MedicalCondition.none;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _waterCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  ClientProfile _buildClientProfile() {
    final name = _nameCtrl.text.trim().isEmpty ? "Client" : _nameCtrl.text.trim();
    final age = int.tryParse(_ageCtrl.text.trim()) ?? 28;
    final weight = double.tryParse(_weightCtrl.text.trim()) ?? 75.0;
    final height = double.tryParse(_heightCtrl.text.trim()) ?? 172.0;

    final profile = ClientProfile(
      name: name,
      age: age,
      gender: _gender,
      weightKg: weight,
      heightCm: height,
      activityMultiplier: _activityMultiplier,
      condition: _condition,
      goal: _goal,
      dailyWater: _waterCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );

    profile.targetCalories = profile.calculatedTargetCalories;
    return profile;
  }

  void _proceedToPlanner() {
    final profile = _buildClientProfile();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => PlannerScreen(initialClient: profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewProfile = _buildClientProfile();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          "fitwithRahul - Client Intake",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: "Client Name", border: OutlineInputBorder(), isDense: true),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Age (yrs)", border: OutlineInputBorder(), isDense: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
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
          const SizedBox(height: 12),
          Row(
            children: [
              const Text("Gender: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ...['Male', 'Female'].map((g) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(g, style: const TextStyle(fontSize: 12)),
                    selected: _gender == g,
                    selectedColor: const Color(0xFFF59E0B),
                    onSelected: (v) => setState(() => _gender = g),
                  ),
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text("Goal: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ...['Fat Loss', 'Muscle Gain', 'Body Recomp'].map((g) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: ChoiceChip(
                    label: Text(g, style: const TextStyle(fontSize: 11)),
                    selected: _goal == g,
                    selectedColor: const Color(0xFFF59E0B),
                    onSelected: (v) => setState(() => _goal = g),
                  ),
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<MedicalCondition>(
            value: _condition,
            decoration: const InputDecoration(labelText: "Medical / Endocrine Profile", border: OutlineInputBorder(), isDense: true),
            items: MedicalCondition.values.map((c) {
              return DropdownMenuItem(value: c, child: Text(c.name.toUpperCase(), style: const TextStyle(fontSize: 12)));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _condition = val);
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<double>(
            value: _activityMultiplier,
            decoration: const InputDecoration(labelText: "Activity Multiplier", border: OutlineInputBorder(), isDense: true),
            items: const [
              DropdownMenuItem(value: 1.2, child: Text("1.2 - Sedentary", style: TextStyle(fontSize: 12))),
              DropdownMenuItem(value: 1.4, child: Text("1.4 - Light / Active", style: TextStyle(fontSize: 12))),
              DropdownMenuItem(value: 1.55, child: Text("1.55 - Moderate", style: TextStyle(fontSize: 12))),
              DropdownMenuItem(value: 1.72, child: Text("1.72 - Very Active", style: TextStyle(fontSize: 12))),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _activityMultiplier = val);
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _waterCtrl,
            decoration: const InputDecoration(labelText: "Daily Water", border: OutlineInputBorder(), isDense: true),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notesCtrl,
            decoration: const InputDecoration(labelText: "Coach Notes", border: OutlineInputBorder(), isDense: true),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Estimated TDEE: ${previewProfile.adjustedTdee.toStringAsFixed(0)} kcal", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  "Recommended Target: ${previewProfile.calculatedTargetCalories.toStringAsFixed(0)} kcal",
                  style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.arrow_forward, color: Colors.black),
              label: const Text("Continue to Diet & Workout Builder", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              onPressed: _proceedToPlanner,
            ),
          ),
        ],
      ),
    );
  }
}