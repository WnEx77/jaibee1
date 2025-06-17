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
import 'package:provider/provider.dart';
import 'package:jaibee1/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(GoalAdapter());

  // Open boxes
  await Hive.openBox('transactions');
  await Hive.openBox<Category>('categories');
  await Hive.openBox<double>('settings'); // For monthlyLimit and theme preference
  await Hive.openBox<Budget>('budgets');
  await Hive.openBox<Goal>('goals');
  await Hive.openBox<Category>('userCategories');

  await addDefaultCategoriesIfEmpty();
  await addDefaultMonthlyLimitIfNotExists();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider()..loadThemeFromHive(),
      child: const ExpenseTrackerApp(),
    ),
  );
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
    await settingsBox.put('monthlyLimit', 1000.0);
  }
}

// providers/theme_provider.dart

class ThemeProvider extends ChangeNotifier {
  static const _themeKey = 'isDarkTheme';
  final Box<double> _settingsBox = Hive.box<double>('settings');

  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  ThemeMode get themeMode => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadThemeFromHive() async {
    // Default to false (light) if not set or value != 1
    _isDarkTheme = (_settingsBox.get(_themeKey) ?? 0) == 1;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _isDarkTheme = isDark;
    await _settingsBox.put(_themeKey, isDark ? 1 : 0);
    notifyListeners();
  }
}

// main app widget

class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    final _ExpenseTrackerAppState? state = context.findAncestorStateOfType<_ExpenseTrackerAppState>();
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
    final themeProvider = Provider.of<ThemeProvider>(context);

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      textTheme: const TextTheme(bodyMedium: TextStyle(fontFamily: 'Cairo')),
      brightness: Brightness.light,
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey, brightness: Brightness.dark),
      textTheme: const TextTheme(bodyMedium: TextStyle(fontFamily: 'Cairo')),
      brightness: Brightness.dark,
    );

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
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}

// Splash screen (no changes needed)
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
      backgroundColor: Theme.of(context).colorScheme.background,
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
