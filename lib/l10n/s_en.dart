// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Jaibee';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get transactions => 'Activity';

  @override
  String get reports => 'Reports';

  @override
  String get amount => 'Amount';

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get category => 'Category';

  @override
  String get food => 'Food';

  @override
  String get transportation => 'Transportation';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get coffee => 'Coffee';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get date => 'Date';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get transactionAdded => 'Transaction added';

  @override
  String get noTransactions => 'No Transactions Yet';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get totalExpenses => 'Total Expenses';

  @override
  String get balance => 'Balance';

  @override
  String get customizeCategories => 'Customize Categories';

  @override
  String get newCategory => 'New Category';

  @override
  String get reportTitle => 'Expense Report';

  @override
  String get dailyExpenses => 'Daily Expenses';

  @override
  String get filter => 'Filter';

  @override
  String get averageDaily => 'Average Daily Expense';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get selectPeriod => 'Select Period';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get applyFilter => 'Apply Filter';

  @override
  String get cancel => 'Cancel';

  @override
  String get addQuickTransaction => 'Add Quick Transaction';

  @override
  String get filterTransactions => 'Filter The Transactions';

  @override
  String get ok => 'Ok';

  @override
  String get monthlyLimit => 'Monthly Limit';

  @override
  String get monthlyLimitSet => 'Monthly limit set successfully';

  @override
  String get filters => 'Filters';

  @override
  String get spent => 'Spent';

  @override
  String get setMonthlyLimit => 'Set Your Monthly Limit';

  @override
  String get used => 'Used';

  @override
  String get invalidAmount => 'Invalid Amount';

  @override
  String get monthlyLimitSetter => 'Monthly limit set at: ';

  @override
  String get sar => 'SAR';

  @override
  String get noDataMonth => 'No Data For This Month';

  @override
  String get allTime => 'All Time';

  @override
  String get monthly => 'Monthly';

  @override
  String get other => 'Other';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get transactionUpdated => 'Transaction updated successfully';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get deleteTransaction => 'Delete';

  @override
  String get delete => 'Delete';

  @override
  String get getAdvice => 'Get AI Advice';

  @override
  String get aiFinancialAdvice => 'AI Financial Advice';

  @override
  String get expenses => 'Expenses';

  @override
  String get limit => 'Limit';

  @override
  String get notSet => 'Not set';

  @override
  String get personalizedAdvice => 'Personalized Advice';

  @override
  String get noAdvice => 'No advice';

  @override
  String get errorWithMessage => 'Error With Message';

  @override
  String get financialAdviceTitle => 'AI Financial Advice';

  @override
  String get copyAdvice => 'Copy Advice';

  @override
  String get adviceCopied => 'Advice copied to clipboard';

  @override
  String get exportAsPdf => 'Export as PDF';

  @override
  String get profile => 'Profile';

  @override
  String get profileTitle => 'Profile';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get sex => 'Gender';

  @override
  String get age => 'Age';

  @override
  String get enterAge => 'Enter your age';

  @override
  String get setGoals => 'Set Investment Goals';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get profileSaved => 'Profile saved successfully!';

  @override
  String get financialGoals => 'Financial Goals';

  @override
  String get goalType => 'Goal Type';

  @override
  String get retirement => 'Retirement';

  @override
  String get education => 'Education';

  @override
  String get home => 'Home';

  @override
  String get travel => 'Travel';

  @override
  String get monthlyInvestment => 'Monthly Investment';

  @override
  String get enterAmount => 'Enter amount';

  @override
  String get whatToBuy => 'What do you want to buy?';

  @override
  String get timeframe => 'Timeframe (months)';

  @override
  String get enterTimeframe => 'Enter timeframe';

  @override
  String get addGoal => 'Add Goal';

  @override
  String get goalAdded => 'Goal added!';

  @override
  String get noGoals => 'No goals added yet.';

  @override
  String get aiDisclaimerText =>
      'This advice is generated by AI for informational purposes only. The developer is not responsible for any actions taken based on it.';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get noDataAdvice => 'Try adding some expenses to see reports.';

  @override
  String get yourGoals => 'Your Goals';

  @override
  String get budgets => 'Budgets';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get monthlyBudgetLimit => 'Monthly Budget Limit';

  @override
  String get enterMonthlyLimitHint => 'e.g. 1000';

  @override
  String get limitLabel => 'Limit';

  @override
  String get save => 'Save';

  @override
  String get budgetsSaved => 'Budgets Saved';

  @override
  String get replaceAll => 'Replace All';

  @override
  String monthlyLimitValidation(Object monthly, Object total) {
    return 'Monthly limit ($monthly) must equal the sum of all category limits ($total).';
  }

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get addCategory => 'Add Category';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String deleteCategoryConfirm(Object categoryName) {
    return 'Are you sure you want to delete \"$categoryName\"? All transactions belong to this category will be removed!';
  }

  @override
  String get categoryExists => 'Category already exists';

  @override
  String get incomeProtected =>
      'The \"income\" category already exists and cannot be modified.';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get undo => 'undo';

  @override
  String get categoryDeleted => 'Category Deleted';

  @override
  String get daysRemaining => 'Days remaining tell end of the month.';

  @override
  String get shopping => 'Shopping';

  @override
  String get health => 'Health';

  @override
  String get transport => 'Transport';

  @override
  String get fitness => 'Fitness';

  @override
  String get bills => 'Bills';

  @override
  String get groceries => 'Groceries';

  @override
  String get beauty => 'Beauty';

  @override
  String get electronics => 'Electronics';

  @override
  String get books => 'Books';

  @override
  String get petCare => 'Pet Care';

  @override
  String get gifts => 'Gifts';

  @override
  String get savings => 'Savings';

  @override
  String get events => 'Events';

  @override
  String get totalSavings => 'Total Savings';

  @override
  String get aboutUs => 'About Us';

  @override
  String get aboutAppDescription =>
      'JaiBee is a simple and intuitive app for tracking your income and expenses. We aim to help you take control of your finances with ease.';

  @override
  String get developedBy => 'Developed by';

  @override
  String get categoryBudgets => 'Set Your Budget Per Category';

  @override
  String get limitExceedsMonthly => 'Limit Exceeds Monthly';

  @override
  String get enterValidNumber => 'Enter Valid Number';

  @override
  String get invalidLimit => 'Invalid Limit';

  @override
  String get invalidMonthlyLimit => 'Invalid Monthly Limit';

  @override
  String get confirmDeletion => 'Confirm Deletion';

  @override
  String get areYouSureDeleteTransaction =>
      'Are you sure you want to delete this transaction?';

  @override
  String get budgetDistribution => 'Budget Distribution';

  @override
  String get expectedDate => 'Expected Date';

  @override
  String get addNewGoal => 'Add New Goal';

  @override
  String get goalName => 'Goal Name';

  @override
  String get targetAmount => 'Target Amount';

  @override
  String get savedAmount => 'Saved Amount';

  @override
  String get targetDate => 'Target Date';

  @override
  String get pickDate => 'Pick Date';

  @override
  String get addMilestone => 'Add Milestone';

  @override
  String get required => 'Required';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String get savedMoreThanTarget => 'Saved amount cannot exceed target amount';

  @override
  String get description => 'Transaction Description (Optional).';

  @override
  String budgetProgressInfo(double allocated, double total) {
    return 'You’ve allocated $allocated of $total.';
  }

  @override
  String get noInternetConnection =>
      'No internet connection. Please check your network settings.';

  @override
  String get retry => 'Retry';

  @override
  String get welcomeTitle => 'Welcome to Jaibee';

  @override
  String get welcomeDescription =>
      'Take control of your finances with AI-powered insights.';

  @override
  String get trackTitle => 'Track Your Spending';

  @override
  String get trackDescription =>
      'Easily record and review all your daily transactions.';

  @override
  String get budgetTitle => 'Set Budgets and Goals';

  @override
  String get budgetDescription =>
      'Stay on track by defining clear budgets and savings goals.';

  @override
  String get adviceTitle => 'Smart AI Advice';

  @override
  String get adviceDescription =>
      'Get personalized financial tips based on your habits.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get next => 'Next';

  @override
  String get couldNotOpenLink => 'Could not open the link';

  @override
  String get buyMeACoffee => 'Buy me a coffee';

  @override
  String get enterDescription =>
      'Please enter a transaction description (optional).';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get noCategories =>
      'No custom categories yet. You can add new categories from the app settings.';

  @override
  String get ofExpenses => 'of Expenses';

  @override
  String get categoryProgress => 'Category Progress';

  @override
  String get noLimitSet => 'No limit set for this category.';

  @override
  String get ofLimit => 'of Limit';

  @override
  String get clickForMoreInfo => 'Click for more info';

  @override
  String get exportTransactionsAsPdf => 'Export Transactions as PDF';

  @override
  String get pastDue => 'Past Due';

  @override
  String get target => 'Target';

  @override
  String get saved => 'Saved';

  @override
  String get goal => 'Goal';

  @override
  String get daysLeft => 'Days Left';

  @override
  String get categoryDistribution => 'Category Distribution';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get savedAmountExceedsTarget =>
      'Saved amount cannot exceed target amount';

  @override
  String get requiredField => 'This field is required';

  @override
  String get editGoal => 'Edit Goal';

  @override
  String get deleteGoalConfirmation =>
      'Are you sure you want to delete this goal? All progress will be lost.';

  @override
  String get deleteGoal => 'Delete Goal';

  @override
  String get done => 'Done';

  @override
  String get mostSpentCategories => 'Most Spent Categories';

  @override
  String get goalDeleted => 'Goal deleted successfully';

  @override
  String get goalAddedSuccessfully => 'Goal added successfully';

  @override
  String get categoryAdded => 'Category added successfully';

  @override
  String get amountToReachMonthlyLimit => 'Amount to reach monthly limit';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get expensesByPeriod => 'Expenses By Period';

  @override
  String get supportAndFeedback => 'Support and Feedback';

  @override
  String get currency => 'Currency';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get couldNotOpenSupportPage => 'Could not open the support page';

  @override
  String get couldNotLaunchEmailClient => 'Could not launch email client';

  @override
  String get usDollar => 'US Dollar';

  @override
  String get euro => 'Euro';

  @override
  String get saudiRiyal => 'Saudi Riyal';

  @override
  String get allCategories => 'All Categories';

  @override
  String get monthlyExpenses => 'Monthly Expenses';

  @override
  String get clickToSeeAllCategoriesInfo => 'Click to see all categories';

  @override
  String get filterByRange => 'Filter By Range';

  @override
  String get clearFilter => 'Clear';

  @override
  String get chooseDateRange => 'Choose Date Range';

  @override
  String get currencyUpdated => 'Currency updated successfully';

  @override
  String get goalUpdated => 'Goal updated successfully';

  @override
  String get categoryLimitExceeded =>
      'Transaction added, but you have exceeded the category limit ';

  @override
  String get pleaseSetLimitForCategory =>
      'Please set a limit for this category.';

  @override
  String get incomeAndExpenseSelected => 'Income and Expense Selected';

  @override
  String get onlyIncomeSelected => 'Only Income Selected';

  @override
  String get onlyExpenseSelected => 'Only Expense Selected';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get message => 'Message';

  @override
  String get send => 'Send';

  @override
  String get feedbackSent => 'Feedback Sent';

  @override
  String get couldNotSendFeedback => 'Could Not Send Feedback';

  @override
  String get sending => 'Sending...';

  @override
  String get optionalNameEmailNote =>
      'Name and email are optional, but if you include them, we can follow up to help you better.';

  @override
  String get generalSettings => 'General Settings';

  @override
  String get appFeatures => 'App Features';

  @override
  String get infoAndLegal => 'Info & Legal';

  @override
  String get support => 'Support';

  @override
  String get setDailyReminder => 'Set Daily Reminder';

  @override
  String get reminderSetSuccess => 'Daily reminder set successfully!';

  @override
  String get all => 'All';

  @override
  String get totalExpensesInCategory => 'Total Expenses In Category ';

  @override
  String get budgetSummary => 'Budget Summary';

  @override
  String get monthlyLimitLabel => 'Limit';

  @override
  String get allocatedLabel => 'Allocated';

  @override
  String get remainingLabel => 'Remaining';

  @override
  String get monthlyBudget => 'Monthly Budget';

  @override
  String get enterAmountHint => 'Enter amount';

  @override
  String get summary => 'Summary';

  @override
  String get allocated => 'Allocated';

  @override
  String get remaining => 'Remaining';

  @override
  String get overBudgetWarning => 'You are over your budget!';

  @override
  String get budgetScreenFooter =>
      'Tip: Adjust your limits anytime to stay on track!';

  @override
  String get summaryHint => 'Allocated should match your monthly limit.';

  @override
  String get allocateToCategories =>
      'Distribute your monthly limit across categories.';

  @override
  String get setYourMonthlyLimit =>
      'Set your total spending limit for the month.';

  @override
  String get monthlyLimitAuto =>
      'Your monthly limit is the sum of all category limits below.';
}
