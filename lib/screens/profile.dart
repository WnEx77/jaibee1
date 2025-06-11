import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jaibee1/screens/goals_screen.dart';
import 'package:jaibee1/l10n/s.dart'; // localization import

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _selectedSex;
  int? _age;
  final TextEditingController _goalsController = TextEditingController();

  final List<String> _sexOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSex = prefs.getString('user_sex');
      _age = prefs.getInt('user_age');
      _goalsController.text = prefs.getString('user_goals') ?? '';
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_sex', _selectedSex ?? '');
    await prefs.setInt('user_age', _age ?? 0);
    await prefs.setString('user_goals', _goalsController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context)!.profileSaved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.profileTitle),
        backgroundColor: const Color.fromARGB(255, 130, 148, 179),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.personalInfo,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // Sex Dropdown
                    Text(s.sex, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedSex,
                      items: _sexOptions.map((sex) {
                        return DropdownMenuItem(value: sex, child: Text(sex));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSex = value;
                        });
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Age Input
                    Text(s.age, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextFormField(
                      initialValue: _age?.toString(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.cake),
                        border: const OutlineInputBorder(),
                        hintText: s.enterAge,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _age = int.tryParse(value);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Set Goals Button
            ElevatedButton.icon(
              icon: const Icon(Icons.flag),
              label: Text(s.setGoals),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GoalsScreen()),
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
                backgroundColor: const Color.fromARGB(255, 130, 148, 179),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
