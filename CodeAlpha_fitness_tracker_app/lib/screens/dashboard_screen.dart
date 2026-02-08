import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/mock_activity_provider.dart';
import '../providers/mock_goal_provider.dart';
import 'add_activity_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Provider.of<MockActivityProvider>(context, listen: false).loadActivities();
    await Provider.of<MockGoalProvider>(context, listen: false).loadCurrentGoal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Tracker'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildTodayStats(),
              const SizedBox(height: 20),
              _buildProgressIndicators(),
              const SizedBox(height: 20),
              _buildWeeklyChart(),
              const SizedBox(height: 20),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddActivityScreen()),
          ).then((_) => _loadData());
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            formattedDate,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildTodayStats() {
    return Consumer<MockActivityProvider>(
      builder: (context, activityProvider, child) {
        return FutureBuilder<Map<String, dynamic>>(
          future: activityProvider.getTodayStats(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _buildStatsLoading();
            }

            final stats = snapshot.data!;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _buildStatCard('Steps', '${stats['totalSteps']}', '👣'),
                    const SizedBox(width: 10),
                    _buildStatCard('Calories', '${stats['totalCalories']}', '🔥'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildStatCard('Minutes', '${stats['totalDuration']}', '⏱️'),
                    const SizedBox(width: 10),
                    _buildStatCard('Workouts', '${stats['activitiesCount']}', '💪'),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatsLoading() {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(child: Card(child: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())))),
            SizedBox(width: 10),
            Expanded(child: Card(child: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())))),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: Card(child: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())))),
            SizedBox(width: 10),
            Expanded(child: Card(child: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())))),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String emoji) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicators() {
    return Consumer<MockGoalProvider>(
      builder: (context, goalProvider, child) {
        return FutureBuilder<Map<String, double>>(
          future: goalProvider!.getTodayProgress(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Card(
                child: SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final progress = snapshot.data!;
            
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Goals Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildProgressRow('Steps', progress['stepsProgress']!, Icons.directions_walk),
                    const SizedBox(height: 10),
                    _buildProgressRow('Calories', progress['caloriesProgress']!, Icons.local_fire_department),
                    const SizedBox(height: 10),
                    _buildProgressRow('Active Minutes', progress['activeMinutesProgress']!, Icons.timer),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProgressRow(String label, double progress, IconData icon) {
    final percentage = (progress * 100).round();
    
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.green),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text('$percentage%', style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 5),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                minHeight: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    return Consumer<MockActivityProvider>(
      builder: (context, activityProvider, child) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: activityProvider!.getWeeklyStats(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Card(
                child: SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final weeklyData = snapshot.data!;
            
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weekly Steps',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          barGroups: weeklyData.asMap().entries.map((entry) {
                            int index = entry.key;
                            var data = entry.value;
                            
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: (data['steps'] / 1000).toDouble(), // Convert to thousands
                                  color: Colors.green,
                                  width: 20,
                                  borderRadius: BorderRadius.zero,
                                ),
                              ],
                            );
                          }).toList(),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                  final index = value.toInt();
                                  return Text(
                                    index < days.length ? days[index] : '',
                                    style: const TextStyle(fontSize: 12),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text('${value.toInt()}k');
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: true),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildActionButton('History', Icons.history, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            }),
            const SizedBox(width: 10),
            _buildActionButton('Add Activity', Icons.add_box, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddActivityScreen()),
              ).then((_) => _loadData());
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 30, color: Colors.green),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}