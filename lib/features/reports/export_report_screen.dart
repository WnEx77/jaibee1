import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jaibee/data/models/trancs.dart';
import 'package:jaibee/l10n/s.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:jaibee/shared/widgets/app_background.dart';
import 'package:jaibee/shared/widgets/custom_app_bar.dart';
import 'package:jaibee/core/theme/mint_jade_theme.dart';
import 'package:jaibee/shared/widgets/global_date_picker.dart';

class ExportReportScreen extends StatefulWidget {
  const ExportReportScreen({super.key});

  @override
  State<ExportReportScreen> createState() => _ExportReportScreenState();
}

class _ExportReportScreenState extends State<ExportReportScreen> {
  DateTimeRange? _selectedRange;
  bool _includeExpenses = true;
  bool _includeIncome = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    if (_selectedRange == null || (!_includeExpenses && !_includeIncome)) {
      return;
    }

    // Capture all needed context values before any await
    final localizer = S.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;
    final isArabic = localeCode == 'ar';

    final transactionBox = Hive.box('transactions');

    final transactions = transactionBox.values.whereType<Transaction>().where((
      t,
    ) {
      final inRange =
          !t.date.isBefore(_selectedRange!.start) &&
          !t.date.isAfter(_selectedRange!.end);
      if (!inRange) return false;
      if (t.isIncome && _includeIncome) return true;
      if (!t.isIncome && _includeExpenses) return true;
      return false;
    }).toList();

    final double totalIncome = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);

    final double totalExpenses = transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);

    final pdf = pw.Document();

    // Load logo
    final ByteData logoBytes = await rootBundle.load('assets/images/icon_transparency.png');
    final Uint8List logoUint8List = logoBytes.buffer.asUint8List();
    final pw.MemoryImage logo = pw.MemoryImage(logoUint8List);

    // Font setup
    pw.Font? baseFont;
    pw.Font? boldFont;
    if (isArabic) {
      final arabicFontData = await rootBundle.load(
        'assets/fonts/NotoSansArabic-Regular.ttf',
      );
      baseFont = pw.Font.ttf(arabicFontData);
      boldFont = baseFont;
    } else {
      baseFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
      );
      boldFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
        textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        build: (context) => [
          // Logo at top right
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [pw.Image(logo, height: 90)],
          ),
          pw.SizedBox(height: 8),

          // Title and Date Range Row
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  localizer.reportTitle,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey900,
                    font: boldFont,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 12,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Text(
                  '${DateFormat.yMMMd(localeCode).format(_selectedRange!.start)}  -  ${DateFormat.yMMMd(localeCode).format(_selectedRange!.end)}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.blue800,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),

          // Totals Row
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Text(
                  '${localizer.totalIncome}: ',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green800,
                    fontSize: 13,
                  ),
                ),
                pw.Text(
                  totalIncome.toStringAsFixed(2),
                  style: pw.TextStyle(color: PdfColors.green800, fontSize: 13),
                ),
                pw.SizedBox(width: 24),
                pw.Text(
                  '${localizer.totalExpenses}: ',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red800,
                    fontSize: 13,
                  ),
                ),
                pw.Text(
                  totalExpenses.toStringAsFixed(2),
                  style: pw.TextStyle(color: PdfColors.red800, fontSize: 13),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 10),

          // Text next to the selected range
          // pw.Align(
          //   alignment: isArabic
          //       ? pw.Alignment.centerRight
          //       : pw.Alignment.centerLeft,
          //   child: pw.Text(
          //     (_includeIncome && _includeExpenses)
          //         ? localizer.incomeAndExpenseSelected
          //         : _includeIncome
          //         ? localizer.onlyIncomeSelected
          //         : localizer.onlyExpenseSelected,
          //     style: pw.TextStyle(
          //       fontSize: 12,
          //       color: PdfColors.blueGrey700,
          //       fontWeight: pw.FontWeight.normal,
          //     ),
          //   ),
          // ),
          // pw.SizedBox(height: 16),

          // Modern Table in a card-like container
          pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(14),
              boxShadow: [
                pw.BoxShadow(
                  color: PdfColors.blueGrey100,
                  blurRadius: 6,
                  spreadRadius: 1,
                  offset: const PdfPoint(0, 2),
                ),
              ],
              border: pw.Border.all(color: PdfColors.blueGrey300, width: 1),
            ),
            padding: const pw.EdgeInsets.all(14),
            child: pw.TableHelper.fromTextArray(
              headers: [
                localizer.date,
                localizer.category,
                localizer.amount,
                '${localizer.income}/${localizer.expense}',
              ],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey900,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
              headerDecoration: pw.BoxDecoration(
                color: PdfColors.blueGrey50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              cellStyle: pw.TextStyle(
                font: baseFont,
                fontSize: 11,
                color: PdfColors.blueGrey800,
              ),
              oddRowDecoration: pw.BoxDecoration(color: PdfColors.blue50),
              data: transactions
                  .map(
                    (t) => [
                      DateFormat.yMMMd(localeCode).format(t.date),
                      t.category,
                      t.amount.toStringAsFixed(2),
                      t.isIncome ? localizer.income : localizer.expense,
                    ],
                  )
                  .toList(),
              cellAlignment: isArabic
                  ? pw.Alignment.centerRight
                  : pw.Alignment.centerLeft,
            ),
          ),
          pw.SizedBox(height: 28),

          // Disclaimer
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 16,
            ),
            decoration: pw.BoxDecoration(
              color: PdfColors.orange50,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  isArabic ? "تنويه" : "Disclaimer",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                    color: PdfColors.deepOrange,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  isArabic
                      ? "هذا التقرير المالي تم إنشاؤه بواسطة التطبيق لأغراض معلوماتية فقط. المطور غير مسؤول عن أي قرارات مالية يتم اتخاذها بناءً على هذا المحتوى."
                      : "This financial report is generated by the app for informational purposes only. The developer is not responsible for financial decisions made based on this content.",
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.orange800),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  Future<void> _pickSingleDate(
    BuildContext context, {
    required bool isStart,
  }) async {
    DateTime initialDate = isStart
        ? _selectedRange!.start
        : _selectedRange!.end;
    DateTime minDate = isStart ? DateTime(2000) : _selectedRange!.start;
    DateTime maxDate = isStart ? _selectedRange!.end : DateTime.now();

    final pickedDate = await showGlobalCupertinoDatePicker(
      context: context,
      initialDate: initialDate,
      minDate: minDate,
      maxDate: maxDate,
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _selectedRange = DateTimeRange(
            start: pickedDate,
            end: _selectedRange!.end.isBefore(pickedDate)
                ? pickedDate
                : _selectedRange!.end,
          );
        } else {
          _selectedRange = DateTimeRange(
            start: _selectedRange!.start,
            end: pickedDate.isBefore(_selectedRange!.start)
                ? _selectedRange!.start
                : pickedDate,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizer = S.of(context)!;
    final mintJade = Theme.of(context).extension<MintJadeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(title: localizer.exportAsPdf, showBackButton: true),
      body: AppBackground(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(16),
            child: Card(
              color: isDark ? Colors.grey[900] : Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        _RangeDateTile(
                          icon: Icons.calendar_today,
                          color: Colors.blue.shade700,
                          label: localizer.startDate,
                          date: _selectedRange!.start,
                          onTap: () => _pickSingleDate(context, isStart: true),
                        ),
                        _RangeDateTile(
                          icon: Icons.event,
                          color: Colors.green.shade700,
                          label: localizer.endDate,
                          date: _selectedRange!.end,
                          onTap: () => _pickSingleDate(context, isStart: false),
                        ),
                      ],
                    ),
                    CheckboxListTile(
                      value: _includeExpenses,
                      onChanged: (v) =>
                          setState(() => _includeExpenses = v ?? true),
                      title: Text(localizer.expense),
                      activeColor: mintJade.selectedIconColor,
                      checkColor: isDark ? Colors.black : Colors.white,
                    ),
                    CheckboxListTile(
                      value: _includeIncome,
                      onChanged: (v) =>
                          setState(() => _includeIncome = v ?? true),
                      title: Text(localizer.income),
                      activeColor: mintJade.selectedIconColor,
                      checkColor: isDark ? Colors.black : Colors.white,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: Text(localizer.exportAsPdf),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mintJade.buttonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _exportPdf(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RangeDateTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _RangeDateTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.18) : color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.7 : 1),
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          DateFormat.yMMMd().format(date),
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.grey.shade900,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.edit_calendar, color: color),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
