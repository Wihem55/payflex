// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:payflexx/Controllers/providers/clientbankInfo_provider.dart';

import 'package:provider/provider.dart';

class SalaryChartCard extends StatelessWidget {
  const SalaryChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color:const Color(0xFF1E1E2C),
         border: Border.all(color: const Color(0xFF9E9E9E)), 
      ),
      padding: const EdgeInsets.all(16),
      child: Consumer<ClientBankInfoProvider>(
        builder: (context, clientBankInfoProvider, child) {
          String salaryLevel =
              _getSalaryLevel(clientBankInfoProvider.getClientBankInfo?.salary);
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Niveau de salaire : $salaryLevel',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: _getChartSections(salaryLevel),
                    centerSpaceRadius: 40,
                    sectionsSpace: 0,
                    startDegreeOffset: 180,
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 500),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
//get salary level method
  String _getSalaryLevel(String? salary) {
    if (salary == null || salary.isEmpty) {
      return 'Unknown';
    }
//salary level 
    double salaryAmount = double.tryParse(salary) ?? 0.0;
    if (salaryAmount < 2000) {
      return 'Low';
    } else if (salaryAmount >= 2000 && salaryAmount < 5000) {
      return 'Medium';
    } else if (salaryAmount >= 5000 && salaryAmount < 10000) {
      return 'High';
    } else {
      return 'very High';
    }
  }

  List<PieChartSectionData> _getChartSections(String salaryLevel) {
    Color lowColor = const Color.fromARGB(255, 16, 125, 18);
    Color mediumColor = Colors.yellow;
    Color highColor = Colors.orange;
    Color riskyColor = Colors.red;

    double lowValue = salaryLevel == 'Low' ? 1.0 : 0.0;
    double mediumValue = salaryLevel == 'Medium' ? 1.0 : 0.0;
    double highValue = salaryLevel == 'High' ? 1.0 : 0.0;
    double riskyValue = salaryLevel == 'Risky' ? 1.0 : 0.0;

    return [
      PieChartSectionData(
        color: lowColor,
        value: lowValue,
        title: '',
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: mediumColor,
        value: mediumValue,
        title: '',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
      ),
      PieChartSectionData(
        color: highColor,
        value: highValue,
        title: '',
        radius: 70,
        titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
      ),
      PieChartSectionData(
        color: riskyColor,
        value: riskyValue,
        title: '',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
      ),
    ];
  }
}
