import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:jaibee1/l10n/s.dart';
import 'monthly_summary.dart';

Future<void> generatePdfArabic(BuildContext context, MonthlySummary summary, String advice, DateTime selectedMonth) async {
  final s = S.of(context);
  if (s == null) return;

  final pdf = pw.Document();

  // Load logo
  final ByteData logoBytes = await rootBundle.load('assets/images/logo.png');
  final Uint8List logoUint8List = logoBytes.buffer.asUint8List();
  final pw.MemoryImage logo = pw.MemoryImage(logoUint8List);

  // Load Arabic font
  final arabicFontData = await rootBundle.load(
    'assets/fonts/NotoSansArabic-Regular.ttf',
  );
  final arabicFont = pw.Font.ttf(arabicFontData);

  final String monthName = DateFormat.yMMMM('ar').format(selectedMonth);
  final String title = '${s.aiFinancialAdvice} - $monthName';

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      theme: pw.ThemeData.withFont(base: arabicFont),
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        title,
                        style: pw.TextStyle(
                          font: arabicFont,
                          fontSize: 22,
                          color: PdfColors.redAccent,
                        ),
                      ),
                    ),
                    pw.Image(logo, height: 100),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Divider(),
                pw.SizedBox(height: 16),

                // Income
                pw.Text(
                  s.income,
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 14,
                    color: PdfColors.green600,
                  ),
                ),
                pw.Text(
                  "\$${summary.totalIncome.toStringAsFixed(2)}",
                  style: pw.TextStyle(font: arabicFont, fontSize: 14),
                ),
                pw.SizedBox(height: 8),

                // Expenses
                pw.Text(
                  s.expenses,
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 14,
                    color: PdfColors.red,
                  ),
                ),
                pw.Text(
                  "\$${summary.totalExpenses.toStringAsFixed(2)}",
                  style: pw.TextStyle(font: arabicFont, fontSize: 14),
                ),
                pw.SizedBox(height: 8),

                // Limit
                pw.Text(
                  s.limit,
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 14,
                    color: PdfColors.orange,
                  ),
                ),
                pw.Text(
                  (summary.monthlyLimit ?? 0) > 0
                      ? "\$${summary.monthlyLimit!.toStringAsFixed(2)}"
                      : s.notSet,
                  style: pw.TextStyle(font: arabicFont, fontSize: 14),
                ),
                pw.SizedBox(height: 24),

                // Advice
                pw.Text(
                  s.personalizedAdvice,
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 16,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(
                      color: PdfColors.blueGrey,
                      width: 1,
                    ),
                  ),
                  child: pw.Text(
                    advice,
                    style: pw.TextStyle(
                      font: arabicFont,
                      fontSize: 12,
                      lineSpacing: 4,
                    ),
                  ),
                ),
                pw.SizedBox(height: 24),

                // Disclaimer (optional to translate)
                pw.Text(
                  "تنويه",
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 14,
                    color: PdfColors.deepOrange,
                  ),
                ),
                pw.Text(
                  "هذه النصيحة المالية تم إنشاؤها بواسطة الذكاء الاصطناعي وتُعد لأغراض معلوماتية فقط. "
                  "المطور غير مسؤول عن أي قرارات مالية يتم اتخاذها بناءً على هذا المحتوى.",
                  style: pw.TextStyle(font: arabicFont, fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}

Future<void> generatePdfEnglish(BuildContext context, MonthlySummary summary, String advice, DateTime selectedMonth) async {
  final s = S.of(context);
  if (s == null) return;

  final pdf = pw.Document();

  // Load logo
  final ByteData logoBytes = await rootBundle.load('assets/images/logo.png');
  final Uint8List logoUint8List = logoBytes.buffer.asUint8List();
  final pw.MemoryImage logo = pw.MemoryImage(logoUint8List);

  // Load English fonts
  final font = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
  final boldFont = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

  final String monthName = DateFormat.yMMMM().format(selectedMonth);
  final String title = '${s.aiFinancialAdvice} - $monthName';

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 22,
                      color: PdfColors.redAccent,
                    ),
                  ),
                  pw.Image(logo, height: 100),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 16),

              // Income
              pw.Text(
                s.income,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 14,
                  color: PdfColors.green600,
                ),
              ),
              pw.Text(
                "\$${summary.totalIncome.toStringAsFixed(2)}",
                style: pw.TextStyle(font: font, fontSize: 14),
              ),
              pw.SizedBox(height: 8),

              // Expenses
              pw.Text(
                s.expenses,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 14,
                  color: PdfColors.red,
                ),
              ),
              pw.Text(
                "\$${summary.totalExpenses.toStringAsFixed(2)}",
                style: pw.TextStyle(font: font, fontSize: 14),
              ),
              pw.SizedBox(height: 8),

              // Limit
              pw.Text(
                s.limit,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 14,
                  color: PdfColors.orange,
                ),
              ),
              pw.Text(
                (summary.monthlyLimit ?? 0) > 0
                    ? "\$${summary.monthlyLimit!.toStringAsFixed(2)}"
                    : s.notSet,
                style: pw.TextStyle(font: font, fontSize: 14),
              ),
              pw.SizedBox(height: 24),

              // Personalized Advice
              pw.Text(
                s.personalizedAdvice,
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 16,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.blueGrey, width: 1),
                ),
                child: pw.Text(
                  advice,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    lineSpacing: 4,
                  ),
                ),
              ),
              pw.SizedBox(height: 24),

              // Disclaimer
              pw.Text(
                "Disclaimer",
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 14,
                  color: PdfColors.deepOrange,
                ),
              ),
              pw.Text(
                "This financial advice is generated by AI and should be considered informational only. "
                "The developer is not responsible for financial decisions made based on this content.",
                style: pw.TextStyle(font: font, fontSize: 10),
              ),
            ],
          ),
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}