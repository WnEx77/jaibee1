import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jaibee1/l10n/s.dart';
import 'package:jaibee1/models/trancs.dart';
import 'package:jaibee1/screens/expense_home_screen.dart';
import 'package:jaibee1/models/category.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:jaibee1/models/budget.dart';
import 'package:jaibee1/models/goal_model.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive only once:
  await Hive.initFlutter();

  // Register Adapters before opening boxes:
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(GoalAdapter());

  // Open boxes BEFORE running the app:
  await Hive.openBox('transactions');
  await Hive.openBox<Category>('categories');
  await Hive.openBox<double>('settings'); // For monthlyLimit and other simple settings
  await Hive.openBox<Budget>('budgets');
  await Hive.openBox<Goal>('goals');
  // print('Box type: ${Hive.box<Goal>('goals').runtimeType}');

  // Add default data if needed
  await addDefaultCategoriesIfEmpty();
  await addDefaultMonthlyLimitIfNotExists();

  runApp(const ExpenseTrackerApp());
}

Future<void> addDefaultCategoriesIfEmpty() async {
  final box = Hive.box<Category>('categories');
  if (box.isEmpty) {
    await box.addAll([
      Category(name: 'food'),
      Category(name: 'transportation'),
      Category(name: 'entertainment'),
      Category(name: 'coffee'),
      Category(name: 'other'),
    ]);
  }
}

Future<void> addDefaultMonthlyLimitIfNotExists() async {
  final settingsBox = Hive.box<double>('settings');
  if (!settingsBox.containsKey('monthlyLimit')) {
    await settingsBox.put(
      'monthlyLimit',
      1000.0,
    ); // Default monthly limit $1000
  }
}

class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    final _ExpenseTrackerAppState? state = context
        .findAncestorStateOfType<_ExpenseTrackerAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'جيبي',
      locale: _locale,
      supportedLocales: S.supportedLocales,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return supportedLocales.first;
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        textTheme: const TextTheme(bodyMedium: TextStyle(fontFamily: 'Cairo')),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(_createFadeRoute());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Route _createFadeRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const ExpenseHomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 1200),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            'assets/images/Jaibee_logo-removebg-preview.png',
            width: 150,
          ),
        ),
      ),
    );
  }
}
