  // --- ADD EXERCISE MODAL (DATABASE SELECTION + PERMANENT CUSTOM ADDON) ---
  void _openAddExerciseDialog() {
    String selectedCategory = _allExercises.keys.isNotEmpty ? _allExercises.keys.first : 'Chest';
    String selectedExName = (_allExercises[selectedCategory]?.isNotEmpty ?? false)
        ? _allExercises[selectedCategory]!.first
        : '';

    final customExNameCtrl = TextEditingController();
    final setsCtrl = TextEditingController(text: "3");
    final repsCtrl = TextEditingController(text: "12");
    final restCtrl = TextEditingController(text: "60s");
    
    bool isCreatingNew = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          List<String> currentExList = _allExercises[selectedCategory] ?? [];

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Text(
              "Add Exercise to $_selectedDay",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MODE TOGGLE SWITCH
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setDlgState(() => isCreatingNew = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: !isCreatingNew ? const Color(0xFF0F172A) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Database List",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: !isCreatingNew ? const Color(0xFFF59E0B) : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setDlgState(() => isCreatingNew = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isCreatingNew ? const Color(0xFF0F172A) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "+ New Exercise",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isCreatingNew ? const Color(0xFFF59E0B) : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // CATEGORY DROPDOWN
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: "Target Muscle / Category",
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: _allExercises.keys.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                    onChanged: (cat) {
                      if (cat != null) {
                        setDlgState(() {
                          selectedCategory = cat;
                          selectedExName = (_allExercises[cat]?.isNotEmpty ?? false)
                              ? _allExercises[cat]!.first
                              : '';
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // INPUT FIELD: PICK VS CREATE NEW
                  if (!isCreatingNew) ...[
                    DropdownButtonFormField<String>(
                      value: currentExList.contains(selectedExName)
                          ? selectedExName
                          : (currentExList.isNotEmpty ? currentExList.first : null),
                      decoration: const InputDecoration(
                        labelText: "Select Exercise",
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      items: currentExList.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(e, style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (ex) {
                        if (ex != null) setDlgState(() => selectedExName = ex);
                      },
                    ),
                  ] else ...[
                    TextField(
                      controller: customExNameCtrl,
                      decoration: const InputDecoration(
                        labelText: "New Exercise Name",
                        hintText: "e.g. Incline Smith Press, Hammer Curls",
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // SETS, REPS, REST
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: setsCtrl,
                          decoration: const InputDecoration(labelText: "Sets", isDense: true, border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: repsCtrl,
                          decoration: const InputDecoration(labelText: "Reps", isDense: true, border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextField(
                          controller: restCtrl,
                          decoration: const InputDecoration(labelText: "Rest", isDense: true, border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () {
                  String finalName = isCreatingNew
                      ? customExNameCtrl.text.trim()
                      : selectedExName;

                  if (finalName.isEmpty) return;

                  setState(() {
                    // Agar naya exercise hai toh use permanent database category mein bhi daalein
                    if (isCreatingNew) {
                      if (!_allExercises.containsKey(selectedCategory)) {
                        _allExercises[selectedCategory] = [];
                      }
                      if (!_allExercises[selectedCategory]!.contains(finalName)) {
                        _allExercises[selectedCategory]!.insert(0, finalName);
                      }
                    }

                    // Routine mein add karein
                    _weeklyWorkout[_selectedDay]?.add(
                      WorkoutExercise(
                        name: finalName,
                        category: selectedCategory,
                        sets: setsCtrl.text.trim(),
                        reps: repsCtrl.text.trim(),
                        restSeconds: restCtrl.text.trim(),
                      ),
                    );
                  });

                  Navigator.pop(ctx);
                },
                child: Text(
                  isCreatingNew ? "Save & Add" : "Add to Routine",
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
