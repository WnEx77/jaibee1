import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jaibee1/l10n/s.dart'; // Import localization
// import 'package:jaibee1/screens/BackgroundContainer.dart';



class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _monthlyInvestmentController = TextEditingController();
  final TextEditingController _itemToBuyController = TextEditingController();
  final TextEditingController _timeFrameController = TextEditingController();
  String? _goalType;

  List<Map<String, dynamic>> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final String? goalsJson = prefs.getString('user_goals_list');
    if (goalsJson != null) {
      final List decoded = jsonDecode(goalsJson);
      setState(() {
        _goals = decoded.cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_goals_list', jsonEncode(_goals));
  }

  void _addGoal() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newGoal = {
        'type': _goalType ?? '',
        'monthly': double.tryParse(_monthlyInvestmentController.text) ?? 0.0,
        'item': _itemToBuyController.text,
        'months': int.tryParse(_timeFrameController.text) ?? 0,
      };

      setState(() {
        _goals.add(newGoal);
        _goalType = null;
        _monthlyInvestmentController.clear();
        _itemToBuyController.clear();
        _timeFrameController.clear();
      });

      _saveGoals();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context)!.goalAdded)),
      );
    }
  }

  void _deleteGoal(int index) {
    setState(() {
      _goals.removeAt(index);
    });
    _saveGoals();
  }

  @override
  void dispose() {
    _monthlyInvestmentController.dispose();
    _itemToBuyController.dispose();
    _timeFrameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.financialGoals),
        backgroundColor: const Color.fromARGB(255, 130, 148, 179),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _goalType,
                    decoration: InputDecoration(
                      labelText: s.goalType,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'Retirement', child: Text(s.retirement)),
                      DropdownMenuItem(value: 'Education', child: Text(s.education)),
                      DropdownMenuItem(value: 'Home', child: Text(s.home)),
                      DropdownMenuItem(value: 'Travel', child: Text(s.travel)),
                      DropdownMenuItem(value: 'Other', child: Text(s.other)),
                    ],
                    onChanged: (value) => setState(() => _goalType = value),
                    validator: (value) => value == null ? s.goalType : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _monthlyInvestmentController,
                    decoration: InputDecoration(
                      labelText: s.monthlyInvestment,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || value.isEmpty ? s.enterAmount : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _itemToBuyController,
                    decoration: InputDecoration(
                      labelText: s.whatToBuy,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _timeFrameController,
                    decoration: InputDecoration(
                      labelText: s.timeframe,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || value.isEmpty ? s.enterTimeframe : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 130, 148, 179),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(s.addGoal),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _goals.isEmpty
                  ? Text(s.noGoals)
                  : ListView.builder(
                      itemCount: _goals.length,
                      itemBuilder: (context, index) {
                        final goal = _goals[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(goal['type']),
                            subtitle: Text(
                              '${s.monthlyInvestment}: \$${goal['monthly']}, ${s.whatToBuy}: ${goal['item']}, ${s.timeframe}: ${goal['months']}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteGoal(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
