import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'models.dart';

class PdfService {
  static final PdfColor _navyDark = PdfColor.fromHex('#0F172A');
  static final PdfColor _navyCard = PdfColor.fromHex('#1E293B');
  static final PdfColor _amberAccent = PdfColor.fromHex('#F59E0B');
  static final PdfColor _amberDark = PdfColor.fromHex('#B45309');
  static final PdfColor _amberSoft = PdfColor.fromHex('#FFFBEB');
  static final PdfColor _surfaceSoft = PdfColor.fromHex('#F8FAFC');
  static final PdfColor _borderLight = PdfColor.fromHex('#E2E8F0');
  static final PdfColor _textMuted = PdfColor.fromHex('#475569');

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

    final double targetNum = double.tryParse(targetCalories) ?? 0;
    final double actualNum = plan.totalCalories;
    final double diffNum = targetNum - actualNum;
    final String diffText = diffNum >= 0
        ? "${diffNum.toStringAsFixed(0)} kcal Remaining"
        : "${diffNum.abs().toStringAsFixed(0)} kcal Surplus";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(22),
        build: (pw.Context context) {
          return [
            // PREMIUM BRAND HEADER WITH LOGO
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: _navyDark,
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(color: _amberAccent, width: 1.0),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (logoImage != null)
                    pw.Container(
                      width: 54,
                      height: 54,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        border: pw.Border.all(color: _amberAccent, width: 1.8),
                        image: pw.DecorationImage(
                          image: logoImage,
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    ),
                  if (logoImage != null) pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "fitwithRahul Coaching",
                          style: pw.TextStyle(
                            color: _amberAccent,
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          "Certified Nutrition & Hypertrophy Coach",
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 9.5,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          "Contact: 9039783093  |  IG: @fitwithRahul",
                          style: const pw.TextStyle(
                            color: PdfColors.grey300,
                            fontSize: 8.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: pw.BoxDecoration(
                      color: _amberAccent,
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Text(
                      "DIET PROTOCOL",
                      style: pw.TextStyle(
                        color: _navyDark,
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // CLIENT SUMMARY & DAILY MACRO STRIP
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: _surfaceSoft,
                border: pw.Border.all(color: _borderLight, width: 1.0),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "CLIENT: ${clientName.toUpperCase()}",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11.5,
                              color: _navyDark,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            "Goal: $fitnessGoal  •  5-Meal Structured Plan",
                            style: pw.TextStyle(
                              fontSize: 9.5,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            "Target: $targetCalories kcal",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                              color: _amberDark,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            "Actual: ${actualNum.toStringAsFixed(0)} kcal ($diffText)",
                            style: pw.TextStyle(
                              fontSize: 9.5,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: pw.BoxDecoration(
                      color: _navyDark,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        pw.Text(
                          "Total Calories: ${actualNum.toStringAsFixed(0)} kcal",
                          style: pw.TextStyle(
                            color: _amberAccent,
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          "Protein: ${plan.totalProtein.toStringAsFixed(1)}g",
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 9,
                          ),
                        ),
                        pw.Text(
                          "Carbs: ${plan.totalCarbs.toStringAsFixed(1)}g",
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 9,
                          ),
                        ),
                        pw.Text(
                          "Fats: ${plan.totalFats.toStringAsFixed(1)}g",
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            // MEAL SECTIONS
            _buildMealPdfSection("MEAL 1 (Breakfast)", plan.meal1),
            _buildMealPdfSection("MEAL 2 (Mid-Morning)", plan.meal2),
            _buildMealPdfSection("MEAL 3 (Lunch)", plan.meal3),
            _buildMealPdfSection("MEAL 4 (Evening Snack)", plan.meal4),
            _buildMealPdfSection("MEAL 5 (Dinner)", plan.meal5),

            pw.SizedBox(height: 8),

            // COACH GUIDELINES & HYDRATION CARD
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: _amberSoft,
                border: pw.Border.all(color: _amberAccent, width: 0.8),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "COACH GUIDELINES & HYDRATION PROTOCOL",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9.5,
                      color: _navyDark,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    coachNotes.isNotEmpty
                        ? coachNotes
                        : "Progressive overload prioritize karein aur consistency maintain rakhein.",
                    style: pw.TextStyle(fontSize: 9, color: _navyCard),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    "Daily Water Intake: $dailyWater",
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#0284C7'),
                    ),
                  ),
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
        margin: const pw.EdgeInsets.all(22),
        build: (pw.Context context) {
          return [
            // PREMIUM WORKOUT HEADER WITH LOGO
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: _navyDark,
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(color: _amberAccent, width: 1.0),
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
                        border: pw.Border.all(color: _amberAccent, width: 1.8),
                        image: pw.DecorationImage(
                          image: logoImage,
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    ),
                  if (logoImage != null) pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "fitwithRahul - Training Split",
                          style: pw.TextStyle(
                            color: _amberAccent,
                            fontSize: 15.5,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          "Client: ${clientName.toUpperCase()}  |  Goal: $fitnessGoal",
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 9.5,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          "Contact: 9039783093  |  IG: @fitwithRahul",
                          style: const pw.TextStyle(
                            color: PdfColors.grey300,
                            fontSize: 8.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: pw.BoxDecoration(
                      color: _amberAccent,
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Text(
                      "WEEKLY SPLIT",
                      style: pw.TextStyle(
                        color: _navyDark,
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            // DAYS WORKOUT TABLES
            ...['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) {
              final exercises = weeklyWorkout[day] ?? [];
              if (exercises.isEmpty) return pw.SizedBox.shrink();

              final tableData = exercises
                  .map<List<String>>((e) => [
                        e.name,
                        e.category,
                        "${e.sets} Sets",
                        e.reps,
                        e.restSeconds,
                      ])
                  .toList();

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _borderLight, width: 0.9),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: pw.BoxDecoration(
                        color: _navyCard,
                        borderRadius: const pw.BorderRadius.vertical(
                          top: pw.Radius.circular(7),
                        ),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            _getDayFullTitle(day),
                            style: pw.TextStyle(
                              color: _amberAccent,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9.5,
                            ),
                          ),
                          pw.Text(
                            "${exercises.length} Exercises",
                            style: const pw.TextStyle(
                              color: PdfColors.grey300,
                              fontSize: 8.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.TableHelper.fromTextArray(
                      headers: [
                        'Exercise Name',
                        'Category',
                        'Sets',
                        'Reps Target',
                        'Rest',
                      ],
                      data: tableData,
                      headerStyle: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8.5,
                        color: PdfColors.white,
                      ),
                      headerDecoration: pw.BoxDecoration(color: _navyDark),
                      cellStyle: pw.TextStyle(fontSize: 8.5, color: _navyDark),
                      rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
                      oddRowDecoration: pw.BoxDecoration(color: _surfaceSoft),
                      cellAlignment: pw.Alignment.centerLeft,
                      cellPadding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ];
        },
      ),
    );

    await _saveAndShare(
        pdf, "${clientName.replaceAll(' ', '_')}_WorkoutPlan.pdf");
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
      margin: const pw.EdgeInsets.only(bottom: 11),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                  color: _navyDark,
                ),
              ),
              pw.Text(
                "${totalMealCal.toStringAsFixed(0)} kcal  |  Protein: ${totalMealPro.toStringAsFixed(1)}g",
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: _amberDark,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: _borderLight, width: 0.8),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              children: [
                // Table Header
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: pw.BoxDecoration(
                    color: _navyCard,
                    borderRadius: const pw.BorderRadius.vertical(
                      top: pw.Radius.circular(5),
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      pw.SizedBox(width: 24),
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(
                          'Food Item',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          'Qty',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          'Calories',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          'Protein',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          'Carbs',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          'Fats',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Rows with Food Icon
                ...entries.asMap().entries.map((mapEntry) {
                  final int rowIdx = mapEntry.key;
                  final MealEntry e = mapEntry.value;
                  String qtyStr = (e.food.unit == 'pcs' ||
                          e.food.unit == 'tbsp' ||
                          e.food.unit == 'scoop' ||
                          e.food.unit == 'tsp')
                      ? "${e.quantity.toStringAsFixed(0)} ${e.food.unit}"
                      : "${e.quantity.toStringAsFixed(0)}g";

                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: pw.BoxDecoration(
                      color: rowIdx.isOdd ? _surfaceSoft : PdfColors.white,
                      border: const pw.Border(
                        bottom: pw.BorderSide(
                          color: PdfColors.grey200,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        _buildFoodIconBadge(e.food.name),
                        pw.SizedBox(width: 6),
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                            e.food.name,
                            style: pw.TextStyle(fontSize: 8, color: _navyDark),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            qtyStr,
                            style: pw.TextStyle(fontSize: 8, color: _navyDark),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            "${e.calories.toStringAsFixed(0)} kcal",
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: _amberDark,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            "${e.protein.toStringAsFixed(1)}g",
                            style: pw.TextStyle(fontSize: 8, color: _navyDark),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            "${e.carbs.toStringAsFixed(1)}g",
                            style: pw.TextStyle(fontSize: 8, color: _navyDark),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            "${e.fats.toStringAsFixed(1)}g",
                            style: pw.TextStyle(fontSize: 8, color: _navyDark),
                          ),
                        ),
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