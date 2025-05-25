// lib/widgets/charts/fuel_usage_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FuelUsageChart extends StatelessWidget {
  final List<BarChartGroupData> barGroups;
  final List<String> vehicleNames;

  const FuelUsageChart({
    super.key,
    required this.barGroups,
    required this.vehicleNames,
  });

  factory FuelUsageChart.sampleData() {
    return FuelUsageChart(
      vehicleNames: ['Truck 1', 'Truck 2', 'Truck 3'],
      barGroups: [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
              toY: 150,
              color: Colors.green,
              width: 20,
            ),
          ],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(
              toY: 200,
              color: Colors.green,
              width: 20,
            ),
          ],
        ),
        BarChartGroupData(
          x: 2,
          barRods: [
            BarChartRodData(
              toY: 175,
              color: Colors.green,
              width: 20,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: barGroups,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(vehicleNames[value.toInt()]),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          topTitles: AxisTitles(),
          rightTitles: AxisTitles(),
        ),
      ),
    );
  }
}

class FuelData {
  final String vehicle;
  final int liters;

  FuelData(this.vehicle, this.liters);
}