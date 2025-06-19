# Jaibee

Jaibee is a Flutter-based personal finance tracking app designed to help users manage their expenses, budgets, and financial goals effectively. It supports multiple languages, dark/light themes, and provides insightful reports.

---

## Features

- Track your transactions easily
- Manage budgets and financial goals
- Categorize expenses with customizable categories
- View detailed reports with charts and summaries
- Localization support with multiple languages
- Light and dark theme support
- Persistent data storage using Hive local database

---

## Screenshots

//

---

## Getting Started

### Prerequisites

- Flutter SDK >= 3.0
- Dart SDK
- Android Studio or VSCode with Flutter plugin
- Hive dependencies (already included in `pubspec.yaml`)

### Installation

1. Clone the repo:

```bash
git clone https://github.com/wnex77/jaibee.git
cd jaibee
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

---

## Architecture & Tools

- **Flutter** for UI
- **Provider** for state management
- **Hive** for local data storage
- **Flutter localization** with generated `S` files for translations
- Custom theming using Flutter's ThemeExtension

---

## Project Structure

```
lib/
├── core/
│   ├── theme/          # ThemeProvider, MintJadeColors, theming utils
├── data/
│   ├── models/         # Hive models (Transaction, Category, Budget, Goal)
├── features/
│   ├── home/           # Main app screen & navigation
│   ├── transactions/   # Transactions add/edit/view screens
│   ├── reports/        # Reports and charts
│   ├── profile/        # User profile settings
│   ├── budget/         # Budget management
├── l10n/               # Localization generated files
├── shared/             # Shared widgets and helpers
main.dart               # App entry point, Hive initialization
```

---

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Contact

- Developed by Abdulrahman  
- Email: amoharib77@gmail.com  
- GitHub: [https://github.com/wnex77](https://github.com/wnex77)

---

## Acknowledgements

- Flutter community  
- Hive database  
- Month Year Picker package