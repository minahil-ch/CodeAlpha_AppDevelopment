import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/mock_activity_provider.dart';
import '../models/activity.dart';
import '../models/exercise_types.dart';
import 'add_activity_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'All';
  DateTime? _selectedDate;
  final List<String> _filterOptions = ['All', 'Today', 'This Week', 'This Month'];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    await Provider.of<MockActivityProvider>(context, listen: false).loadActivities();
  }

  List<Activity> _filterActivities(List<Activity> activities) {
    final now = DateTime.now();
    
    switch (_filter) {
      case 'Today':
        return activities.where((activity) {
          return _isSameDay(activity.dateTime, now);
        }).toList();
        
      case 'This Week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));
        return activities.where((activity) {
          return activity.dateTime.isAfter(weekStart) && 
                 activity.dateTime.isBefore(weekEnd);
        }).toList();
        
      case 'This Month':
        return activities.where((activity) {
          return activity.dateTime.month == now.month && 
                 activity.dateTime.year == now.year;
        }).toList();
        
      default: // All
        return activities;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _filter = 'Custom'; // Set to custom when date is selected
      });
    }
  }

  List<Activity> _applyDateFilter(List<Activity> activities) {
    if (_selectedDate == null) return activities;
    
    return activities.where((activity) {
      return _isSameDay(activity.dateTime, _selectedDate!);
    }).toList();
  }

  void _deleteActivity(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Activity'),
          content: const Text('Are you sure you want to delete this activity?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await Provider.of<MockActivityProvider>(context, listen: false)
                      .deleteActivity(id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Activity deleted successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting activity: $e')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String value) {
              setState(() {
                _filter = value;
                if (value != 'Custom') {
                  _selectedDate = null;
                }
              });
            },
            itemBuilder: (BuildContext context) {
              final List<PopupMenuEntry<String>> items = [];
              
              // Add filter options
              for (final option in _filterOptions) {
                items.add(
                  PopupMenuItem<String>(
                    value: option,
                    child: Text(option),
                  ),
                );
              }
              
              // Add divider
              items.add(const PopupMenuDivider());
              
              // Add custom date option
              items.add(
                PopupMenuItem<String>(
                  value: 'Custom',
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 8),
                      Text(_selectedDate == null 
                          ? 'Select Date' 
                          : DateFormat('MMM dd, yyyy').format(_selectedDate!)),
                    ],
                  ),
                ),
              );
              
              return items;
            },
          ),
        ],
      ),
      body: Consumer<MockActivityProvider>(
        builder: (context, activityProvider, child) {
          if (activityProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredActivities = _applyDateFilter(
            _filterActivities(activityProvider.activities)
          );

          if (filteredActivities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _filter == 'Custom' && _selectedDate != null 
                        ? Icons.search_off 
                        : Icons.fitness_center,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _filter == 'Custom' && _selectedDate != null
                        ? 'No activities found for selected date'
                        : 'No activities recorded yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start tracking your fitness journey!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadActivities,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredActivities.length,
              itemBuilder: (context, index) {
                final activity = filteredActivities[index];
                return _buildActivityTile(activity);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityTile(Activity activity) {
    final dateFormatted = DateFormat('MMM dd, yyyy').format(activity.dateTime);
    final timeFormatted = DateFormat('hh:mm a').format(activity.dateTime);
    final icon = ExerciseType.getIcons()[activity.type] ?? '📝';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Dismissible(
        key: Key(activity.id.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          _deleteActivity(activity.id!);
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          title: Text(
            activity.type,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.timer, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${activity.duration} min'),
                  const SizedBox(width: 16),
                  const Icon(Icons.local_fire_department, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${activity.calories} cal'),
                ],
              ),
              if (activity.distance != null) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.directions, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${activity.distance!.toStringAsFixed(2)} km'),
                  ],
                ),
              ],
              const SizedBox(height: 2),
              Text(
                '$dateFormatted • $timeFormatted',
                style: const TextStyle(color: Colors.grey),
              ),
              if (activity.notes != null && activity.notes!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    activity.notes!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit, color: Colors.green),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddActivityScreen(activity: activity),
                ),
              ).then((_) => _loadActivities());
            },
          ),
        ),
      ),
    );
  }
}