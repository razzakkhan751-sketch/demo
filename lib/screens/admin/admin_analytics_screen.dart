import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/analytics_service.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  Map<String, int>? _counts;
  Map<String, int>? _roleDistribution;
  Map<String, int>? _categoryDistribution;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final counts = await _analyticsService.getCounts();
      final roles = await _analyticsService.getUserRoleDistribution();
      final categories = await _analyticsService
          .getCourseCategoryDistribution();

      if (mounted) {
        setState(() {
          _counts = counts;
          _roleDistribution = roles;
          _categoryDistribution = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Analytics & Reports")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Overview Cards
            const Text(
              "Overview",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(
                  "Total Users",
                  _counts?['users'] ?? 0,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  "Total Courses",
                  _counts?['courses'] ?? 0,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(
                  "Live Classes",
                  _counts?['live_classes'] ?? 0,
                  Colors.red,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  "Revenue (Est)",
                  "\$${(_counts?['users'] ?? 0) * 10}",
                  Colors.green,
                ), // Mock revenue
              ],
            ),

            const SizedBox(height: 32),

            // 2. User Distribution Pie Chart
            const Text(
              "User Distribution",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.3,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 40,
                          sections: _showingSections(),
                        ),
                      ),
                    ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Indicator(
                          color: Colors.blue,
                          text: 'Student',
                          isSquare: true,
                        ),
                        SizedBox(height: 4),
                        _Indicator(
                          color: Colors.red,
                          text: 'Admin',
                          isSquare: true,
                        ),
                        SizedBox(height: 4),
                        _Indicator(
                          color: Colors.green,
                          text: 'Teacher',
                          isSquare: true,
                        ),
                      ],
                    ),
                    const SizedBox(width: 28),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 3. Course Categories Bar Chart
            const Text(
              "Courses by Category",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.6,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 16,
                    left: 12,
                    top: 24,
                    bottom: 12,
                  ),
                  child: BarChart(
                    BarChartData(
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final index = value.toInt();
                              final keys =
                                  _categoryDistribution?.keys.toList() ?? [];
                              if (index >= 0 && index < keys.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    keys[index].substring(0, 3),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _getBarGroups(),
                      gridData: const FlGridData(show: false),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, dynamic value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _showingSections() {
    return List.generate(3, (i) {
      const fontSize = 16.0;
      const radius = 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      int value = 0;
      Color color = Colors.grey;

      switch (i) {
        case 0:
          value = _roleDistribution?['Student'] ?? 0;
          color = Colors.blue;
          break;
        case 1:
          value = _roleDistribution?['Admin'] ?? 0;
          color = Colors.red;
          break;
        case 2:
          value = _roleDistribution?['Teacher'] ?? 0;
          color = Colors.green;
          break;
      }

      // Prevent division by zero or empty charts
      if (value == 0) {
        return PieChartSectionData(
          value: 0.1,
          color: Colors.transparent,
          title: "",
        );
      }

      return PieChartSectionData(
        color: color,
        value: value.toDouble(),
        title: '$value',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    });
  }

  List<BarChartGroupData> _getBarGroups() {
    if (_categoryDistribution == null) return [];

    final List<BarChartGroupData> bars = [];
    int index = 0;
    _categoryDistribution!.forEach((key, value) {
      bars.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value.toDouble(),
              color: Colors.deepPurple,
              width: 16,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
      index++;
    });
    return bars;
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({
    required this.color,
    required this.text,
    required this.isSquare,
  });
  final Color color;
  final String text;
  final bool isSquare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
