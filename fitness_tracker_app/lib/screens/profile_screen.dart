import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/mock_goal_provider.dart';
import '../models/goal.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stepGoalController = TextEditingController();
  final _calorieGoalController = TextEditingController();
  final _activeMinutesController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentGoal();
  }

  @override
  void dispose() {
    _stepGoalController.dispose();
    _calorieGoalController.dispose();
    _activeMinutesController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentGoal() async {
    await Provider.of<MockGoalProvider>(context, listen: false).loadCurrentGoal();
    final goal = Provider.of<MockGoalProvider>(context, listen: false).currentGoal;
    
    if (goal != null) {
      setState(() {
        _stepGoalController.text = goal.stepGoal.toString();
        _calorieGoalController.text = goal.calorieGoal.toString();
        _activeMinutesController.text = goal.activeMinuteGoal.toString();
      });
    }
  }

  Future<void> _saveGoals() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final goal = Goal(
        id: Provider.of<MockGoalProvider>(context, listen: false).currentGoal?.id,
        stepGoal: int.parse(_stepGoalController.text),
        calorieGoal: int.parse(_calorieGoalController.text),
        activeMinuteGoal: int.parse(_activeMinutesController.text),
        createdAt: DateTime.now(),
      );

      await Provider.of<MockGoalProvider>(context, listen: false).setGoal(goal);
      
      setState(() {
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goals updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving goals: $e')),
      );
    }
  }

  void _resetToDefaults() {
    setState(() {
      _stepGoalController.text = '10000';
      _calorieGoalController.text = '2000';
      _activeMinutesController.text = '30';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Goals'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveGoals,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Consumer<MockGoalProvider>(
        builder: (context, goalProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 30),
                _buildCurrentGoalsSection(goalProvider),
                const SizedBox(height: 30),
                if (_isEditing) _buildEditForm(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Fitness Enthusiast',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Member since ${DateFormat('MMMM yyyy').format(DateTime.now())}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentGoalsSection(MockGoalProvider goalProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Daily Goals',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<Map<String, double>>(
          future: goalProvider.getTodayProgress(),
          builder: (context, progressSnapshot) {
            return FutureBuilder<Map<String, int>>(
              future: goalProvider.getRemainingToGoal(),
              builder: (context, remainingSnapshot) {
                if (!progressSnapshot.hasData || !remainingSnapshot.hasData) {
                  return const Card(
                    child: SizedBox(
                      height: 150,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                final progress = progressSnapshot.data!;
                final remaining = remainingSnapshot.data!;
                final goal = goalProvider.currentGoal;

                if (goal == null) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Set your daily goals to start tracking your progress!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    _buildGoalCard(
                      'Steps',
                      '${goal.stepGoal}',
                      '${remaining!['stepsRemaining']} to go',
                      progress['stepsProgress']!,
                      Icons.directions_walk,
                      Colors.blue,
                    ),
                    const SizedBox(height: 15),
                    _buildGoalCard(
                      'Calories',
                      '${goal.calorieGoal}',
                      '${remaining['caloriesRemaining']} to burn',
                      progress['caloriesProgress']!,
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                    const SizedBox(height: 15),
                    _buildGoalCard(
                      'Active Minutes',
                      '${goal.activeMinuteGoal}',
                      '${remaining['activeMinutesRemaining']} min left',
                      progress['activeMinutesProgress']!,
                      Icons.timer,
                      Colors.purple,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildGoalCard(
    String title,
    String goalValue,
    String remainingText,
    double progress,
    IconData icon,
    Color color,
  ) {
    final percentage = (progress * 100).round();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Goal: $goalValue',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              remainingText,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Set New Goals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildGoalInputField(
            'Daily Step Goal',
            'Steps',
            _stepGoalController,
            Icons.directions_walk,
            '10000',
          ),
          const SizedBox(height: 16),
          _buildGoalInputField(
            'Daily Calorie Goal',
            'Calories',
            _calorieGoalController,
            Icons.local_fire_department,
            '2000',
          ),
          const SizedBox(height: 16),
          _buildGoalInputField(
            'Daily Active Minutes',
            'Minutes',
            _activeMinutesController,
            Icons.timer,
            '30',
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetToDefaults,
                  child: const Text('Reset to Defaults'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveGoals,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Goals'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalInputField(
    String label,
    String unit,
    TextEditingController controller,
    IconData icon,
    String defaultValue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            prefixIcon: Icon(icon),
            suffixText: unit,
            hintText: defaultValue,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a value';
            }
            final number = int.tryParse(value);
            if (number == null || number <= 0) {
              return 'Please enter a valid number greater than 0';
            }
            return null;
          },
        ),
      ],
    );
  }
}