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
  /// **'Activity'**
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

  /// No description provided for @monthlyLimitSetter.
  ///
  /// In en, this message translates to:
  /// **'Monthly limit set at: '**
  String get monthlyLimitSetter;

  /// No description provided for @sar.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get sar;

  /// No description provided for @noDataMonth.
  ///
  /// In en, this message translates to:
  /// **'No Data For This Month'**
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
  /// **'Budgets Saved'**
  String get budgetsSaved;

  /// No description provided for @replaceAll.
  ///
  /// In en, this message translates to:
  /// **'Replace All'**
  String get replaceAll;

  /// Warning when monthly limit does not equal the sum of category limits
  ///
  /// In en, this message translates to:
  /// **'Monthly limit ({monthly}) must equal the sum of all category limits ({total}).'**
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
  /// **'Total Savings'**
  String get totalSavings;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @aboutAppDescription.
  ///
  /// In en, this message translates to:
  /// **'JaiBee is a simple and intuitive app for tracking your income and expenses. We aim to help you take control of your finances with ease.'**
  String get aboutAppDescription;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get developedBy;

  /// No description provided for @categoryBudgets.
  ///
  /// In en, this message translates to:
  /// **'Set Your Budget Per Category'**
  String get categoryBudgets;

  /// No description provided for @limitExceedsMonthly.
  ///
  /// In en, this message translates to:
  /// **'Limit Exceeds Monthly'**
  String get limitExceedsMonthly;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Valid Number'**
  String get enterValidNumber;

  /// No description provided for @invalidLimit.
  ///
  /// In en, this message translates to:
  /// **'Invalid Limit'**
  String get invalidLimit;

  /// No description provided for @invalidMonthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Invalid Monthly Limit'**
  String get invalidMonthlyLimit;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeletion;

  /// No description provided for @areYouSureDeleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get areYouSureDeleteTransaction;

  /// No description provided for @budgetDistribution.
  ///
  /// In en, this message translates to:
  /// **'Budget Distribution'**
  String get budgetDistribution;

  /// No description provided for @expectedDate.
  ///
  /// In en, this message translates to:
  /// **'Expected Date'**
  String get expectedDate;

  /// No description provided for @addNewGoal.
  ///
  /// In en, this message translates to:
  /// **'Add New Goal'**
  String get addNewGoal;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal Name'**
  String get goalName;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get targetAmount;

  /// No description provided for @savedAmount.
  ///
  /// In en, this message translates to:
  /// **'Saved Amount'**
  String get savedAmount;

  /// No description provided for @targetDate.
  ///
  /// In en, this message translates to:
  /// **'Target Date'**
  String get targetDate;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick Date'**
  String get pickDate;

  /// No description provided for @addMilestone.
  ///
  /// In en, this message translates to:
  /// **'Add Milestone'**
  String get addMilestone;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @savedMoreThanTarget.
  ///
  /// In en, this message translates to:
  /// **'Saved amount cannot exceed target amount'**
  String get savedMoreThanTarget;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Transaction Description (Optional).'**
  String get description;

  /// Message showing how much of the monthly budget has been allocated
  ///
  /// In en, this message translates to:
  /// **'You’ve allocated {allocated} of {total}.'**
  String budgetProgressInfo(double allocated, double total);

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network settings.'**
  String get noInternetConnection;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Jaibee'**
  String get welcomeTitle;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Take control of your finances with AI-powered insights.'**
  String get welcomeDescription;

  /// No description provided for @trackTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Your Spending'**
  String get trackTitle;

  /// No description provided for @trackDescription.
  ///
  /// In en, this message translates to:
  /// **'Easily record and review all your daily transactions.'**
  String get trackDescription;

  /// No description provided for @budgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Budgets and Goals'**
  String get budgetTitle;

  /// No description provided for @budgetDescription.
  ///
  /// In en, this message translates to:
  /// **'Stay on track by defining clear budgets and savings goals.'**
  String get budgetDescription;

  /// No description provided for @adviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart AI Advice'**
  String get adviceTitle;

  /// No description provided for @adviceDescription.
  ///
  /// In en, this message translates to:
  /// **'Get personalized financial tips based on your habits.'**
  String get adviceDescription;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get couldNotOpenLink;

  /// No description provided for @buyMeACoffee.
  ///
  /// In en, this message translates to:
  /// **'Buy me a coffee'**
  String get buyMeACoffee;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter a transaction description (optional).'**
  String get enterDescription;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No custom categories yet. You can add new categories from the app settings.'**
  String get noCategories;

  /// No description provided for @ofExpenses.
  ///
  /// In en, this message translates to:
  /// **'of Expenses'**
  String get ofExpenses;

  /// No description provided for @categoryProgress.
  ///
  /// In en, this message translates to:
  /// **'Category Progress'**
  String get categoryProgress;

  /// No description provided for @noLimitSet.
  ///
  /// In en, this message translates to:
  /// **'No limit set for this category.'**
  String get noLimitSet;

  /// No description provided for @ofLimit.
  ///
  /// In en, this message translates to:
  /// **'of Limit'**
  String get ofLimit;

  /// No description provided for @clickForMoreInfo.
  ///
  /// In en, this message translates to:
  /// **'Click for more info'**
  String get clickForMoreInfo;

  /// No description provided for @exportTransactionsAsPdf.
  ///
  /// In en, this message translates to:
  /// **'Export Transactions as PDF'**
  String get exportTransactionsAsPdf;

  /// No description provided for @pastDue.
  ///
  /// In en, this message translates to:
  /// **'Past Due'**
  String get pastDue;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'Days Left'**
  String get daysLeft;

  /// No description provided for @categoryDistribution.
  ///
  /// In en, this message translates to:
  /// **'Category Distribution'**
  String get categoryDistribution;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @savedAmountExceedsTarget.
  ///
  /// In en, this message translates to:
  /// **'Saved amount cannot exceed target amount'**
  String get savedAmountExceedsTarget;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get editGoal;

  /// Confirmation message shown when deleting a goal
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this goal? All progress will be lost.'**
  String get deleteGoalConfirmation;

  /// No description provided for @deleteGoal.
  ///
  /// In en, this message translates to:
  /// **'Delete Goal'**
  String get deleteGoal;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @mostSpentCategories.
  ///
  /// In en, this message translates to:
  /// **'Most Spent Categories'**
  String get mostSpentCategories;

  /// No description provided for @goalDeleted.
  ///
  /// In en, this message translates to:
  /// **'Goal deleted successfully'**
  String get goalDeleted;

  /// No description provided for @goalAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Goal added successfully'**
  String get goalAddedSuccessfully;

  /// No description provided for @categoryAdded.
  ///
  /// In en, this message translates to:
  /// **'Category added successfully'**
  String get categoryAdded;

  /// No description provided for @amountToReachMonthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Amount to reach monthly limit'**
  String get amountToReachMonthlyLimit;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @expensesByPeriod.
  ///
  /// In en, this message translates to:
  /// **'Expenses By Period'**
  String get expensesByPeriod;

  /// No description provided for @supportAndFeedback.
  ///
  /// In en, this message translates to:
  /// **'Support and Feedback'**
  String get supportAndFeedback;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @couldNotOpenSupportPage.
  ///
  /// In en, this message translates to:
  /// **'Could not open the support page'**
  String get couldNotOpenSupportPage;

  /// No description provided for @couldNotLaunchEmailClient.
  ///
  /// In en, this message translates to:
  /// **'Could not launch email client'**
  String get couldNotLaunchEmailClient;

  /// No description provided for @usDollar.
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get usDollar;

  /// No description provided for @euro.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get euro;

  /// No description provided for @saudiRiyal.
  ///
  /// In en, this message translates to:
  /// **'Saudi Riyal'**
  String get saudiRiyal;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @monthlyExpenses.
  ///
  /// In en, this message translates to:
  /// **'Monthly Expenses'**
  String get monthlyExpenses;

  /// No description provided for @clickToSeeAllCategoriesInfo.
  ///
  /// In en, this message translates to:
  /// **'Click to see all categories'**
  String get clickToSeeAllCategoriesInfo;

  /// No description provided for @filterByRange.
  ///
  /// In en, this message translates to:
  /// **'Filter By Range'**
  String get filterByRange;

  /// No description provided for @clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearFilter;

  /// No description provided for @chooseDateRange.
  ///
  /// In en, this message translates to:
  /// **'Choose Date Range'**
  String get chooseDateRange;

  /// No description provided for @currencyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Currency updated successfully'**
  String get currencyUpdated;

  /// No description provided for @goalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Goal updated successfully'**
  String get goalUpdated;

  /// No description provided for @categoryLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'Transaction added, but you have exceeded the category limit '**
  String get categoryLimitExceeded;

  /// No description provided for @pleaseSetLimitForCategory.
  ///
  /// In en, this message translates to:
  /// **'Please set a limit for this category.'**
  String get pleaseSetLimitForCategory;

  /// No description provided for @incomeAndExpenseSelected.
  ///
  /// In en, this message translates to:
  /// **'Income and Expense Selected'**
  String get incomeAndExpenseSelected;

  /// No description provided for @onlyIncomeSelected.
  ///
  /// In en, this message translates to:
  /// **'Only Income Selected'**
  String get onlyIncomeSelected;

  /// No description provided for @onlyExpenseSelected.
  ///
  /// In en, this message translates to:
  /// **'Only Expense Selected'**
  String get onlyExpenseSelected;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @feedbackSent.
  ///
  /// In en, this message translates to:
  /// **'Feedback Sent'**
  String get feedbackSent;

  /// No description provided for @couldNotSendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Could Not Send Feedback'**
  String get couldNotSendFeedback;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @optionalNameEmailNote.
  ///
  /// In en, this message translates to:
  /// **'Name and email are optional, but if you include them, we can follow up to help you better.'**
  String get optionalNameEmailNote;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @appFeatures.
  ///
  /// In en, this message translates to:
  /// **'App Features'**
  String get appFeatures;

  /// No description provided for @infoAndLegal.
  ///
  /// In en, this message translates to:
  /// **'Info & Legal'**
  String get infoAndLegal;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @setDailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Set Daily Reminder'**
  String get setDailyReminder;

  /// No description provided for @reminderSetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder set successfully!'**
  String get reminderSetSuccess;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @totalExpensesInCategory.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses In Category '**
  String get totalExpensesInCategory;

  /// No description provided for @budgetSummary.
  ///
  /// In en, this message translates to:
  /// **'Budget Summary'**
  String get budgetSummary;

  /// No description provided for @monthlyLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get monthlyLimitLabel;

  /// No description provided for @allocatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Allocated'**
  String get allocatedLabel;

  /// No description provided for @remainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remainingLabel;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get monthlyBudget;

  /// No description provided for @enterAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmountHint;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @allocated.
  ///
  /// In en, this message translates to:
  /// **'Allocated'**
  String get allocated;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @overBudgetWarning.
  ///
  /// In en, this message translates to:
  /// **'You are over your budget!'**
  String get overBudgetWarning;

  /// No description provided for @budgetScreenFooter.
  ///
  /// In en, this message translates to:
  /// **'Tip: Adjust your limits anytime to stay on track!'**
  String get budgetScreenFooter;

  /// No description provided for @summaryHint.
  ///
  /// In en, this message translates to:
  /// **'Allocated should match your monthly limit.'**
  String get summaryHint;

  /// No description provided for @allocateToCategories.
  ///
  /// In en, this message translates to:
  /// **'Distribute your monthly limit across categories.'**
  String get allocateToCategories;

  /// No description provided for @setYourMonthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Set your total spending limit for the month.'**
  String get setYourMonthlyLimit;

  /// No description provided for @monthlyLimitAuto.
  ///
  /// In en, this message translates to:
  /// **'Your monthly limit is the sum of all category limits below.'**
  String get monthlyLimitAuto;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @cannotSelectFutureTime.
  ///
  /// In en, this message translates to:
  /// **'Cannot select future time'**
  String get cannotSelectFutureTime;

  /// No description provided for @addIncome.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addIncome;
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
