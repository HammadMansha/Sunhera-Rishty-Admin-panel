import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SubscriptionProfitScreen extends StatefulWidget {
  @override
  _SubscriptionProfitScreenState createState() =>
      _SubscriptionProfitScreenState();
}

class _SubscriptionProfitScreenState extends State<SubscriptionProfitScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Amount'),
      ),
      body: Center(
          child: Container(
              child: SfCartesianChart(
                  title: ChartTitle(text: ''),
                  primaryXAxis: CategoryAxis(),
                  // Initialize category axis.
                  series: <LineSeries<SalesData, String>>[
            // Initialize line series.
            LineSeries<SalesData, String>(
                dataSource: [
                  SalesData('Jan', 10),
                  SalesData('Feb', 20),
                  SalesData('Mar', 10),
                  SalesData('Apr', 20),
                  SalesData('May', 30),
                  SalesData('Jun', 10),
                  SalesData('Jul', 40),
                  SalesData('Aug', 80),
                  SalesData('Sept', 10),
                  SalesData('Oct', 10),
                  SalesData('Nov', 20),
                  SalesData('Dec', 10)
                ],
                xValueMapper: (SalesData sales, _) => sales.year,
                yValueMapper: (SalesData sales, _) => sales.sales)
          ]))),
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final double sales;
}
