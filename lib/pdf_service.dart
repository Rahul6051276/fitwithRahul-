// WORKOUT PROTOCOL SECTION IN PDF
pw.Text("CUSTOM WORKOUT PROTOCOL", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryDark)),
pw.SizedBox(height: 4),
pw.TableHelper.fromTextArray(
  headers: ['Exercise', 'Category', 'Sets', 'Reps Target', 'Rest Time'],
  data: workouts.map((w) => [
    w.name,
    w.category,
    "${w.sets} Sets",
    w.reps,
    w.restSeconds,
  ]).toList(),
  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 8),
  headerDecoration: const pw.BoxDecoration(color: primaryDark),
  cellStyle: const pw.TextStyle(fontSize: 8),
  cellPadding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 6),
),
