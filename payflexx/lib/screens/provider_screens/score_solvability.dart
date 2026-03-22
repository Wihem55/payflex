// ignore_for_file: prefer_const_constructors, unused_local_variable, use_build_context_synchronously, unnecessary_null_comparison, avoid_print

import 'package:flutter/material.dart';

import 'package:payflexx/models/productdescreption_model.dart';
import 'package:payflexx/screens/inner_screens/orders/invoicePage.dart';
import 'package:payflexx/screens/inner_screens/orders/orders_screen.dart';
import 'package:payflexx/screens/inner_screens/orders/orders_widget.dart';
import 'package:payflexx/services/Managers/assets_manager.dart';
import 'package:payflexx/Colors/color_extension.dart';
import 'package:payflexx/widgets/solvability%20widgets/custom_arc_painter.dart';
import 'package:payflexx/widgets/solvability%20widgets/segment_button.dart';
import 'package:payflexx/widgets/solvability%20widgets/status_button.dart';
import 'package:payflexx/screens/provider_screens/footer_provider.dart';

import 'package:provider/provider.dart';

import '../../Controllers/providers/checksolvability_provider.dart';
import '../../Controllers/providers/fullorder_provider.dart';

class HomeView extends StatefulWidget {
  final String? clientId, orderId;

  const HomeView({Key? key, required this.clientId, this.orderId})
      : super(key: key);
  static const routeName = '/HomeViewsolvabilityview';
  @override
  State<HomeView> createState() => _HomeViewState();
}

// function solvability
enum SolvabilityLevel { healthy, stable, risky }

//************
class _HomeViewState extends State<HomeView> {
  void navigateToSubscriptionInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrdersPage(),
      ),
    );
  }

  bool isSubscription = true;
  List<Map<String, dynamic>> historicalData = [];

  SolvabilityLevel _solvabilityLevel =
      SolvabilityLevel.risky; // Initial default solvability level

  void checkSolvability(String clientId) async {
    final chequeDetails =
        await Provider.of<ChequeProvider>(context, listen: false)
            .fetchChequeDetailsFromFirestore(clientId);

    if (chequeDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to fetch cheque details or no data.")));
      return;
    }

    double salary = double.tryParse(chequeDetails['clientSalary'] ?? '0') ?? 0;
    int checks = int.tryParse(chequeDetails['nbCheques'] ?? '0') ?? 0;
    double price = double.tryParse(chequeDetails['articalPrice'] ?? '0') ?? 0;

    // Avoid division by zero by ensuring checks is at least 1
    if (checks <= 0) checks = 1;

    double monthlyPayment = price / checks;
    double remainingSalaryPercentage =
        ((salary - monthlyPayment) / salary) * 100;
    double thresholdPercentage =
        40.0; // Example threshold percentage of remaining salary

    bool isSolvent = salary > monthlyPayment &&
        remainingSalaryPercentage >= thresholdPercentage;

    setState(() {
      _solvabilityLevel =
          isSolvent ? SolvabilityLevel.healthy : SolvabilityLevel.risky;
    });

    if (isSolvent) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Client is solvent: Solvency confirmed and data saved!"),
      ));

      addToHistory();
      // Optionally save data or perform further actions
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Client is not solvent"),
      ));
    }
  }

  void addToHistory() {
    // Assuming you have access to the latest ProductDescriptionDataModel instance through a provider or directly
    final productData =
        Provider.of<ProductDescriptionDataModel>(context, listen: false);

    if (productData != null) {
      Map<String, dynamic> historyEntry = {
        "name": productData.productName ?? "Unknown Product",
        "price": productData.price ?? "0",
        "productDescription":
            productData.productDescription ?? "No Description",
        "code": productData.code,
        "productRef": productData.productRef,
        "adresse": productData.adresse,
        "quantity": productData.quantity,
        "selectedProvider": productData.providerSelected,
        "providerLogo": productData.providerLogo,
        "time": DateTime.now().toString(),
      };

      setState(() {
        historicalData.add(historyEntry);
      });

      // Optionally, you can also save this to a persistent store or database
    } else {
      print("No product data available for history logging.");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.clientId != null) {
        checkSolvability(widget.clientId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ChequeProvider>(context);
    String currentClientId =
        Provider.of<ChequeProvider>(context).getCurrentClientId();
    var media = MediaQuery.sizeOf(context);
    String solvabilityText =
        _solvabilityLevel.toString().split('.').last.toUpperCase();
    double endAngle;
    switch (_solvabilityLevel) {
      case SolvabilityLevel.healthy:
        endAngle = 270;
        break;
      case SolvabilityLevel.stable:
        endAngle = 141;
        break;
      default:
        endAngle = 50;
        break;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.gray60.withOpacity(0.2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color.fromARGB(255, 139, 137, 137)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MainTabView(),
              ),
            );
          },
        ),
      ),
      backgroundColor: TColor.gray70,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: media.width * 1.1,
              decoration: BoxDecoration(
                  color: TColor.gray70.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25))),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(AssetsManager.homebg),
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: media.width * 0.05),
                        width: media.width * 0.72,
                        height: media.width * 0.72,
                        child: CustomPaint(
                          size: Size(media.width * 0.72, media.width * 0.72),
                          painter: CustomArcPainter(start: 0, end: endAngle),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      Image.asset(AssetsManager.applogo,
                          width: media.width * 0.25, fit: BoxFit.contain),
                      SizedBox(
                        height: media.width * 0.07,
                      ),
                      // affiche
                      Text(
                        solvabilityText,
                        style: TextStyle(
                            color: TColor.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        height: media.width * 0.055,
                      ),
                      Text(
                        "Resulting balance",
                        style: TextStyle(
                            color: TColor.gray40,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: media.width * 0.07,
                      ),
                      
                    ],
                  ),
                 
                ],
              ),
            ),
            /***************************** */
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  Expanded(
                    child: SegmentButton(
                      title: "Vos Commandes",
                      isActive: isSubscription,
                      onPressed: () {
                        setState(() {
                          isSubscription = true;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: SegmentButton(
                      title: "Historique",
                      isActive: !isSubscription,
                      onPressed: () {
                        setState(() {
                          isSubscription = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (isSubscription || !isSubscription)
              FutureBuilder<Map<String, dynamic>>(
                future: Provider.of<OrderProvider>(context, listen: false)
                    .fetchOrderDetailsAsMap(widget.orderId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text("Error fetching order: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    return OrderWidget(
                      orderData: snapshot.data!,
                      onTap: () {
                        // Define what happens when the widget is tapped
                        // For example, navigate to an edit page
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  InvoicePage(orderData: snapshot.data!),
                            ));
                      },
                    );
                  } else {
                    return Center(child: Text("No order found"));
                  }
                },
              ),
           
            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }
}
