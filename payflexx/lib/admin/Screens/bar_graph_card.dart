// ignore_for_file: prefer_const_constructors_in_immutables, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:payflexx/admin/responsive.dart';
import 'package:payflexx/admin/model/bar_graph_model.dart';
import 'package:payflexx/admin/model/graph_model.dart';
import 'package:payflexx/admin/widgets/custom_card.dart';
import 'package:payflexx/Models/check_solvanbility_model.dart';
import 'package:payflexx/Models/user_model.dart';

class BarGraphCard extends StatefulWidget {
  BarGraphCard({Key? key}) : super(key: key);

  @override
  _BarGraphCardState createState() => _BarGraphCardState();
}

/// Fetches the number of clients visited in the last 7 days
Future<List<int>> getClientCountsPerDay() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('cheques')
      .where('visitDate',
          isGreaterThan: DateTime.now().subtract(const Duration(days: 7)))
      .get();

  List<int> dayCounts = List.filled(6, 0); // Monday to Saturday

  for (var doc in snapshot.docs) {
    ChequeModel cheque = ChequeModel.fromFirestore(doc);
    int weekday = cheque.visitDate.weekday -
        1; // Adjusting because Dart's DateTime Monday is 1
    if (weekday < 6) {
      // Only count Monday to Saturday
      dayCounts[weekday]++;
    }
  }

  return dayCounts;
}

/// Fetches the number of clients visited in the last 7 days
Future<List<int>> getUsersCountsPerDay() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('createdAt',
          isGreaterThan: DateTime.now().subtract(const Duration(days: 7)))
      .get();

  List<int> dayCounts = List.filled(6, 0); // Monday to Saturday

  for (var doc in snapshot.docs) {
    UserModel user = UserModel.fromFirestore(doc);
    int weekday = user.createdAt.toDate().weekday -
        1; // Adjusting because Dart's DateTime Monday is 1
    if (weekday < 6) {
      // Only count Monday to Saturday
      dayCounts[weekday]++;
    }
  }

  return dayCounts;
}

class _BarGraphCardState extends State<BarGraphCard> {
  List<BarGraphModel> data = [];

  final lable = ['M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    _updateBarGraphData();
  }

  void _updateBarGraphData() async {
    List<int> clientCounts = await getClientCountsPerDay();
    List<int> userCounts = await getUsersCountsPerDay();

    data = [
      BarGraphModel(
        lable: "Users Chart (Day) ",
        color: const Color.fromARGB(255, 18, 67, 89),
        graph: List.generate(
            6, (index) => GraphModel(x: index, y: clientCounts[index])),
      ),
      BarGraphModel(
        lable: "Orders Chart (Day) ",
        color: const Color.fromARGB(248, 9, 93, 49),
        graph: List.generate(
            6, (index) => GraphModel(x: index, y: userCounts[index])),
      ),
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: data.length,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.isMobile(context) ? 1 : 3,
          crossAxisSpacing: !Responsive.isMobile(context) ? 15 : 12,
          mainAxisSpacing: 12.0,
          childAspectRatio: Responsive.isMobile(context) ? 16 / 9 : 5 / 4),
      itemBuilder: (context, i) {
        return CustomCard(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    data[i].lable,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      barGroups: _chartGroups(
                          points: data[i].graph, color: data[i].color),
                      borderData: FlBorderData(border: const Border()),
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                lable[value.toInt()],
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500),
                              ),
                            );
                          },
                        )),
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                    ),
                  ),
                ),
              ],
            ));
      },
    );
  }

  List<BarChartGroupData> _chartGroups(
      {required List<GraphModel> points, required Color color}) {
    return points
        .map((point) => BarChartGroupData(x: point.x.toInt(), barRods: [
              BarChartRodData(
                toY: point.y.toDouble(),
                width: 12,
                color: color.withOpacity(point.y.toInt() > 4 ? 1 : 0.4),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3.0),
                  topRight: Radius.circular(3.0),
                ),
              )
            ]))
        .toList();
  }
}
