// ignore_for_file: camel_case_types, prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, unused_field, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payflexx/models/check_solvanbility_model.dart';
import 'package:payflexx/models/provider_model.dart';
import 'package:provider/provider.dart';
import '../../Controllers/providers/clientbankInfo_provider.dart';
import '../../Controllers/providers/providerinfo_provider.dart';
import '../../models/userbankinfo_model.dart';
import '../image_picker/camera_dialog.dart';
import '../text_style/title_text.dart';

class headWidgetProvider extends StatefulWidget {
  final String? providerName;
  final String? providerLogo;
  final String? providerPrice;
  final String? providerChecks;
  final String? providerCode;
  final String? productName;

  const headWidgetProvider({
    Key? key,
    this.providerName,
    this.providerLogo,
    this.providerPrice,
    this.providerChecks,
    this.providerCode,
    this.productName,
  }) : super(key: key);

  @override
  State<headWidgetProvider> createState() => _headWidgetProviderState();
}

class _headWidgetProviderState extends State<headWidgetProvider> {
  ProviderUserModel? providerUserModel;
  User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;

  Future<void> fetchUserInfo() async {
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      providerUserModel = await ProviderInfo().fetchProviderInfo();
    } catch (error) {
      await MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "An error has occurred $error",
        fct: () {},
      );
    } finally {
      _isLoading = false;
    }
  }

  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bonjour';
    } else if (hour < 17) {
      return 'Bonjour';
    } else {
      return 'Bonsoir';
    }
  }

  Future<int> countDocumentsInCollection(String collectionPath) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(user!.uid)
        .collection("orders")
        .get();
    int count = querySnapshot.size;
    return count;
  }

  ClientBankInfo? clientBankInfoModel;
  User? client = FirebaseAuth.instance.currentUser;
  int providerOrderCount = 0;

  @override
  void initState() {
    super.initState();
    fetchClientBankInfo();
    fetchUserInfo();
  }

  Future<String> countUniqueClients() async {
    Set<String> uniqueClientIds = {};
    var collectionRef = FirebaseFirestore.instance.collection('cheques');
    var snapshot = await collectionRef.get();
    for (var doc in snapshot.docs) {
      var cheque = ChequeModel.fromFirestore(doc);
      uniqueClientIds.add(cheque.clientId);
    }
    return uniqueClientIds.length.toString();
  }

  Future<void> fetchClientBankInfo() async {
    if (client == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final clientBankInfoProvider =
        Provider.of<ClientBankInfoProvider>(context, listen: false);
    try {
      clientBankInfoModel = await clientBankInfoProvider.fetchClientBankInfo();
    } catch (error) {
      await MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "An error has occurred: $error",
        fct: () {},
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              height: size.height * 0.36,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C), // Dark Grey-Blue
                border: Border.all(color: Color(0xFF9E9E9E)), // Grey
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 7),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: size.width * 0.15,
          left: size.width * 0.079,
          child: Container(
            height: size.height * 0.25,
            width: size.width * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E1E2C), // Dark Grey-Blue
                  const Color(0xFF4B4B61) // Medium Grey-Blue
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  offset: Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Text(
                    getGreeting(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  TitlesTextWidget(
                    label: providerUserModel?.providerName.toString() ?? '',
                    fontSize: 30.0,
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color(0xFF4B4B61), // Medium Grey-Blue
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.production_quantity_limits_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(width: 5),
                        FutureBuilder<int>(
                          future: countDocumentsInCollection("providers"),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Text(
                                'Vos commandes passées : ${snapshot.data}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
