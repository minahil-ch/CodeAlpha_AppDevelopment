import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/mock_activity_provider.dart';
import '../models/activity.dart';
import '../models/exercise_types.dart';
import '../models/exercise_types.dart' as exercise_types;

class AddActivityScreen extends StatefulWidget {
  final Activity? activity; // For editing existing activity

  const AddActivityScreen({super.key, this.activity});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedExerciseType;
  late TextEditingController _durationController;
  late TextEditingController _caloriesController;
  late TextEditingController _distanceController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isCalculatingCalories = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.activity != null) {
      // Editing existing activity
      _selectedExerciseType = widget.activity!.type;
      _durationController = TextEditingController(text: widget.activity!.duration.toString());
      _caloriesController = TextEditingController(text: widget.activity!.calories.toString());
      _distanceController = TextEditingController(text: widget.activity!.distance?.toString() ?? '');
      _notesController = TextEditingController(text: widget.activity!.notes ?? '');
      _selectedDate = widget.activity!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.activity!.dateTime);
    } else {
      // Adding new activity
      _selectedExerciseType = exercise_types.ExerciseType.getAllTypes()[0];
      _durationController = TextEditingController();
      _caloriesController = TextEditingController();
      _distanceController = TextEditingController();
      _notesController = TextEditingController();
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    _distanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  DateTime _combineDateAndTime() {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  Future<void> _calculateCalories() async {
    if (_durationController.text.isEmpty) return;
    
    setState(() {
      _isCalculatingCalories = true;
    });

    try {
      final duration = int.tryParse(_durationController.text) ?? 0;
      final calculatedCalories = CalorieCalculator.calculateCalories(
        _selectedExerciseType,
        duration,
      );
      
      setState(() {
        _caloriesController.text = calculatedCalories.toString();
        _isCalculatingCalories = false;
      });
    } catch (e) {
      setState(() {
        _isCalculatingCalories = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error calculating calories: $e')),
      );
    }
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final activity = Activity(
        id: widget.activity?.id,
        type: _selectedExerciseType,
        duration: int.parse(_durationController.text),
        calories: int.parse(_caloriesController.text),
        dateTime: _combineDateAndTime(),
        distance: _distanceController.text.isNotEmpty 
            ? double.tryParse(_distanceController.text) 
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (widget.activity != null) {
        // Update existing activity
        await Provider.of<MockActivityProvider>(context, listen: false)
            .updateActivity(activity);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity updated successfully!')),
        );
      } else {
        // Add new activity
        await Provider.of<MockActivityProvider>(context, listen: false)
            .addActivity(activity);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity added successfully!')),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving activity: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity != null ? 'Edit Activity' : 'Add Activity'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildExerciseTypeSelector(),
              const SizedBox(height: 20),
              _buildDurationField(),
              const SizedBox(height: 20),
              _buildCaloriesField(),
              const SizedBox(height: 20),
              _buildDistanceField(),
              const SizedBox(height: 20),
              _buildDateTimeSelectors(),
              const SizedBox(height: 20),
              _buildNotesField(),
              const SizedBox(height: 30),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exercise Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedExerciseType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Select exercise type',
          ),
          items: exercise_types.ExerciseType.getAllTypes().map((type) {
            return DropdownMenuItem(
              value: type,
              child: Row(
                children: [
                  Text(exercise_types.ExerciseType.getIcons()[type] ?? '📝'),
                  const SizedBox(width: 10),
                  Text(type),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedExerciseType = value;
              });
              // Recalculate calories when exercise type changes
              if (_durationController.text.isNotEmpty) {
                _calculateCalories();
              }
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select an exercise type';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDurationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duration (minutes)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _durationController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter duration in minutes',
            prefixIcon: Icon(Icons.timer),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter duration';
            }
            final duration = int.tryParse(value);
            if (duration == null || duration <= 0) {
              return 'Please enter a valid duration';
            }
            return null;
          },
          onChanged: (value) {
            if (value.isNotEmpty) {
              _calculateCalories();
            }
          },
        ),
      ],
    );
  }

  Widget _buildCaloriesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Calories Burned',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _isCalculatingCalories ? null : _calculateCalories,
              child: _isCalculatingCalories
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Calculate'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _caloriesController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter calories burned',
            prefixIcon: Icon(Icons.local_fire_department),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter calories';
            }
            final calories = int.tryParse(value);
            if (calories == null || calories < 0) {
              return 'Please enter a valid calorie amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDistanceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distance (km) - Optional',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _distanceController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter distance in kilometers',
            prefixIcon: Icon(Icons.directions),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final distance = double.tryParse(value);
              if (distance == null || distance < 0) {
                return 'Please enter a valid distance';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateTimeSelectors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date & Time',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: _selectDate,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.green),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: _selectTime,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.access_time, color: Colors.green),
                        const SizedBox(height: 8),
                        Text(
                          _selectedTime.format(context),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Add any notes about your workout...',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveActivity,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          widget.activity != null ? 'Update Activity' : 'Add Activity',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}