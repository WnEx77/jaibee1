import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jaibee1/data/models/trancs.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:jaibee1/shared/widgets/app_background.dart';
import 'package:jaibee1/shared/widgets/custom_app_bar.dart';
import 'package:jaibee1/core/theme/mint_jade_theme.dart';

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

    final pdf = pw.Document();

    // Load logo
    final ByteData logoBytes = await rootBundle.load('assets/images/logo.png');
    final Uint8List logoUint8List = logoBytes.buffer.asUint8List();
    final pw.MemoryImage logo = pw.MemoryImage(logoUint8List);

    // Font setup
    pw.Font? baseFont;
    pw.Font? boldFont;
    if (isArabic) {
      final arabicFontData = await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
      baseFont = pw.Font.ttf(arabicFontData);
      boldFont = baseFont;
    } else {
      baseFont = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
      boldFont = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));
    }

    // period variable removed as it was unused

    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
        textDirection: isArabic
            ? pw.TextDirection.rtl
            : pw.TextDirection.ltr,
        build: (context) => [
          // Header with logo
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  localizer.reportTitle,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.redAccent,
                    font: boldFont,
                  ),
                ),
              ),
              pw.Image(logo, height: 60),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            localizer.reportTitle,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.redAccent,
              font: boldFont,
            ),
          ),
          pw.SizedBox(height: 16),

          // Section titles
          pw.Row(
            children: [
              pw.Text(
                localizer.expense,
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.red,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Text(
                localizer.income,
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.green,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),

          // Table in a card-like container
          pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.blueGrey, width: 1),
            ),
            padding: const pw.EdgeInsets.all(12),
            child: pw.TableHelper.fromTextArray(
              headers: [
                localizer.date,
                localizer.category,
                localizer.amount,
                '${localizer.income}/${localizer.expense}',
              ],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
              cellStyle: pw.TextStyle(font: baseFont, fontSize: 11),
              data: transactions
                  .map(
                    (t) => [
                      DateFormat.yMMMd(
                        localeCode,
                      ).format(t.date),
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
          pw.SizedBox(height: 24),

          // Disclaimer
          pw.Text(
            isArabic ? "تنويه" : "Disclaimer",
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 14,
              color: PdfColors.deepOrange,
            ),
          ),
          pw.Text(
            isArabic
                ? "هذا التقرير المالي تم إنشاؤه بواسطة التطبيق لأغراض معلوماتية فقط. المطور غير مسؤول عن أي قرارات مالية يتم اتخاذها بناءً على هذا المحتوى."
                : "This financial report is generated by the app for informational purposes only. The developer is not responsible for financial decisions made based on this content.",
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  // ...existing code...

  Future<void> _pickSingleDate(
    BuildContext context, {
    required bool isStart,
  }) async {
    DateTime initialDate = isStart
        ? _selectedRange!.start
        : _selectedRange!.end;
    DateTime minDate = isStart ? DateTime(2000) : _selectedRange!.start;
    DateTime maxDate = isStart ? _selectedRange!.end : DateTime.now();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime pickedDate = initialDate;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final backgroundColor = isDark ? Colors.grey[900] : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;

        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Text(
                  isStart
                      ? S.of(context)!.startDate
                      : S.of(context)!.endDate,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  width: 260,
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      brightness: isDark ? Brightness.dark : Brightness.light,
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          color: textColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: initialDate,
                      minimumDate: minDate,
                      maximumDate: maxDate,
                      onDateTimeChanged: (date) {
                        pickedDate = date;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  child: Text('Done', style: TextStyle(color: textColor)),
                  onPressed: () {
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
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          backgroundColor: backgroundColor,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizer = S.of(context)!;
    final mintTheme = Theme.of(context).extension<MintJadeColors>()!;
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
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text(localizer.startDate),
                            subtitle: Text(
                              DateFormat.yMMMd().format(_selectedRange!.start),
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                            ),
                            trailing: Icon(
                              Icons.edit_calendar,
                              color: mintTheme.selectedIconColor,
                            ),
                            onTap: () =>
                                _pickSingleDate(context, isStart: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ListTile(
                            title: Text(localizer.endDate),
                            subtitle: Text(
                              DateFormat.yMMMd().format(_selectedRange!.end),
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                            ),
                            trailing: Icon(
                              Icons.edit_calendar,
                              color: mintTheme.selectedIconColor,
                            ),
                            onTap: () =>
                                _pickSingleDate(context, isStart: false),
                          ),
                        ),
                      ],
                    ),
                    CheckboxListTile(
                      value: _includeExpenses,
                      onChanged: (v) =>
                          setState(() => _includeExpenses = v ?? true),
                      title: Text(localizer.expense),
                      activeColor: mintTheme.selectedIconColor,
                      checkColor: isDark ? Colors.black : Colors.white,
                    ),
                    CheckboxListTile(
                      value: _includeIncome,
                      onChanged: (v) =>
                          setState(() => _includeIncome = v ?? true),
                      title: Text(localizer.income),
                      activeColor: mintTheme.selectedIconColor,
                      checkColor: isDark ? Colors.black : Colors.white,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: Text(localizer.exportAsPdf),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mintTheme.buttonColor,
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
