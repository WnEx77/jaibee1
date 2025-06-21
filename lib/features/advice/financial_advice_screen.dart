import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:jaibee1/data/models/trancs.dart';
import 'package:jaibee1/secrets.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/data/models/budget.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:month_year_picker/month_year_picker.dart';
import 'package:jaibee1/shared/widgets/app_background.dart';
import 'package:jaibee1/core/theme/mint_jade_theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:jaibee1/core/utils/connection_checker.dart';
import 'package:lottie/lottie.dart';
import 'package:another_flushbar/flushbar.dart';


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
  List<Map<String, dynamic>> budgets = const [],
}) {
  final isArabic = locale.languageCode == 'ar';
  final prompt = StringBuffer();

if (isArabic) {
  prompt.writeln("جاوبني باللهجة السعودية العامية. أنت مستشار مالي ذكي وخبير، هدفك تعطيني نصيحة مالية عملية ومخصصة بناءً على وضعي الحالي.");
  prompt.writeln("اعتمد على البيانات التالية، ووضح لي إذا كنت على الطريق الصحيح أو أحتاج أعدل من سلوكي المالي. إذا فيه أخطاء أو فرص للتحسين، وضحها بشكل واضح وبسيط.");
  prompt.writeln("لا تكرر الأرقام، ركز على التحليل والنصائح العملية.");
  prompt.writeln("إذا فيه تصنيفات صرف مرتفعة أو غير متوازنة، نبهني عليها واقترح حلول.");
  prompt.writeln("إذا أهدافي غير واقعية أو تحتاج تعديل، وضح لي السبب واقترح خطة بديلة.");
  prompt.writeln("إذا وضعي المالي ممتاز، امدحني واقترح كيف أطور أكثر.");
  prompt.writeln("استخدم لغة سهلة وقصيرة، وركز على أهم نقطة واحدة أو نقطتين.");

  if (sex != null) prompt.writeln("الجنس: $sex");
  if (age != null) prompt.writeln("العمر: $age سنة");

  if (budgets.isNotEmpty) {
    prompt.writeln("\nتفصيل الميزانية حسب التصنيفات:");
    for (var budget in budgets) {
      prompt.writeln("- ${budget['category']}: الحد المخصص هو \$${budget['limit']}");
    }
  }

  prompt.writeln("\nملخص الشهر الحالي:");
  prompt.writeln("- الدخل الكلي: \$${summary.totalIncome.toStringAsFixed(2)}");
  prompt.writeln("- مجموع المصروفات: \$${summary.totalExpenses.toStringAsFixed(2)}");

  prompt.writeln(
    summary.monthlyLimit != null
        ? "- الحد الشهري للصرف: \$${summary.monthlyLimit!.toStringAsFixed(2)}"
        : "- ما حددت حد شهري للصرف.",
  );

  prompt.writeln("\nتفاصيل المصاريف حسب التصنيفات:");
  summary.expensesByCategory.forEach((category, amount) {
    prompt.writeln("- $category: \$${amount.toStringAsFixed(2)}");
  });

  if (goals.isNotEmpty) {
    prompt.writeln("\nأهدافي المالية الحالية:");
    for (var goal in goals) {
      prompt.writeln("- أبغى أوصل لهدف '${goal['item']}' عن طريق استثمار \$${goal['monthly']} شهريًا لمدة ${goal['months']} شهر (${goal['type']}).");
    }
  }

  prompt.writeln(
    "\nبناءً على كل المعلومات أعلاه، عطِني نصيحة مالية مختصرة وواضحة تناسب وضعي. قيم صرفي وأهدافي، واقترح لي أهم تعديل أو خطوة أبدأ فيها الآن.",
  );

} else {
  prompt.writeln("You are an expert personal finance advisor. Your goal is to give me actionable, personalized advice based on my current financial data.");
  prompt.writeln("Analyze the data below and tell me if my spending and goals are on track, or if I need to make changes. Highlight any issues or opportunities for improvement.");
  prompt.writeln("Do not repeat the numbers, focus on analysis and practical tips.");
  prompt.writeln("If any expense categories are unusually high or unbalanced, point them out and suggest solutions.");
  prompt.writeln("If my goals are unrealistic or need adjustment, explain why and suggest a better plan.");
  prompt.writeln("If my finances are excellent, acknowledge that and suggest how I can improve even further.");
  prompt.writeln("Use clear, concise language and focus on one or two key points.");

  if (sex != null) prompt.writeln("Sex: $sex");
  if (age != null) prompt.writeln("Age: $age");

  if (budgets.isNotEmpty) {
    prompt.writeln("\nBudget breakdown by category:");
    for (var budget in budgets) {
      prompt.writeln("- ${budget['category']}: Limit \$${budget['limit']}");
    }
  }

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
    "\nBased on all the above, give me a concise, practical financial advice tailored to my situation. Evaluate my spending and goals, and suggest the most important adjustment or next step I should take.",
  );
}

return prompt.toString();
}

Future<double> getMonthlyLimit() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getDouble('monthly_limit') ?? 0;
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
    final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
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

  Future<double?> _getMonthlyLimitFromBudgetsBox() async {
    final budgetsBox = Hive.box<Budget>('budgets');
    final monthlyBudget = budgetsBox.get('__monthly__');
    return monthlyBudget?.limit;
  }

  Future<void> _loadAdvice() async {
    try {
      // ✅ Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();

      // Get monthly limit from budgets box instead of prefs
      final double? monthlyLimit = await _getMonthlyLimitFromBudgetsBox();

      final budgetsBox = Hive.box<Budget>('budgets');
      final List<Map<String, dynamic>> budgets = budgetsBox.values
          .whereType<Budget>()
          .map((b) => {'category': b.category, 'limit': b.limit})
          .toList();

      if (connectivityResult == ConnectivityResult.none) {
        setState(() {
          _error = S.of(context)!.noInternetConnection;
          _loading = false;
        });
        return;
      }

      final locale = Localizations.localeOf(context);
      final transactionsBox = Hive.box('transactions');

      final summary = getMonthlySummary(
        _selectedMonth,
        transactionsBox,
        monthlyLimit: monthlyLimit,
      );

      // Still get sex, age, goals from prefs if needed
      final prefs = await SharedPreferences.getInstance();
      final String? sex = prefs.getString('user_sex');
      final int? age = prefs.getInt('user_age');
      final String? goalsJson = prefs.getString('user_goals_list');
      final List<Map<String, dynamic>> goals = goalsJson != null
          ? List<Map<String, dynamic>>.from(jsonDecode(goalsJson))
          : [];

      final prompt = generatePrompt(
        summary,
        locale,
        sex: sex,
        age: age,
        goals: goals,
        budgets: budgets,
      );

      final advice = await fetchFinancialAdvice(prompt);

      setState(() {
        _summary = summary;
        _advice = advice;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        // _error = 'Something went wrong: ${e.toString()}';
        _error = S.of(context)!.noInternetConnection;
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
                  // Use Flushbar instead of SnackBar
                  // Add flushbar package to pubspec.yaml: flushbar: ^1.10.4
                  // Import at top: import 'package:another_flushbar/flushbar.dart';
                  Flushbar(
                  message: S.of(context)!.adviceCopied,
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(8),
                  borderRadius: BorderRadius.circular(8),
                  backgroundColor: Colors.green.shade600,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  ).show(context);
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
          fallbackText != null && (value == 0 || value == null)
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
    final ByteData logoBytes = await rootBundle.load('assets/images/logo.png');
    final Uint8List logoUint8List = logoBytes.buffer.asUint8List();
    final pw.MemoryImage logo = pw.MemoryImage(logoUint8List);

    // Load Arabic font
    final arabicFontData = await rootBundle.load(
      'assets/fonts/NotoSansArabic-Regular.ttf',
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
                    (_summary!.monthlyLimit ?? 0) > 0
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
    final ByteData logoBytes = await rootBundle.load('assets/images/logo.png');
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
                  (_summary!.monthlyLimit ?? 0) > 0
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
              ? Center(
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: Lottie.asset(
                      'assets/animations/loading.json',
                      repeat: true,
                    ),
                  ),
                )
              : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        Theme.of(context).brightness == Brightness.dark
                            ? 'assets/images/error_DarkMode.png'
                            : 'assets/images/error.png',
                        height: 300,
                        width: 300,
                      ),

                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: Text(S.of(context)!.retry),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mintJadeColors.buttonColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _loading = true;
                            _error = null;
                          });
                          _loadAdvice();
                        },
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              // Income
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Text(S.of(context)!.income),
                                Row(
                                  children: [
                                  Text(
                                    "${_summary!.totalIncome.toStringAsFixed(2)}",
                                    style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Image.asset(
                                    'assets/images/Saudi_Riyal_Symbol.png',
                                    color: Colors.green,
                                    height: 20,
                                    width: 20,
                                  ),
                                  ],
                                ),
                                ],
                              ),
                              // Expenses
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Text(S.of(context)!.expenses),
                                Row(
                                  children: [
                                  Text(
                                    "${_summary!.totalExpenses.toStringAsFixed(2)}",
                                    style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Image.asset(
                                    'assets/images/Saudi_Riyal_Symbol.png',
                                    color: Colors.red,
                                    height: 20,
                                    width: 20,
                                  ),
                                  ],
                                ),
                                ],
                              ),
                              // Limit
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Text(S.of(context)!.limit),
                                Row(
                                  children: [
                                  Text(
                                    (_summary!.monthlyLimit ?? 0) == 0
                                      ? S.of(context)!.notSet
                                      : "${_summary!.monthlyLimit!.toStringAsFixed(2)}",
                                    style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                    ),
                                  ),
                                  if ((_summary!.monthlyLimit ?? 0) != 0)
                                    ...[
                                    const SizedBox(width: 4),
                                    Image.asset(
                                      'assets/images/Saudi_Riyal_Symbol.png',
                                      color: Colors.orange,
                                      height: 20,
                                      width: 20,
                                    ),
                                    ],
                                  ],
                                ),
                                ],
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

                      // Disclaimer section
                      Builder(
                        builder: (context) {
                          final isArabic = Localizations.localeOf(context).languageCode == 'ar';
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic ? "تنويه" : "Disclaimer",
                                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isDark ? Colors.red[300] : Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isArabic
                                      ? "هذه النصيحة تم إنشاؤها بواسطة الذكاء الاصطناعي وتُعد لأغراض معلوماتية فقط. المطور غير مسؤول عن أي تصرفات أو قرارات مالية يتم اتخاذها بناءً على هذه النصيحة."
                                      : 'This advice is generated by AI for informational purposes only. The developer is not responsible for any actions taken based on it.',
                                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark ? Colors.grey[300] : Colors.black54,
                                  ),
                                ),
                                if (isArabic) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'للحصول على اجابات افضل فضلًا استخدم اللغة الإنجليزية',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.orange[800],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
