import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'models.dart';

class PdfService {
  // --- 1. GENERATE & SHARE DIET PDF ---
  static Future<void> generateAndShareDietPdf({
    required String clientName,
    required String fitnessGoal,
    required String targetCalories,
    required String dailyWater,
    required String coachNotes,
    required FiveMealPlan plan,
  }) async {
    final pdf = pw.Document();

    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/images/coach_rahul.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {}

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            // HEADER WITH LOGO
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#0F172A'),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (logoImage != null)
                    pw.Container(
                      width: 50,
                      height: 50,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        image: pw.DecorationImage(image: logoImage, fit: pw.BoxFit.cover),
                      ),
                    ),
                  if (logoImage != null) pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("fitwithRahul Coaching",
                            style: pw.TextStyle(color: PdfColor.fromHex('#F59E0B'), fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        pw.Text("Certified Nutrition & Hypertrophy Coach",
                            style: const pw.TextStyle(color: PdfColors.white, fontSize: 9)),
                        pw.Text("Contact: 9039783093 | IG: @fitwithRahul",
                            style: const pw.TextStyle(color: PdfColors.grey400, fontSize: 8)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // CLIENT INFO & METRICS CARD
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Client Name: $clientName", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.Text("Goal Protocol: $fitnessGoal", style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey800)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Target Calories: $targetCalories kcal",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColor.fromHex('#B45309'))),
                      pw.Text("Diet Plan: ${plan.totalCalories.toStringAsFixed(0)} kcal (P: ${plan.totalProtein.toStringAsFixed(0)}g)",
                          style: const pw.TextStyle(fontSize: 10, color: PdfColor.green800)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            // MEALS SECTIONS WITH FOOD ICONS
            _buildMealPdfSection("MEAL 1 (Breakfast)", plan.meal1),
            _buildMealPdfSection("MEAL 2 (Mid-Morning)", plan.meal2),
            _buildMealPdfSection("MEAL 3 (Lunch)", plan.meal3),
            _buildMealPdfSection("MEAL 4 (Evening Snack)", plan.meal4),
            _buildMealPdfSection("MEAL 5 (Dinner)", plan.meal5),

            pw.SizedBox(height: 10),

            // COACH NOTES & HYDRATION
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F8FAFC'),
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Coach Guidelines & Hydration:",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColor.fromHex('#0F172A'))),
                  pw.SizedBox(height: 4),
                  pw.Text(coachNotes.isNotEmpty ? coachNotes : "Progressive overload prioritize karein aur consistency maintain rakhein.",
                      style: const pw.TextStyle(fontSize: 9)),
                  pw.SizedBox(height: 3),
                  pw.Text("Daily Water Intake: $dailyWater",
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#0284C7'))),
                ],
              ),
            ),
          ];
        },
      ),
    );

    await _saveAndShare(pdf, "${clientName.replaceAll(' ', '_')}_DietPlan.pdf");
  }

  // --- 2. GENERATE & SHARE WORKOUT PDF ---
  static Future<void> generateAndShareWorkoutPdf({
    required String clientName,
    required String fitnessGoal,
    required Map<String, List<WorkoutExercise>> weeklyWorkout,
  }) async {
    final pdf = pw.Document();

    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/images/coach_rahul.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {}

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            // HEADER WITH LOGO
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#0F172A'),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (logoImage != null)
                    pw.Container(
                      width: 45,
                      height: 45,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        image: pw.DecorationImage(image: logoImage, fit: pw.BoxFit.cover),
                      ),
                    ),
                  if (logoImage != null) pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("fitwithRahul - Training Split",
                            style: pw.TextStyle(color: PdfColor.fromHex('#F59E0B'), fontSize: 15, fontWeight: pw.FontWeight.bold)),
                        pw.Text("Client: $clientName | Goal: $fitnessGoal",
                            style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                      ],
                    ),
                  ),
                  pw.Text("Weekly Schedule", style: const pw.TextStyle(color: PdfColors.grey400, fontSize: 9)),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            // DAYS WORKOUT TABLES
            ...['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) {
              final exercises = weeklyWorkout[day] ?? [];
              if (exercises.isEmpty) return pw.SizedBox.shrink();

              final tableData = exercises.map<List<String>>((e) => [
                    e.name,
                    e.category,
                    "${e.sets} Sets",
                    e.reps,
                    e.restSeconds,
                  ]).toList();

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#1E293B'),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        _getDayFullTitle(day),
                        style: pw.TextStyle(color: PdfColor.fromHex('#F59E0B'), fontWeight: pw.FontWeight.bold, fontSize: 10),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.TableHelper.fromTextArray(
                      headers: ['Exercise Name', 'Category', 'Sets', 'Reps Target', 'Rest'],
                      data: tableData,
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
                      headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#334155')),
                      cellStyle: const pw.TextStyle(fontSize: 8.5),
                      cellAlignment: pw.Alignment.centerLeft,
                      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    ),
                  ],
                ),
              );
            }).toList(),
          ];
        },
      ),
    );

    await _saveAndShare(pdf, "${clientName.replaceAll(' ', '_')}_WorkoutPlan.pdf");
  }

  // --- VISUAL ICON BADGE FOR PDF FOOD ITEMS ---
  static pw.Widget _buildFoodIconBadge(String foodName) {
    final lower = foodName.toLowerCase();

    PdfColor bgColor = PdfColor.fromHex('#FEF3C7');
    PdfColor dotColor = PdfColor.fromHex('#D97706');
    String tag = 'FD';

    if (lower.contains('roti') || lower.contains('chapati')) {
      bgColor = PdfColor.fromHex('#FDE68A');
      dotColor = PdfColor.fromHex('#B45309');
      tag = 'RT';
    } else if (lower.contains('apple') ||
        lower.contains('banana') ||
        lower.contains('orange') ||
        lower.contains('pear') ||
        lower.contains('papaya') ||
        lower.contains('guava')) {
      bgColor = PdfColor.fromHex('#DCFCE7');
      dotColor = PdfColor.fromHex('#15803D');
      tag = 'FR';
    } else if (lower.contains('curd') ||
        lower.contains('dahi') ||
        lower.contains('milk') ||
        lower.contains('butter') ||
        lower.contains('cheese')) {
      bgColor = PdfColor.fromHex('#E0F2FE');
      dotColor = PdfColor.fromHex('#0369A1');
      tag = 'DY';
    } else if (lower.contains('egg')) {
      bgColor = PdfColor.fromHex('#FEF9C3');
      dotColor = PdfColor.fromHex('#CA8A04');
      tag = 'EG';
    } else if (lower.contains('whey') ||
        lower.contains('soya') ||
        lower.contains('paneer') ||
        lower.contains('chicken') ||
        lower.contains('daal') ||
        lower.contains('chana') ||
        lower.contains('beans')) {
      bgColor = PdfColor.fromHex('#DBEAFE');
      dotColor = PdfColor.fromHex('#1D4ED8');
      tag = 'PR';
    } else if (lower.contains('oil') ||
        lower.contains('peanut') ||
        lower.contains('almond') ||
        lower.contains('seed') ||
        lower.contains('dates') ||
        lower.contains('raisins')) {
      bgColor = PdfColor.fromHex('#FFEDD5');
      dotColor = PdfColor.fromHex('#C2410C');
      tag = 'FT';
    } else if (lower.contains('oats') ||
        lower.contains('rice') ||
        lower.contains('daliya') ||
        lower.contains('poha') ||
        lower.contains('flakes') ||
        lower.contains('muesli') ||
        lower.contains('flour') ||
        lower.contains('besan')) {
      bgColor = PdfColor.fromHex('#F3E8FF');
      dotColor = PdfColor.fromHex('#7E22CE');
      tag = 'GR';
    }

    return pw.Container(
      width: 18,
      height: 18,
      decoration: pw.BoxDecoration(
        color: bgColor,
        shape: pw.BoxShape.circle,
        border: pw.Border.all(color: dotColor, width: 0.8),
      ),
      alignment: pw.Alignment.center,
      child: pw.Text(
        tag,
        style: pw.TextStyle(
          fontSize: 6.5,
          fontWeight: pw.FontWeight.bold,
          color: dotColor,
        ),
      ),
    );
  }

  // --- HELPER METHODS ---
  static pw.Widget _buildMealPdfSection(String title, List<MealEntry> entries) {
    if (entries.isEmpty) return pw.SizedBox.shrink();

    double totalMealCal = entries.fold(0.0, (prev, e) => prev + e.calories);
    double totalMealPro = entries.fold(0.0, (prev, e) => prev + e.protein);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColor.fromHex('#0F172A'))),
              pw.Text("${totalMealCal.toStringAsFixed(0)} kcal | Protein: ${totalMealPro.toStringAsFixed(1)}g",
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#B45309'))),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              children: [
                // Table Header
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: pw.BoxDecoration(color: PdfColor.fromHex('#1E293B')),
                  child: pw.Row(
                    children: [
                      pw.SizedBox(width: 24),
                      pw.Expanded(flex: 3, child: pw.Text('Food Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.white))),
                      pw.Expanded(flex: 1, child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.white))),
                      pw.Expanded(flex: 1, child: pw.Text('Calories', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.white))),
                      pw.Expanded(flex: 1, child: pw.Text('Protein', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.white))),
                      pw.Expanded(flex: 1, child: pw.Text('Carbs', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.white))),
                      pw.Expanded(flex: 1, child: pw.Text('Fats', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.white))),
                    ],
                  ),
                ),
                // Rows with Food Icon
                ...entries.map((e) {
                  String qtyStr = (e.food.unit == 'pcs' || e.food.unit == 'tbsp' || e.food.unit == 'scoop' || e.food.unit == 'tsp')
                      ? "${e.quantity.toStringAsFixed(0)} ${e.food.unit}"
                      : "${e.quantity.toStringAsFixed(0)}g";

                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        _buildFoodIconBadge(e.food.name),
                        pw.SizedBox(width: 6),
                        pw.Expanded(flex: 3, child: pw.Text(e.food.name, style: const pw.TextStyle(fontSize: 8))),
                        pw.Expanded(flex: 1, child: pw.Text(qtyStr, style: const pw.TextStyle(fontSize: 8))),
                        pw.Expanded(flex: 1, child: pw.Text("${e.calories.toStringAsFixed(0)} kcal", style: const pw.TextStyle(fontSize: 8))),
                        pw.Expanded(flex: 1, child: pw.Text("${e.protein.toStringAsFixed(1)}g", style: const pw.TextStyle(fontSize: 8))),
                        pw.Expanded(flex: 1, child: pw.Text("${e.carbs.toStringAsFixed(1)}g", style: const pw.TextStyle(fontSize: 8))),
                        pw.Expanded(flex: 1, child: pw.Text("${e.fats.toStringAsFixed(1)}g", style: const pw.TextStyle(fontSize: 8))),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _getDayFullTitle(String day) {
    switch (day) {
      case 'Mon':
        return 'MONDAY SESSION';
      case 'Tue':
        return 'TUESDAY SESSION';
      case 'Wed':
        return 'WEDNESDAY SESSION';
      case 'Thu':
        return 'THURSDAY SESSION';
      case 'Fri':
        return 'FRIDAY SESSION';
      case 'Sat':
        return 'SATURDAY SESSION';
      default:
        return '$day SESSION';
    }
  }

  static Future<void> _saveAndShare(pw.Document pdf, String filename) async {
    final bytes = await pdf.save();
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/$filename");
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: 'fitwithRahul Coaching Plan');
  }
}