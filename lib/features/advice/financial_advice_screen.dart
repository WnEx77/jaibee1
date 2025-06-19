import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:jaibee1/data/models/trancs.dart';
import 'package:jaibee1/secrets.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:month_year_picker/month_year_picker.dart';
import 'package:jaibee1/shared/widgets/app_background.dart';
import 'package:jaibee1/core/theme/mint_jade_theme.dart';

class MonthlySummary {
  final double totalIncome;
  final double totalExpenses;
  final Map<String, double> expensesByCategory;
  final double? monthlyLimit;

  MonthlySummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.expensesByCategory,
    required this.monthlyLimit,
  });
}

MonthlySummary getMonthlySummary(
  DateTime month,
  Box transactionsBox, {
  double? monthlyLimit,
}) {
  double income = 0.0;
  double expenses = 0.0;
  Map<String, double> categoryTotals = {};

  for (var transaction in transactionsBox.values) {
    if (transaction is Transaction &&
        transaction.date.month == month.month &&
        transaction.date.year == month.year) {
      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expenses += transaction.amount;
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }
  }

  return MonthlySummary(
    totalIncome: income,
    totalExpenses: expenses,
    expensesByCategory: categoryTotals,
    monthlyLimit: monthlyLimit,
  );
}

String generatePrompt(
  MonthlySummary summary,
  Locale locale, {
  String? sex,
  int? age,
  List<Map<String, dynamic>> goals = const [],
}) {
  final isArabic = locale.languageCode == 'ar';
  final prompt = StringBuffer();

  if (isArabic) {
    prompt.writeln("جاوب علي بلهجة سعودية عامية، أنت مساعد مالي ذكي.");
    if (sex != null) prompt.writeln("الجنس: $sex");
    if (age != null) prompt.writeln("العمر: $age سنة");

    prompt.writeln("ملخص الشهر الحالي:");
    prompt.writeln("الدخل: \$${summary.totalIncome.toStringAsFixed(2)}");
    prompt.writeln("المصروفات: \$${summary.totalExpenses.toStringAsFixed(2)}");
    prompt.writeln(
      summary.monthlyLimit != null
          ? "الحد الشهري للصرف: \$${summary.monthlyLimit!.toStringAsFixed(2)}"
          : "مافيه حد شهري محدد.",
    );

    prompt.writeln("\nتفاصيل المصروفات حسب التصنيفات:");
    summary.expensesByCategory.forEach((category, amount) {
      prompt.writeln("- $category: \$${amount.toStringAsFixed(2)}");
    });

    if (goals.isNotEmpty) {
      prompt.writeln("\nأهدافي المالية:");
      for (var goal in goals) {
        prompt.writeln(
          "- نوع الهدف: ${goal['type']}, ابي اشتري ${goal['item']}, ابي اوفر\$${goal['monthly']} شهرياً لمدة ${goal['months']} شهور",
        );
      }
    }

    prompt.writeln(
      "\nاعطني نصائح مالية شخصية تساعده يوازن بين مصاريفه وأهدافه المالية. اقترح عليه إذا يحتاج يعدل أهدافه أو صرفه.",
    );
  } else {
    prompt.writeln("You are a smart personal finance assistant.");
    if (sex != null) prompt.writeln("Sex: $sex");
    if (age != null) prompt.writeln("Age: $age");

    prompt.writeln("\nMonthly Summary:");
    prompt.writeln("Income: \$${summary.totalIncome.toStringAsFixed(2)}");
    prompt.writeln("Expenses: \$${summary.totalExpenses.toStringAsFixed(2)}");
    prompt.writeln(
      summary.monthlyLimit != null
          ? "Spending Limit: \$${summary.monthlyLimit!.toStringAsFixed(2)}"
          : "No spending limit set.",
    );

    prompt.writeln("\nExpense breakdown by category:");
    summary.expensesByCategory.forEach((category, amount) {
      prompt.writeln("- $category: \$${amount.toStringAsFixed(2)}");
    });

    if (goals.isNotEmpty) {
      prompt.writeln("\nUser's financial goals:");
      for (var goal in goals) {
        prompt.writeln(
          "- Goal Type: ${goal['type']}, Item: ${goal['item']}, Monthly Investment: \$${goal['monthly']}, Timeframe: ${goal['months']} months",
        );
      }
    }

    prompt.writeln(
      "\nProvide concise and personalized financial advice based on age, sex, expenses, and goals. Include whether the user should adjust their goals or spending.",
    );
  }

  return prompt.toString();
}

Future<String> fetchFinancialAdvice(String prompt) async {
  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/chat/completions'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $openAiApiKey',
    },
    body: json.encode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "user", "content": prompt},
      ],
      "temperature": 0.7,
    }),
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return jsonResponse['choices'][0]['message']['content'];
  } else {
    throw Exception(
      'Failed to fetch advice: ${response.body}, Please contact the developer: amoharib77@gmail.com',
    );
  }
}

class FinancialAdviceScreen extends StatefulWidget {
  const FinancialAdviceScreen({super.key});

  @override
  State<FinancialAdviceScreen> createState() => _FinancialAdviceScreenState();
}

class _FinancialAdviceScreenState extends State<FinancialAdviceScreen> {
  String? _advice;
  bool _loading = true;
  String? _error;
  MonthlySummary? _summary;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAdvice());
  }

  Future<void> _loadAdvice() async {
    try {
      final locale = Localizations.localeOf(context);

      final transactionsBox = Hive.box('transactions');
      final prefs = await SharedPreferences.getInstance();
      final double? monthlyLimit = prefs.getDouble('monthly_limit') ?? 0;

      final summary = getMonthlySummary(
        _selectedMonth,
        transactionsBox,
        monthlyLimit: monthlyLimit,
      );

      final String? sex = prefs.getString('user_sex');
      final int? age = prefs.getInt('user_age');

      // ✅ Get and decode goals
      final String? goalsJson = prefs.getString('user_goals_list');
      final List<Map<String, dynamic>> goals = goalsJson != null
          ? List<Map<String, dynamic>>.from(jsonDecode(goalsJson))
          : [];

      final prompt = generatePrompt(
        summary,
        locale,
        sex: sex,
        age: age,
        goals: goals, // ⬅️ pass to prompt
      );

      final advice = await fetchFinancialAdvice(prompt);

      setState(() {
        _summary = summary;
        _advice = advice;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // Future<void> _pickMonth() async {
  //   final DateTime now = DateTime.now();
  //   final DateTime? picked = await showMonthYearPicker(
  //     context: context,
  //     initialDate: _selectedMonth,
  //     firstDate: DateTime(now.year - 3),
  //     lastDate: DateTime(now.year + 1),
  //   );

  //   if (picked != null) {
  //     setState(() {
  //       _selectedMonth = DateTime(picked.year, picked.month);
  //       _loading = true;
  //     });
  //     await _loadAdvice();
  //   }
  // }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: Text(S.of(context)!.copyAdvice),
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: _advice ?? ''));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.of(context)!.adviceCopied)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: Text(S.of(context)!.exportAsPdf),
                onTap: () {
                  Navigator.pop(context);
                  final languageCode = Localizations.localeOf(
                    context,
                  ).languageCode;

                  if (languageCode == 'ar') {
                    _generatePdfArabic(context);
                  } else {
                    _generatePdfEnglish(context);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryItem(
    String title,
    double value,
    Color color, {
    String? fallbackText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Text(
          fallbackText != null && value == 0
              ? fallbackText
              : "\$${value.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _generatePdfArabic(BuildContext flutterContext) async {
    final s = S.of(flutterContext);
    if (s == null || _summary == null) return;

    final pdf = pw.Document();

    // Load logo
    final ByteData logoBytes = await rootBundle.load(
      'assets/images/Jaibee_logo-removebg-preview.png',
    );
    final Uint8List logoUint8List = logoBytes.buffer.asUint8List();
    final pw.MemoryImage logo = pw.MemoryImage(logoUint8List);

    // Load Arabic font
    final arabicFontData = await rootBundle.load(
      'assets/fonts/Amiri-Regular.ttf',
    );
    final arabicFont = pw.Font.ttf(arabicFontData);

    final String monthName = DateFormat.yMMMM('ar').format(_selectedMonth);
    final String title = '${s.aiFinancialAdvice} - $monthName';
    final String adviceContent = _advice ?? s.noAdvice;

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
                    "\$${_summary!.totalIncome.toStringAsFixed(2)}",
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
                    "\$${_summary!.totalExpenses.toStringAsFixed(2)}",
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
                    _summary!.monthlyLimit != null
                        ? "\$${_summary!.monthlyLimit!.toStringAsFixed(2)}"
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
                      adviceContent,
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

  Future<void> _generatePdfEnglish(BuildContext flutterContext) async {
    final s = S.of(flutterContext);
    if (s == null || _summary == null) return;

    final pdf = pw.Document();

    // Load logo
    final ByteData logoBytes = await rootBundle.load(
      'assets/images/Jaibee_logo-removebg-preview.png',
    );
    final Uint8List logoUint8List = logoBytes.buffer.asUint8List();
    final pw.MemoryImage logo = pw.MemoryImage(logoUint8List);

    // Load English fonts
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    final String monthName = DateFormat.yMMMM().format(_selectedMonth);
    final String title = '${s.aiFinancialAdvice} - $monthName';
    final String adviceContent = _advice ?? s.noAdvice;

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
                  "\$${_summary!.totalIncome.toStringAsFixed(2)}",
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
                  "\$${_summary!.totalExpenses.toStringAsFixed(2)}",
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
                  _summary!.monthlyLimit != null
                      ? "\$${_summary!.monthlyLimit!.toStringAsFixed(2)}"
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
                    adviceContent,
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

  @override
  Widget build(BuildContext context) {
    final mintJadeColors = Theme.of(context).extension<MintJadeColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: mintJadeColors.appBarColor,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              S.of(context)!.aiFinancialAdvice,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: _showShareOptions,
              ),
            ],
          ),
        ),
      ),
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text("Error: $_error"))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month Picker Row
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(
                      //       DateFormat.MMMM().format(_selectedMonth),
                      //       style: const TextStyle(
                      //         fontSize: 20,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //     TextButton.icon(
                      //       onPressed: _pickMonth,
                      //       icon: Icon(
                      //         Icons.calendar_today,
                      //         size: 16,
                      //         color: mintJadeColors.unselectedIconColor,
                      //       ),
                      //       label: Text(
                      //         "Pick Month",
                      //         style: TextStyle(
                      //           color: mintJadeColors.unselectedIconColor,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(height: 12),

                      // Summary Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: mintJadeColors.appBarColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat.yMMMM().format(_selectedMonth),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _summaryItem(
                                  S.of(context)!.income,
                                  _summary!.totalIncome,
                                  Colors.green,
                                ),
                                _summaryItem(
                                  S.of(context)!.expenses,
                                  _summary!.totalExpenses,
                                  Colors.red,
                                ),
                                _summaryItem(
                                  S.of(context)!.limit,
                                  _summary!.monthlyLimit ?? 0,
                                  Colors.orange,
                                  fallbackText: "Not set",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        S.of(context)!.personalizedAdvice,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: mintJadeColors.appBarColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: mintJadeColors.selectedIconColor,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          _advice ?? S.of(context)!.noAdvice,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        "Disclaimer",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.red[300] : Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Directionality(
                        textDirection: Directionality.of(context),
                        child: Text(
                          'This advice is generated by AI for informational purposes only. The developer is not responsible for any actions taken based on it.',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[300] : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
