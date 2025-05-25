// lib/widgets/charts/sales_chart.dart
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SalesChart extends StatelessWidget {
  final List<CartesianSeries<SalesData, DateTime>> seriesList;

  const SalesChart({
    super.key,
    required this.seriesList,
  });

  factory SalesChart.sampleData() {
    return SalesChart(
      seriesList: [
        FastLineSeries<SalesData, DateTime>(
          name: 'Penjualan',
          dataSource: [
            SalesData(date: DateTime(2024, 1, 1), amount: 500000),
            SalesData(date: DateTime(2024, 2, 1), amount: 750000),
            SalesData(date: DateTime(2024, 3, 1), amount: 1000000),
          ],
          xValueMapper: (SalesData sales, _) => sales.date,
          yValueMapper: (SalesData sales, _) => sales.amount,
          color: Colors.blue,
          markerSettings: const MarkerSettings(isVisible: true),
          animationDuration: 1000,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.currency(
          symbol: 'Rp',
          decimalDigits: 0,
        ),
      ),
      legend: const Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: seriesList,
    );
  }
}

class SalesData {
  final DateTime date;
  final int amount;

  SalesData({
    required this.date,
    required this.amount,
  });
}