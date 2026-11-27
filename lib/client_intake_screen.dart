import 'package:flutter/material.dart';
import 'models.dart';
import 'planner_screen.dart';

class ClientIntakeScreen extends StatefulWidget {
  const ClientIntakeScreen({Key? key}) : super(key: key);

  @override
  State<ClientIntakeScreen> createState() => _ClientIntakeScreenState();
}

class _ClientIntakeScreenState extends State<ClientIntakeScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController(text: '28');
  final _weightController = TextEditingController(text: '75');
  final _heightController = TextEditingController(text: '172');
  final _waterController = TextEditingController(text: '3.5 - 4 L');
  final _notesController = TextEditingController(
      text: 'Creatine 3-5g daily. Progressive Overload prioritize karein.');

  String _gender = 'Male';
  String _goal = 'Fat Loss';
  double _activityMultiplier = 1.375;
  MedicalCondition _condition = MedicalCondition.none;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _waterController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  ClientProfile _buildProfile() {
    final name =
        _nameController.text.trim().isEmpty ? 'Client' : _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 28;
    final weight = double.tryParse(_weightController.text.trim()) ?? 75.0;
    final height = double.tryParse(_heightController.text.trim()) ?? 172.0;

    final profile = ClientProfile(
      name: name,
      age: age,
      gender: _gender,
      weightKg: weight,
      heightCm: height,
      activityMultiplier: _activityMultiplier,
      condition: _condition,
      goal: _goal,
      dailyWater: _waterController.text.trim(),
      notes: _notesController.text.trim(),
    );
    profile.targetCalories = profile.calculatedTargetCalories;
    return profile;
  }

  void _openPlanner() {
    final profile = _buildProfile();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => PlannerScreen(initialClient: profile),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: const Color(0xFFD97706)),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputStyle(String label, {IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
      prefixIcon:
          prefixIcon != null ? Icon(prefixIcon, size: 18, color: const Color(0xFF64748B)) : null,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = _buildProfile();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'fitwithRahul Coaching',
              style: TextStyle(
                color: Color(0xFFF59E0B),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'Client Assessment & Metabolic Intake',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // 1. CLIENT IDENTITY & ANTHROPOMETRICS
          _buildSectionCard(
            title: 'Client Profile & Body Metrics',
            icon: Icons.person_outline,
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: _inputStyle('Client Full Name', prefixIcon: Icons.badge_outlined),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: _inputStyle('Age (yrs)'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: _inputStyle('Weight (kg)'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: _inputStyle('Height (cm)'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Gender:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ...['Male', 'Female'].map((g) {
                      final active = _gender == g;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            g,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: active ? Colors.black : const Color(0xFF334155),
                            ),
                          ),
                          selected: active,
                          selectedColor: const Color(0xFFF59E0B),
                          backgroundColor: const Color(0xFFF8FAFC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: active
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                          onSelected: (_) => setState(() => _gender = g),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),

          // 2. COACHING GOAL & METABOLIC PROFILE
          _buildSectionCard(
            title: 'Goal, Activity & Clinical Profile',
            icon: Icons.monitor_heart_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Primary Goal',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ['Fat Loss', 'Muscle Gain', 'Body Recomp'].map((g) {
                    final active = _goal == g;
                    return ChoiceChip(
                      label: Text(
                        g,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.black : const Color(0xFF334155),
                        ),
                      ),
                      selected: active,
                      selectedColor: const Color(0xFFF59E0B),
                      backgroundColor: const Color(0xFFF8FAFC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: active
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                      onSelected: (_) => setState(() => _goal = g),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MedicalCondition>(
                  value: _condition,
                  decoration: _inputStyle('Medical / Endocrine Profile'),
                  items: MedicalCondition.values.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(
                        c.name.toUpperCase(),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _condition = val);
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<double>(
                  value: _activityMultiplier,
                  decoration: _inputStyle('Activity Multiplier'),
                  items: const [
                    DropdownMenuItem(
                      value: 1.2,
                      child: Text('1.2 - Sedentary', style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: 1.375,
                      child: Text('1.375 - Light Activity', style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: 1.55,
                      child: Text('1.55 - Moderate', style: TextStyle(fontSize: 12)),
                    ),
                    DropdownMenuItem(
                      value: 1.725,
                      child: Text('1.725 - Very Active', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _activityMultiplier = val);
                  },
                ),
              ],
            ),
          ),

          // 3. HYDRATION & COACH GUIDELINES
          _buildSectionCard(
            title: 'Hydration & Coach Guidelines',
            icon: Icons.water_drop_outlined,
            child: Column(
              children: [
                TextField(
                  controller: _waterController,
                  decoration:
                      _inputStyle('Daily Water Target', prefixIcon: Icons.local_drink_outlined),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _notesController,
                  maxLines: 2,
                  decoration:
                      _inputStyle('Coach Notes', prefixIcon: Icons.edit_note_outlined),
                ),
              ],
            ),
          ),

          // 4. PREMIUM ENERGY SUMMARY BANNER
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.45)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESTIMATED TDEE',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${preview.adjustedTdee.toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 36,
                  width: 1,
                  color: Colors.white24,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'RECOMMENDED TARGET',
                      style: TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${preview.calculatedTargetCalories.toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                        color: Color(0xFFF59E0B),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // PRIMARY CTA BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black,
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.arrow_forward_rounded, color: Colors.black),
              label: const Text(
                'Continue to Diet & Workout Builder',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
              onPressed: _openPlanner,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}