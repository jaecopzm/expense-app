import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme_enhanced.dart';

class SpendingTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;

  const SpendingTrendChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final monthlyData = _getMonthlyData();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending Trend', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < monthlyData.length) {
                            return Text(monthlyData[value.toInt()]['month'], 
                              style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: monthlyData.asMap().entries.map((e) => 
                        FlSpot(e.key.toDouble(), e.value['amount'])).toList(),
                      isCurved: true,
                      color: AppThemeEnhanced.primaryLight,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppThemeEnhanced.primaryLight.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMonthlyData() {
    final Map<String, double> monthly = {};
    for (var expense in expenses) {
      final date = DateTime.parse(expense['date']);
      final key = DateFormat('MMM').format(date);
      monthly[key] = (monthly[key] ?? 0) + expense['amount'];
    }
    return monthly.entries.map((e) => {'month': e.key, 'amount': e.value}).toList();
  }
}

class CategoryPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;

  const CategoryPieChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final categoryData = _getCategoryData();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category Breakdown', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: categoryData.map((data) => PieChartSectionData(
                    value: data['amount'],
                    title: '${data['percentage']}%',
                    color: data['color'],
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categoryData.map((data) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: data['color'],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(data['category'], style: const TextStyle(fontSize: 12)),
                ],
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getCategoryData() {
    final Map<String, double> categories = {};
    double total = 0;
    
    for (var expense in expenses) {
      final category = expense['category'];
      categories[category] = (categories[category] ?? 0) + expense['amount'];
      total += expense['amount'];
    }

    final colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.red, Colors.teal, Colors.pink, Colors.amber,
    ];

    return categories.entries.toList().asMap().entries.map((e) {
      final percentage = ((e.value.value / total) * 100).round();
      return {
        'category': e.value.key,
        'amount': e.value.value,
        'percentage': percentage,
        'color': colors[e.key % colors.length],
      };
    }).toList();
  }
}

class ComparisonBarChart extends StatelessWidget {
  final double thisMonth;
  final double lastMonth;

  const ComparisonBarChart({
    super.key,
    required this.thisMonth,
    required this.lastMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Month Comparison', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: [thisMonth, lastMonth].reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value == 0 ? 'Last' : 'This',
                            style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(
                        toY: lastMonth,
                        color: Colors.grey,
                        width: 40,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(
                        toY: thisMonth,
                        color: AppThemeEnhanced.primaryLight,
                        width: 40,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                thisMonth > lastMonth 
                  ? '↑ ${((thisMonth - lastMonth) / lastMonth * 100).toStringAsFixed(1)}% increase'
                  : '↓ ${((lastMonth - thisMonth) / lastMonth * 100).toStringAsFixed(1)}% decrease',
                style: TextStyle(
                  color: thisMonth > lastMonth ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
