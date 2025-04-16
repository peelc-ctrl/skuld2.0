import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String selectedLift = 'Deadlift';

  final List<double> weeklyWorkouts = [1, 0, 2, 1, 0, 1, 0];
  final List<double> caloriesByDay = [300, 0, 450, 500, 0, 600, 500];

  final Map<String, List<FlSpot>> liftProgress = {
    'Deadlift': [FlSpot(0, 225), FlSpot(1, 245), FlSpot(2, 265), FlSpot(3, 275), FlSpot(4, 285)],
    'Bench': [FlSpot(0, 135), FlSpot(1, 145), FlSpot(2, 155), FlSpot(3, 165), FlSpot(4, 175)],
    'Squat': [FlSpot(0, 185), FlSpot(1, 205), FlSpot(2, 225), FlSpot(3, 235), FlSpot(4, 245)],
  };

  final TextStyle whiteLabel = TextStyle(color: Colors.white, fontSize: 12);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('Your Stats')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildUserHeader(),
            SizedBox(height: 16),
            _buildSummaryStats(),
            SizedBox(height: 24),
            _buildLineChart(),
            SizedBox(height: 24),
            _buildBarChart(),
            SizedBox(height: 24),
            _buildProgressDropdown(),
            SizedBox(height: 16),
            _buildLiftProgressChart(),
            SizedBox(height: 24),
            _buildAchievements(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      children: [
        CircleAvatar(radius: 30, backgroundImage: AssetImage('assets/tanjiro2.jpg')),
        SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("tanjKamado", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("🔥 21 Day Streak", style: TextStyle(color: Colors.orange)),
        ]),
      ],
    );
  }

  Widget _buildSummaryStats() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          _statRow("Workouts this week", "5"),
          _statRow("Calories burned", "2,350 kcal"),
          _statRow("Total time", "6h 12m"),
        ]),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: whiteLabel),
        Text(value, style: whiteLabel.copyWith(fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildLineChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Workout Trend (Last 7 Days)", style: whiteLabel.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      return Text(days[value.toInt() % 7], style: whiteLabel);
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, _) => Text(value.toInt().toString(), style: whiteLabel),
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: 3,
              lineBarsData: [
                LineChartBarData(
                  spots: weeklyWorkouts
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value))
                      .toList(),
                  isCurved: true,
                  color: Colors.blue,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.black87,
                  getTooltipItems: (touchedSpots) => touchedSpots
                      .map((spot) => LineTooltipItem('${spot.y}', TextStyle(color: Colors.white)))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Calories Burned (Last 7 Days)", style: whiteLabel.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      return Text(days[value.toInt() % 7], style: whiteLabel);
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 200,
                    getTitlesWidget: (value, _) => Text(value.toInt().toString(), style: whiteLabel),
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: caloriesByDay
                  .asMap()
                  .entries
                  .map((e) => BarChartGroupData(
                        x: e.key,
                        barRods: [
                          BarChartRodData(
                            toY: e.value,
                            color: Colors.orange,
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                          )
                        ],
                      ))
                  .toList(),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.black87,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                    rod.toY.toString(),
                    TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Lift Progress", style: whiteLabel.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          dropdownColor: Colors.grey[850],
          value: selectedLift,
          iconEnabledColor: Colors.white,
          style: whiteLabel,
          underline: Container(height: 1, color: Colors.white),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedLift = value;
              });
            }
          },
          items: ['Deadlift', 'Bench', 'Squat']
              .map((lift) => DropdownMenuItem(
                    value: lift,
                    child: Text(lift),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLiftProgressChart() {
    final progressData = liftProgress[selectedLift]!;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Text("W${value.toInt() + 1}", style: whiteLabel),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                getTitlesWidget: (value, _) => Text(value.toInt().toString(), style: whiteLabel),
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          minX: 0,
          maxX: 4,
          minY: progressData.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 10,
          maxY: progressData.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 10,
          lineBarsData: [
            LineChartBarData(
              spots: progressData,
              isCurved: true,
              color: Colors.greenAccent,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: Colors.greenAccent.withOpacity(0.2)),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.black87,
              getTooltipItems: (touchedSpots) => touchedSpots
                  .map((spot) => LineTooltipItem('${spot.y.toInt()} lbs', TextStyle(color: Colors.white)))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievements() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Recent Achievements", style: whiteLabel.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("🏅 Completed 100 Workouts", style: whiteLabel),
          Text("🏆 7-Day Streak", style: whiteLabel),
        ]),
      ),
    );
  }
}

