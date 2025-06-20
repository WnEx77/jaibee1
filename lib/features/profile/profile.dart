import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jaibee1/features/goals/goals_screen.dart';
import 'package:jaibee1/l10n/s.dart';
// import 'package:intl/intl.dart';
import 'package:jaibee1/main.dart';
import 'package:jaibee1/shared/widgets/app_background.dart'; // Your background widget
import 'package:provider/provider.dart'; // For ThemeProvider
import 'package:jaibee1/features/about/about_us_screen.dart';
// import 'package:jaibee1/widgets/custom_app_bar.dart'; // Import your global CustomAppBar
import 'package:jaibee1/core/theme/mint_jade_theme.dart';
// import 'package:jaibee1/app.dart';
import 'package:jaibee1/core/theme/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jaibee1/features/webview/webview_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _selectedSex;
  DateTime? _birthDate;
  final TextEditingController _goalsController = TextEditingController();

  // final List<String> _sexOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSex = prefs.getString('user_sex');
      final dobString = prefs.getString('user_birthdate');
      if (dobString != null) {
        _birthDate = DateTime.tryParse(dobString);
      }
      _goalsController.text = prefs.getString('user_goals') ?? '';
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_sex', _selectedSex ?? '');
    if (_birthDate != null) {
      await prefs.setString('user_birthdate', _birthDate!.toIso8601String());
    }
    await prefs.setString('user_goals', _goalsController.text);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(S.of(context)!.profileSaved)));
  }

  // int? _calculateAge(DateTime? birthDate) {
  //   if (birthDate == null) return null;
  //   final today = DateTime.now();
  //   int age = today.year - birthDate.year;
  //   if (birthDate.month > today.month ||
  //       (birthDate.month == today.month && birthDate.day > today.day)) {
  //     age--;
  //   }
  //   return age;
  // }

  // Future<void> _selectBirthDate() async {
  //   final now = DateTime.now();
  //   final initialDate = _birthDate ?? DateTime(now.year - 20);
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: initialDate,
  //     firstDate: DateTime(1900),
  //     lastDate: now,
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       _birthDate = picked;
  //     });
  //   }
  // }

  void _changeLanguage(String langCode) {
    Locale newLocale = Locale(langCode);
    JaibeeTrackerApp.setLocale(context, newLocale);
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.of(context)!.changeLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('🇺🇸 English'),
              onTap: () {
                Navigator.pop(context);
                JaibeeTrackerApp.setLocale(context, const Locale('en'));
              },
            ),
            ListTile(
              title: const Text('🇸🇦 العربية'),
              onTap: () {
                Navigator.pop(context);
                JaibeeTrackerApp.setLocale(context, const Locale('ar'));
              },
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final mintTheme = Theme.of(context).extension<MintJadeColors>()!;

    return Scaffold(
      // appBar: CustomAppBar(
      //   title: s.profileTitle,
      //   // showBackButton: true,
      // ),
      body: AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Sex Dropdown
              // Card(
              //   elevation: 4,
              //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              //   child: Padding(
              //     padding: const EdgeInsets.all(16),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(s.personalInfo, style: Theme.of(context).textTheme.titleMedium),
              //         const SizedBox(height: 16),

              //         Text(s.sex, style: const TextStyle(fontWeight: FontWeight.w600)),
              //         const SizedBox(height: 6),
              //         DropdownButtonFormField<String>(
              //           value: _selectedSex,
              //           items: _sexOptions.map((sex) {
              //             return DropdownMenuItem(value: sex, child: Text(sex));
              //           }).toList(),
              //           onChanged: (value) {
              //             setState(() {
              //               _selectedSex = value;
              //             });
              //           },
              //           decoration: const InputDecoration(
              //             prefixIcon: Icon(Icons.person),
              //             border: OutlineInputBorder(),
              //           ),
              //         ),
              //         const SizedBox(height: 16),

              //         // Date of Birth Picker
              //         Text(s.birthDate, style: const TextStyle(fontWeight: FontWeight.w600)),
              //         const SizedBox(height: 6),
              //         GestureDetector(
              //           onTap: _selectBirthDate,
              //           child: AbsorbPointer(
              //             child: TextFormField(
              //               decoration: InputDecoration(
              //                 hintText: s.enterAge,
              //                 prefixIcon: const Icon(Icons.calendar_today),
              //                 border: const OutlineInputBorder(),
              //               ),
              //               controller: TextEditingController(
              //                 text: _birthDate != null
              //                     ? DateFormat('yyyy-MM-dd').format(_birthDate!)
              //                     : '',
              //               ),
              //             ),
              //           ),
              //         ),

              //         if (_birthDate != null)
              //           Padding(
              //             padding: const EdgeInsets.only(top: 8),
              //             child: Text(
              //               '${s.age}: ${_calculateAge(_birthDate)}',
              //               style: const TextStyle(color: Colors.grey),
              //             ),
              //           ),
              //       ],
              //     ),
              //   ),
              // ),
              const SizedBox(height: 20),

              // Language Selection
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.language, color: Colors.blueGrey),
                  title: Text(s.changeLanguage),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showLanguageDialog,
                ),
              ),

              const SizedBox(height: 20),

              // Dark Mode Toggle
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.brightness_6,
                    color: Colors.blueGrey,
                  ),
                  title: Text(s.darkMode),
                  trailing: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return Switch(
                        value: themeProvider.isDarkTheme,
                        onChanged: (val) {
                          themeProvider.toggleTheme(val);
                        },
                      );
                    },
                  ),
                ),
              ),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.account_circle_outlined,
                    color: Colors.blueGrey,
                  ),
                  title: Text(s.aboutUs),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutUsScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Set Goals Button
              ElevatedButton.icon(
                icon: const Icon(Icons.flag),
                label: Text(s.setGoals),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mintTheme.unselectedIconColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GoalsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Save Profile Button
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                onPressed: _saveProfile,
                label: Text(s.saveProfile),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mintTheme.buttonColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                icon: Image.asset(
                  'assets/images/buy-me-a-coffee.png',
                  height: 30,
                  width: 30,
                ),
                label: Text(S.of(context)!.buyMeACoffee),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _launchBuyMeACoffee,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
