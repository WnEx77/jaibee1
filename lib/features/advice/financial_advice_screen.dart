import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
// import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
// import 'package:jaibee1/data/models/trancs.dart';
// import 'package:jaibee1/secrets.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/data/models/budget.dart';
import 'package:flutter/services.dart';
// import 'package:printing/printing.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:month_year_picker/month_year_picker.dart';
import 'package:jaibee1/shared/widgets/app_background.dart';
import 'package:jaibee1/core/theme/mint_jade_theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:jaibee1/core/utils/connection_checker.dart';
import 'package:lottie/lottie.dart';
import 'package:another_flushbar/flushbar.dart';
import 'monthly_summary.dart';
import 'prompt_generator.dart';
import 'advice_api.dart';
import 'advice_pdf.dart';

Future<double> getMonthlyLimit() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getDouble('monthly_limit') ?? 0;
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
                    generatePdfArabic(
                      context,
                      _summary!,
                      _advice ?? '',
                      _selectedMonth,
                    );
                  } else {
                    generatePdfEnglish(
                      context,
                      _summary!,
                      _advice ?? '',
                      _selectedMonth,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
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
                                        if ((_summary!.monthlyLimit ?? 0) !=
                                            0) ...[
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
                          final isArabic =
                              Localizations.localeOf(context).languageCode ==
                              'ar';
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isArabic ? "تنويه" : "Disclaimer",
                                  textAlign: isArabic
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isDark
                                        ? Colors.red[300]
                                        : Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isArabic
                                      ? "هذه النصيحة تم إنشاؤها بواسطة الذكاء الاصطناعي وتُعد لأغراض معلوماتية فقط. المطور غير مسؤول عن أي تصرفات أو قرارات مالية يتم اتخاذها بناءً على هذه النصيحة."
                                      : 'This advice is generated by AI for informational purposes only. The developer is not responsible for any actions taken based on it.',
                                  textAlign: isArabic
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.black54,
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
