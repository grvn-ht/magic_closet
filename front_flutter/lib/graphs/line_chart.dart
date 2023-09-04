import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/graphs/line_chart_bar_data.dart';

class LineChartContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: 1,
        minY: 0,
        maxX: 7,
        maxY: 16,
        lineBarsData: lineChartBarData,
        borderData: FlBorderData(
          show: true, // Show the borders
          border: const Border(
            left: BorderSide(color: Colors.grey), // Customize the left border
            bottom:
                BorderSide(color: Colors.grey), // Customize the bottom border
            right: BorderSide.none, // Hide the right border
            top: BorderSide.none, // Hide the top border
          ),
        ),
        titlesData: const FlTitlesData(
          bottomTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1)),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}
