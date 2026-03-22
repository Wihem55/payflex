// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartCard extends StatefulWidget {
  @override
  _LineChartCardState createState() => _LineChartCardState();
}

class _LineChartCardState extends State<LineChartCard> {
  List<FlSpot> _spots = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    List<MonthData> data = await fetchMonthlyChequeData();
    if (mounted) {
      setState(() {
        _spots = data.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.count.toDouble());
        }).toList();
      });
    }
  }

  Future<List<MonthData>> fetchMonthlyChequeData() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    List<MonthData> monthlyData = [];
    for (int month = 1; month <= 12; month++) {
      var startDate = DateTime(DateTime.now().year, month, 1, 0, 0, 0);
      var endDate = DateTime(DateTime.now().year, month + 1, 1, 0, 0, 0)
          .subtract(const Duration(seconds: 1));

      var snapshot = await _firestore
          .collection('cheques')
          .where('visitDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('visitDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      int count = snapshot.docs.length;
      monthlyData.add(MonthData(month.toString(), count));
    }
    return monthlyData;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color:const Color.fromARGB(255, 18, 67, 89),
      ),
      padding: const EdgeInsets.only(right: 18, left: 12, top: 24, bottom: 12),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: _spots,
              isCurved: true,
              color: const  Color.fromARGB(190,198, 211, 0),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: const  Color.fromARGB(190,198, 211, 0)),
            ),
          ],
        
          borderData: FlBorderData(show: false),

          minX: 0,

          maxX: 12,
          minY: 0,


        ),
        
      ),
    );
  }
}

class MonthData {
  final String month;
  final int count;

  MonthData(this.month, this.count);
}
