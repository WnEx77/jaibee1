import 'dart:ui';
import 'monthly_summary.dart';

Future<String> generatePrompt(
  MonthlySummary summary,
  Locale locale, {
  List<Map<String, dynamic>> budgets = const [],
}) async {
  final isArabic = locale.languageCode == 'ar';
  final prompt = StringBuffer();

  if (isArabic) {
    prompt.writeln(
      "ابدأ ردك دائمًا بالجملة التالية: عزيزي، بناءً على بياناتك المالية، هذا هو تحليلي ونصيحتي المخصصة لك:",
    );
    prompt.writeln(
      "أنت مستشار مالي ذكي باللهجة السعودية. دورك تقدم تحليل مفصل ونصائح عملية بناءً على وضعي.",
    );
    prompt.writeln(
      "لا تعيد ذكر الأرقام مثل ما هي، ركز على التحليل، التوجيه، والفرص.",
    );
    prompt.writeln("وضح لي إذا كنت أصرف بشكل متوازن، وإذا فيه تصنيفات تحتاج مراجعة.");
    prompt.writeln("قيم وضعي المالي وهل هو مستقر أو يحتاج تدخل.");
    prompt.writeln("إذا وضعي ممتاز، امدحني وعلمني كيف أطور نفسي أكثر.");
    prompt.writeln("تكلم بلغة واضحة، قصيرة، وتركز على أهم نصيحتين أو ثلاث.");
    prompt.writeln(
      "حتى لو بعض التصنيفات مكتوبة بالإنجليزية، ترجمها وتكلم بالعربية فقط.",
    );

    prompt.writeln("\n📊 ملخص الشهر:");
    prompt.writeln("- إجمالي الدخل: ${summary.totalIncome.toStringAsFixed(2)}");
    prompt.writeln("- إجمالي المصروفات: ${summary.totalExpenses.toStringAsFixed(2)}");

    if (summary.monthlyLimit != null) {
      prompt.writeln("- الحد الشهري للصرف (من الميزانية): ${summary.monthlyLimit!.toStringAsFixed(2)}");
    } else {
      prompt.writeln("- ما تم تحديد حد شهري للصرف.");
    }

    prompt.writeln("\n💸 توزيع المصروفات حسب التصنيف:");
    summary.expensesByCategory.forEach((category, amount) {
      prompt.writeln("- $category: ${amount.toStringAsFixed(2)}");
    });

    if (budgets.isNotEmpty) {
      prompt.writeln("\n🧾 الميزانية المحددة لكل تصنيف:");
      for (var budget in budgets) {
        final category = budget['category'];
        final limit = budget['limit'];
        final spent = summary.expensesByCategory[category] ?? 0.0;
        final status = spent > limit ? "🔴 فوق الحد" : "🟢 ضمن الحد";
        prompt.writeln(
          "- $category: صرفت ${spent.toStringAsFixed(2)} (الحد: ${limit.toStringAsFixed(2)}) $status",
        );
      }
    }

    prompt.writeln(
      "\n📌 عطِني تحليل صريح، مع أهم 2-3 نصائح ممكن تساعدني أبدأ أتحسن من اليوم.",
    );
  } else {
    prompt.writeln(
      "Start your response with this sentence exactly: Dear, based on your financial data, here is my analysis and tailored advice:",
    );
    prompt.writeln(
      "You are a smart financial advisor. Your role is to provide personal, insightful, and actionable financial guidance.",
    );
    prompt.writeln(
      "Do not simply repeat numbers. Focus on insight, trends, and decision-making.",
    );
    prompt.writeln("Tell me if my expenses are healthy or need adjustment.");
    prompt.writeln(
      "Evaluate if my financial state is stable or needs intervention.",
    );
    prompt.writeln(
      "Praise me if I’m doing well, and suggest what to improve further.",
    );
    prompt.writeln(
      "Keep your advice focused on the top 2–3 most impactful changes.",
    );

    prompt.writeln("\n📊 Monthly Summary:");
    prompt.writeln("- Total Income: ${summary.totalIncome.toStringAsFixed(2)}");
    prompt.writeln("- Total Expenses: ${summary.totalExpenses.toStringAsFixed(2)}");

    if (summary.monthlyLimit != null) {
      prompt.writeln("- Monthly Spending Limit (from budgets): ${summary.monthlyLimit!.toStringAsFixed(2)}");
    } else {
      prompt.writeln("- No monthly spending limit has been set.");
    }

    prompt.writeln("\n💸 Expense Breakdown by Category:");
    summary.expensesByCategory.forEach((category, amount) {
      prompt.writeln("- $category: ${amount.toStringAsFixed(2)}");
    });

    if (budgets.isNotEmpty) {
      prompt.writeln("\n🧾 Budget Overview:");
      for (var budget in budgets) {
        final category = budget['category'];
        final limit = budget['limit'];
        final spent = summary.expensesByCategory[category] ?? 0.0;
        final status = spent > limit ? "🔴 Over Budget" : "🟢 Within Budget";
        prompt.writeln(
          "- $category: Spent ${spent.toStringAsFixed(2)} (Limit: ${limit.toStringAsFixed(2)}) $status",
        );
      }
    }

    prompt.writeln(
      "\n📌 Based on all the above, provide a clear and actionable evaluation of my finances with your top 2–3 personalized recommendations.",
    );
  }

  return prompt.toString();
}
