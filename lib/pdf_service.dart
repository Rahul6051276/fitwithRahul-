import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'models.dart';

class PdfService {
  static const PdfColor primaryDark = PdfColor.fromInt(0xFF0F172A);
  static const PdfColor cardDark = PdfColor.fromInt(0xFF1E293B);
  static const PdfColor accentGold = PdfColor.fromInt(0xFFF59E0B);
  static const PdfColor lightRow = PdfColor.fromInt(0xFFF8FAFC);

  static Future<void> sharePdf({
    required String clientName,
    required double targetCalories,
    required String waterTarget,
    required String coachNotes,
    required FiveMealPlan plan,
    required List<WorkoutExercise> workouts,
  }) async {
    final pdf = pw.Document();

    // 1. Coach Photo Asset Load
    final imageBytes = await rootBundle.load('assets/images/coach_rahul.png');
    final coachImage = pw.MemoryImage(imageBytes.buffer.asUint8List());

    pw.Widget buildMealTable(String title, List<MealEntry> items) {
      if (items.isEmpty) return pw.SizedBox.shrink();

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE2E8F0)),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5, color: primaryDark)),
                pw.Text("${items.fold(0.0, (s, i) => s + i.totalCalories).toStringAsFixed(0)} kcal",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5, color: primaryDark)),
              ],
            ),
          ),
          pw.TableHelper.fromTextArray(
            headers: ['Food Item', 'Portion', 'Calories', 'Protein', 'Carbs', 'Fats'],
            data: items.map((i) => [
              i.food.name,
              i.displayPortion,
              "${i.totalCalories.toStringAsFixed(0)} kcal",
              "${i.totalProtein.toStringAsFixed(1)}g",
              "${i.totalCarbs.toStringAsFixed(1)}g",
              "${i.totalFats.toStringAsFixed(1)}g",
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 7.5),
            headerDecoration: const pw.BoxDecoration(color: primaryDark),
            cellStyle: const pw.TextStyle(fontSize: 7.5),
            cellPadding: const pw.EdgeInsets.symmetric(vertical: 2.5, horizontal: 5),
            oddRowDecoration: const pw.BoxDecoration(color: lightRow),
          ),
          pw.SizedBox(height: 5),
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(18),
        build: (pw.Context context) {
          return [
            // Header Banner with Coach Authentic Circular Photo
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: cardDark,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 52,
                    height: 52,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(color: accentGold, width: 2),
                    ),
                    child: pw.ClipOval(
                      child: pw.Image(coachImage, fit: pw.BoxFit.cover),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("fitwithRahul", style: pw.TextStyle(color: accentGold, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                        pw.Text("Coach Rahul | Certified Fitness & Nutrition", style: const pw.TextStyle(color: PdfColors.white, fontSize: 8.5)),
                        pw.SizedBox(height: 2),
                        pw.Text("Personalized Protocol: Hypertrophy & Nutrition", style: const pw.TextStyle(color: PdfColors.grey400, fontSize: 7.5)),
                      ],
                    ),
                  ),
                  pw.UrlLink(
                    destination: "https://www.instagram.com/fitwithRahul",
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(color: accentGold, borderRadius: pw.BorderRadius.circular(12)),
                      child: pw.Text("@fitwithRahul", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: primaryDark)),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 8),

            // Client Info Card
            pw.Container(
              padding: const pw.EdgeInsets.all(7),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(4)),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("CLIENT: ${clientName.toUpperCase()}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                  pw.Text(
                    "Target: ${plan.grandCalories.toStringAsFixed(0)} / ${targetCalories.toStringAsFixed(0)} kcal | P: ${plan.grandProtein.toStringAsFixed(0)}g | C: ${plan.grandCarbs.toStringAsFixed(0)}g | F: ${plan.grandFats.toStringAsFixed(0)}g",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5, color: cardDark),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 8),

            // Meals Tables
            buildMealTable("MEAL 1: BREAKFAST", plan.meal1),
            buildMealTable("MEAL 2: MID-MORNING", plan.meal2),
            buildMealTable("MEAL 3: LUNCH", plan.meal3),
            buildMealTable("MEAL 4: EVENING SNACK", plan.meal4),
            buildMealTable("MEAL 5: DINNER", plan.meal5),

            pw.SizedBox(height: 5),

            // Workout Table
            pw.Text("CUSTOM WORKOUT PROTOCOL", style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: primaryDark)),
            pw.SizedBox(height: 3),
            pw.TableHelper.fromTextArray(
              headers: ['Exercise', 'Category', 'Sets', 'Reps Target', 'Rest Time'],
              data: workouts.map((w) => [w.name, w.category, "${w.sets} Sets", w.reps, w.restSeconds]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 7.5),
              headerDecoration: const pw.BoxDecoration(color: cardDark),
              cellStyle: const pw.TextStyle(fontSize: 7.5),
              cellPadding: const pw.EdgeInsets.symmetric(vertical: 2.5, horizontal: 5),
            ),
            pw.SizedBox(height: 7),

            // Water & Notes Section
            pw.Container(
              padding: const pw.EdgeInsets.all(7),
              decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFF1F5F9), borderRadius: pw.BorderRadius.circular(4)),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("COACH GUIDELINES & HYDRATION", style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: primaryDark)),
                  pw.SizedBox(height: 2),
                  pw.Text("Daily Water Intake: $waterTarget", style: const pw.TextStyle(fontSize: 7.5)),
                  if (coachNotes.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text("Protocol Notes: $coachNotes", style: const pw.TextStyle(fontSize: 7.5)),
                  ],
                ],
              ),
            ),

            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.UrlLink(
                destination: "https://www.instagram.com/fitwithRahul",
                child: pw.Text("Created by fitwithRahul | Follow on Instagram: @fitwithRahul", style: pw.TextStyle(fontSize: 7.5, color: accentGold, fontWeight: pw.FontWeight.bold)),
              ),
            ),
          ];
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/${clientName}_fitwithRahul_Plan.pdf");
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Namaste $clientName! Here is your custom diet & workout plan by Coach Rahul (@fitwithRahul).',
    );
  }
}
