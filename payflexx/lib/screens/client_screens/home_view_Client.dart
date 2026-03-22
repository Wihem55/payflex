// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_import, use_build_context_synchronously, annotate_overrides, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:payflexx/Controllers/providers/fullorder_provider.dart';
import 'package:payflexx/screens/client_screens/bankinfopage.dart';
import 'package:payflexx/screens/client_screens/salary_chart.dart';
import 'package:provider/provider.dart';
import '../../services/Managers/assets_manager.dart';
import '../../widgets/text_style/app_name_text.dart';
import '../../widgets/heads/headClient.dart';
import '../../widgets/text_style/title_text.dart';
import '../../Controllers/clientbankinfoController.dart';

class HomeScreen extends StatefulWidget {
  static const routName = '/homeScreenUsers';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    _promptUpdateIfNeeded();
  }

  void _promptUpdateIfNeeded() async {
    bool needsUpdate = await BankInfoController().needsBankingInfoUpdate();
    if (needsUpdate) {
      // Show dialog or navigate to update banking infos page
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Mise à jour requise"),
            content: Text("Veuillez mettre à jour vos informations bancaires."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, BankInfoPage.routName);
                },
                child: Text("Mettre à jour maintenant"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const AppNameTextWidget(fontSize: 20),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.balance_outlined),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //head widget
              headWidgetClient(),
              SizedBox(height: 25),
              //salary level chart
              SalaryChartCard(),
            ],
          ),
        ),
      ),
    );
  }
}
