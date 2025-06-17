import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 's_ar.dart';
import 's_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/s.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Jaibee'**
  String get appTitle;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAmount;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @transportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get transportation;

  /// No description provided for @entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// No description provided for @coffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get coffee;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @transactionAdded.
  ///
  /// In en, this message translates to:
  /// **'Transaction added'**
  String get transactionAdded;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No Transactions Yet'**
  String get noTransactions;

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get transactionDeleted;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @customizeCategories.
  ///
  /// In en, this message translates to:
  /// **'Customize Categories'**
  String get customizeCategories;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get newCategory;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense Report'**
  String get reportTitle;

  /// No description provided for @dailyExpenses.
  ///
  /// In en, this message translates to:
  /// **'Daily Expenses'**
  String get dailyExpenses;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @averageDaily.
  ///
  /// In en, this message translates to:
  /// **'Average Daily Expense'**
  String get averageDaily;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @selectPeriod.
  ///
  /// In en, this message translates to:
  /// **'Select Period'**
  String get selectPeriod;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @applyFilter.
  ///
  /// In en, this message translates to:
  /// **'Apply Filter'**
  String get applyFilter;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @addQuickTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Quick Transaction'**
  String get addQuickTransaction;

  /// No description provided for @filterTransactions.
  ///
  /// In en, this message translates to:
  /// **'Filter The Transactions'**
  String get filterTransactions;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @monthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly Limit'**
  String get monthlyLimit;

  /// No description provided for @monthlyLimitSet.
  ///
  /// In en, this message translates to:
  /// **'Monthly limit set successfully'**
  String get monthlyLimitSet;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @setMonthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Set Your Monthly Limit'**
  String get setMonthlyLimit;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get used;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid Amount'**
  String get invalidAmount;

  /// No description provided for @montlyLimitSetter.
  ///
  /// In en, this message translates to:
  /// **'Montly limit set at: '**
  String get montlyLimitSetter;

  /// No description provided for @sar.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get sar;

  /// No description provided for @noDataMonth.
  ///
  /// In en, this message translates to:
  /// **'No Data Month'**
  String get noDataMonth;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @transactionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Transaction updated successfully'**
  String get transactionUpdated;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTransaction;

  /// No description provided for @areYouSureDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get areYouSureDelete;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @getAdvice.
  ///
  /// In en, this message translates to:
  /// **'Get AI Advice'**
  String get getAdvice;

  /// No description provided for @aiFinancialAdvice.
  ///
  /// In en, this message translates to:
  /// **'AI Financial Advice'**
  String get aiFinancialAdvice;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @limit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get limit;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @personalizedAdvice.
  ///
  /// In en, this message translates to:
  /// **'Personalized Advice'**
  String get personalizedAdvice;

  /// No description provided for @noAdvice.
  ///
  /// In en, this message translates to:
  /// **'No advice'**
  String get noAdvice;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(Object error);

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error With Message'**
  String get errorWithMessage;

  /// No description provided for @financialAdviceTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Financial Advice'**
  String get financialAdviceTitle;

  /// No description provided for @copyAdvice.
  ///
  /// In en, this message translates to:
  /// **'Copy Advice'**
  String get copyAdvice;

  /// No description provided for @adviceCopied.
  ///
  /// In en, this message translates to:
  /// **'Advice copied to clipboard'**
  String get adviceCopied;

  /// No description provided for @exportAsPdf.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get exportAsPdf;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @sex.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get sex;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @enterAge.
  ///
  /// In en, this message translates to:
  /// **'Enter your age'**
  String get enterAge;

  /// No description provided for @setGoals.
  ///
  /// In en, this message translates to:
  /// **'Set Investment Goals'**
  String get setGoals;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully!'**
  String get profileSaved;

  /// No description provided for @financialGoals.
  ///
  /// In en, this message translates to:
  /// **'Financial Goals'**
  String get financialGoals;

  /// No description provided for @goalType.
  ///
  /// In en, this message translates to:
  /// **'Goal Type'**
  String get goalType;

  /// No description provided for @retirement.
  ///
  /// In en, this message translates to:
  /// **'Retirement'**
  String get retirement;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @travel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travel;

  /// No description provided for @monthlyInvestment.
  ///
  /// In en, this message translates to:
  /// **'Monthly Investment'**
  String get monthlyInvestment;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @whatToBuy.
  ///
  /// In en, this message translates to:
  /// **'What do you want to buy?'**
  String get whatToBuy;

  /// No description provided for @timeframe.
  ///
  /// In en, this message translates to:
  /// **'Timeframe (months)'**
  String get timeframe;

  /// No description provided for @enterTimeframe.
  ///
  /// In en, this message translates to:
  /// **'Enter timeframe'**
  String get enterTimeframe;

  /// No description provided for @addGoal.
  ///
  /// In en, this message translates to:
  /// **'Add Goal'**
  String get addGoal;

  /// No description provided for @goalAdded.
  ///
  /// In en, this message translates to:
  /// **'Goal added!'**
  String get goalAdded;

  /// No description provided for @noGoals.
  ///
  /// In en, this message translates to:
  /// **'No goals added yet.'**
  String get noGoals;

  /// No description provided for @aiDisclaimerText.
  ///
  /// In en, this message translates to:
  /// **'This advice is generated by AI for informational purposes only. The developer is not responsible for any actions taken based on it.'**
  String get aiDisclaimerText;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @noDataAdvice.
  ///
  /// In en, this message translates to:
  /// **'Try adding some expenses to see reports.'**
  String get noDataAdvice;

  /// No description provided for @yourGoals.
  ///
  /// In en, this message translates to:
  /// **'Your Goals'**
  String get yourGoals;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @monthlyBudgetLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget Limit'**
  String get monthlyBudgetLimit;

  /// No description provided for @enterMonthlyLimitHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1000'**
  String get enterMonthlyLimitHint;

  /// No description provided for @limitLabel.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get limitLabel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @budgetsSaved.
  ///
  /// In en, this message translates to:
  /// **'Budgets saved'**
  String get budgetsSaved;

  /// No description provided for @replaceAll.
  ///
  /// In en, this message translates to:
  /// **'Replace All'**
  String get replaceAll;

  /// تحذير عندما لا يساوي الحد الشهري مجموع حدود الفئات
  ///
  /// In en, this message translates to:
  /// **'يجب أن يكون الحد الشهري ({monthly}) مساويًا لمجموع حدود جميع الفئات ({total}).'**
  String monthlyLimitValidation(Object monthly, Object total);

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// Confirmation message shown when deleting a category
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{categoryName}\"? All transactions belong to this category will be removed!'**
  String deleteCategoryConfirm(Object categoryName);

  /// No description provided for @categoryExists.
  ///
  /// In en, this message translates to:
  /// **'Category already exists'**
  String get categoryExists;

  /// No description provided for @incomeProtected.
  ///
  /// In en, this message translates to:
  /// **'The \"income\" category already exists and cannot be modified.'**
  String get incomeProtected;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'undo'**
  String get undo;

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category Deleted'**
  String get categoryDeleted;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'Days remaining tell end of the month.'**
  String get daysRemaining;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @fitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get fitness;

  /// No description provided for @bills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get bills;

  /// No description provided for @groceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get groceries;

  /// No description provided for @beauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get beauty;

  /// No description provided for @electronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get electronics;

  /// No description provided for @books.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get books;

  /// No description provided for @petCare.
  ///
  /// In en, this message translates to:
  /// **'Pet Care'**
  String get petCare;

  /// No description provided for @gifts.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get gifts;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @totalSavings.
  ///
  /// In en, this message translates to:
  /// **'totalSavings'**
  String get totalSavings;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SAr();
    case 'en':
      return SEn();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
