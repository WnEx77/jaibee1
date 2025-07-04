import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:jaibee/l10n/s.dart';
import 'package:jaibee/main.dart';
// import 'package:jaibee/features/goals/goals_screen.dart';
import 'package:jaibee/features/about/about_us_screen.dart';
import 'package:jaibee/features/webview/webview_screen.dart';
import 'package:jaibee/core/theme/theme_provider.dart';
import 'package:jaibee/shared/widgets/app_background.dart';
import 'package:jaibee/features/reports/export_report_screen.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:jaibee/features/about/privacy_policy_screen.dart';
import 'package:jaibee/core/utils/currency_utils.dart';
import 'package:jaibee/features/about/terms_of_service_screen.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/mint_jade_theme.dart';
import '../../core/services/notification_service.dart';
import 'package:jaibee/shared/widgets/global_time_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_settings/app_settings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _goalsController = TextEditingController();

  bool _isReminderEnabled = false;
  TimeOfDay? _reminderTime;
  bool _notificationGranted = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadReminderStatus();
    _loadReminderTime();
  }

  void _loadReminderStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('isReminderEnabled') ?? false;

    setState(() {
      _isReminderEnabled = isEnabled;
      _notificationGranted = isEnabled; // إذا تم تفعيلها، نفترض أن الإذن موجود
    });
  }

  Future<void> _loadReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('reminder_hour');
    final minute = prefs.getInt('reminder_minute');

    if (hour != null && minute != null) {
      setState(() {
        _reminderTime = TimeOfDay(hour: hour, minute: minute);
      });
    }
  }

  void _toggleReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value) {
      final granted = await NotificationService.requestPermission();

      if (granted) {
        await prefs.setBool('isReminderEnabled', true);
        setState(() {
          _notificationGranted = true;
          _isReminderEnabled = true;
        });
      } else {
        await prefs.setBool('isReminderEnabled', false);
        setState(() {
          _notificationGranted = false;
          _isReminderEnabled = false;
        });

        if (context.mounted) {
          _showNotificationSettingsDialog(context, S.of(context)!);
        }
      }
    } else {
      await prefs.setBool('isReminderEnabled', false);
      NotificationService.cancelDailyReminder();
      setState(() {
        _isReminderEnabled = false;
        _reminderTime = null;
      });
    }
  }

  Future<void> _saveReminderTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    // نحفظ الساعة والدقيقة بشكل منفصل
    await prefs.setInt('reminder_hour', time.hour);
    await prefs.setInt('reminder_minute', time.minute);
  }

  void _showNotificationSettingsDialog(BuildContext context, S s) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      backgroundColor: Theme.of(context).cardColor,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_off_rounded,
                  size: 40,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 12),
                Text(
                  s.notificationsDisabled ?? 'Notifications Disabled',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  s.enableNotificationsInSettings ??
                      'To receive daily reminders, please enable notifications in your device settings.',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      AppSettings.openAppSettings(
                        type: AppSettingsType.notification,
                      );
                    },
                    child: Text(s.openSettings ?? 'Open Settings'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(s.cancel ?? 'Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _goalsController.text = prefs.getString('user_goals') ?? '';
    });
  }

  void _changeLanguage(String langCode) {
    JaibeeTrackerApp.setLocale(context, Locale(langCode));
  }

  void _showLanguageDialog() {
    final s = S.of(context)!;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                s.changeLanguage,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildLanguageOption(
                flag: '🇸🇦',
                language: s.arabic,
                onTap: () {
                  Navigator.pop(context);
                  _changeLanguage('ar');
                },
              ),
              const SizedBox(height: 10),
              _buildLanguageOption(
                flag: '🇺🇸',
                language: s.english,
                onTap: () {
                  Navigator.pop(context);
                  _changeLanguage('en');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String flag,
    required String language,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Text(language, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }

  void _launchBuyMeACoffee() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const InAppWebViewScreen(url: 'https://buymeacoffee.com/wnex77'),
      ),
    );
  }

  Future<void> _showCurrencyPicker(BuildContext context) async {
    final s = S.of(context)!;
    final prefs = await SharedPreferences.getInstance();
    String currentCode = prefs.getString('currency_code') ?? 'SAR';

    // Always show Saudi Riyal symbol with teal color
    final saudiRiyal = supportedCurrencies.firstWhere(
      (c) => c.code == 'SAR',
      orElse: () => supportedCurrencies.first,
    );
    final saudiAsset = saudiRiyal.getAsset(
      isDarkMode: Theme.of(context).brightness == Brightness.dark,
    );

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (saudiAsset != null)
                  Image.asset(
                    saudiAsset,
                    width: 52,
                    height: 52,
                    color: Colors.teal,
                  )
                else
                  Icon(Icons.attach_money, size: 52, color: Colors.teal),
                const SizedBox(height: 12),
                Text(
                  s.selectCurrency,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ...supportedCurrencies.map(
                  (currency) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: _buildCurrencyOption(
                      currency: currency,
                      isSelected: currentCode == currency.code,
                      onTap: () async {
                        await prefs.setString('currency_code', currency.code);
                        Navigator.pop(context);
                        setState(() {}); // Refresh UI
                        // Show flushbar after currency update
                        Flushbar(
                          message: s.currencyUpdated,
                          duration: const Duration(seconds: 2),
                          backgroundColor: Colors.green,
                          margin: const EdgeInsets.all(16),
                          borderRadius: BorderRadius.circular(12),
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                        ).show(context);
                      },
                      // Localize currency name:
                      localizedName: _getLocalizedCurrencyName(currency, s),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyOption({
    required AppCurrency currency,
    required bool isSelected,
    required VoidCallback onTap,
    String? localizedName,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = currency.getAsset(isDarkMode: isDark);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.secondary.withOpacity(0.15)
              : Theme.of(context).colorScheme.secondary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              asset != null
                  ? Image.asset(asset, width: 22, height: 22)
                  : Text(currency.symbol, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Text(
                localizedName ?? '${currency.name} (${currency.code})',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check, color: Colors.teal, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper to localize currency names
  String _getLocalizedCurrencyName(AppCurrency currency, S s) {
    switch (currency.code) {
      case 'SAR':
        return s.saudiRiyal;
      case 'USD':
        return s.usDollar;
      case 'EUR':
        return s.euro;
      default:
        return '${currency.name} (${currency.code})';
    }
  }

  Future<Widget> buildCurrencySymbolWidget(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('currency_code') ?? 'SAR';
    final currency = getCurrencyByCode(code);

    // Use theme from context for dark mode
    // final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = currency.getAsset();
    if (asset != null) {
      return Image.asset(asset, width: 26, height: 26, color: Colors.teal);
    } else {
      return Text(
        currency.symbol,
        style: const TextStyle(fontSize: 26, color: Colors.teal),
      );
    }
  }

  void _showFeedbackForm() {
    final s = S.of(context)!;
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _messageController = TextEditingController();
    final mintJadeColors = Theme.of(context).extension<MintJadeColors>()!;

    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.feedback,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.supportAndFeedback,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: s.name,
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: s.email,
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.optionalNameEmailNote, // Localized string like: "Name and email are optional, but they help us reach you if we need more details."
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: s.message,
                      alignLabelWithHint: true,
                      prefixIcon: const Icon(Icons.message),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.close, color: Colors.white),
                          label: Text(
                            s.cancel,
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(
                            isLoading ? s.sending : s.send,
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mintJadeColors.buttonColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final name = _nameController.text.trim();
                                  final email = _emailController.text.trim();
                                  final message = _messageController.text
                                      .trim();
                                  if (message.isEmpty) return;

                                  setState(() => isLoading = true);

                                  final formUrl =
                                      "https://docs.google.com/forms/d/e/1FAIpQLSc2jr5yYVYnK9Oxh6AWKvp8yo9m6f50ct_ydlb_J_jDJ8375g/formResponse";
                                  final Map<String, String> body = {
                                    "entry.257464318": name,
                                    "entry.737850348": email,
                                    "entry.1968950375": message,
                                  };

                                  try {
                                    await http.post(
                                      Uri.parse(formUrl),
                                      body: body,
                                    );
                                    Navigator.pop(context);
                                    Flushbar(
                                      message: s.feedbackSent,
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: Colors.green,
                                      margin: const EdgeInsets.all(16),
                                      borderRadius: BorderRadius.circular(12),
                                      icon: const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                    ).show(context);
                                  } catch (e) {
                                    Navigator.pop(context);
                                    Flushbar(
                                      message: s.couldNotSendFeedback,
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: Colors.redAccent,
                                      margin: const EdgeInsets.all(16),
                                      borderRadius: BorderRadius.circular(12),
                                      icon: const Icon(
                                        Icons.error_outline,
                                        color: Colors.white,
                                      ),
                                    ).show(context);
                                  } finally {
                                    setState(() => isLoading = false);
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;

    return Scaffold(
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              _buildSectionCard(
                title: s.generalSettings,
                children: [
                  _buildCardTile(
                    icon: Icons.language_outlined,
                    label: s.changeLanguage,
                    onTap: _showLanguageDialog,
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Image.asset(
                        'assets/images/Saudi_Riyal_Symbol.png',
                        width: 26,
                        height: 26,
                        color: Colors.teal,
                      ),
                    ),
                    title: Text(
                      s.currency,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () => _showCurrencyPicker(context),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minLeadingWidth: 0,
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: const Icon(
                      Icons.dark_mode_outlined,
                      color: Colors.blueGrey,
                    ),
                    title: Text(
                      s.darkMode,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    trailing: Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return Switch(
                          value: themeProvider.isDarkTheme,
                          onChanged: themeProvider.toggleTheme,
                        );
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minLeadingWidth: 0,
                  ),
                ],
              ),

              _buildSectionCard(
                title: s.appFeatures,
                children: [
                  _buildCardTile(
                    icon: Icons.alarm,
                    label: s.setDailyReminder,
                    trailing: Switch(
                      value: _isReminderEnabled,
                      onChanged: _toggleReminder,
                    ),
                    onTap: () {},
                  ),

                  if (_isReminderEnabled && _notificationGranted)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.pickReminderTime,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.teal[700],
                                ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final pickedTime =
                                  await showGlobalCupertinoTimePicker(
                                    context: context,
                                    initialTime:
                                        _reminderTime ?? TimeOfDay.now(),
                                  );
                              if (pickedTime != null) {
                                await NotificationService.scheduleDailyReminder(
                                  context,
                                  pickedTime,
                                );
                                await _saveReminderTime(pickedTime);
                                setState(() {
                                  _reminderTime = pickedTime;
                                });

                                if (context.mounted) {
                                  Flushbar(
                                    message: s.reminderSetSuccess,
                                    flushbarPosition: FlushbarPosition.BOTTOM,
                                    margin: const EdgeInsets.all(8),
                                    borderRadius: BorderRadius.circular(8),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: Colors.green,
                                    icon: const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.white,
                                    ),
                                  ).show(context);
                                }
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 18,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.teal.withOpacity(0.18)
                                    : Colors.teal.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.teal,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _reminderTime != null
                                        ? s.reminderLabel(
                                            _reminderTime!.format(context),
                                          )
                                        : s.pickReminderTime,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.teal[100]
                                              : Colors.teal[900],
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Icon(
                                    Icons.access_time,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.teal[100]
                                        : Colors.teal,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  _buildDivider(),
                  // _buildCardTile(
                  //   icon: Icons.flag_outlined,
                  //   label: s.setGoals,
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (_) => const GoalsScreen()),
                  //     );
                  //   },
                  // ),
                  // _buildDivider(),
                  _buildCardTile(
                    icon: Icons.picture_as_pdf_outlined,
                    label: s.exportTransactionsAsPdf,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ExportReportScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              _buildSectionCard(
                title: s.infoAndLegal,
                children: [
                  _buildCardTile(
                    icon: Icons.info_outline,
                    label: s.aboutUs,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AboutUsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildCardTile(
                    icon: Icons.privacy_tip_outlined,
                    label: s.privacyPolicy,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildCardTile(
                    icon: Icons.description_outlined,
                    label: s.termsOfService,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TermsOfServiceScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              _buildSectionCard(
                title: s.support,
                children: [
                  _buildCardTile(
                    icon: Icons.support_agent_outlined,
                    label: s.supportAndFeedback,
                    onTap:
                        _showFeedbackForm, // Combine contact and support here
                  ),
                  _buildDivider(),
                  _buildCardTile(
                    icon: Icons.local_cafe_outlined,
                    label: s.buyMeACoffee,
                    onTap: _launchBuyMeACoffee,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(children: children),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCardTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing, // براميتر اختياري جديد
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal, size: 28),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      trailing:
          trailing ??
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minLeadingWidth: 0,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 0,
        thickness: 0.7,
        color: Colors.grey.withOpacity(0.18),
      ),
    );
  }
}
