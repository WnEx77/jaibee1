import 'monthly_summary.dart';
import 'dart:ui';

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