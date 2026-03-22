// ignore_for_file: camel_case_types, prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, unused_field, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payflexx/models/user_model.dart';
import 'package:payflexx/Controllers/providers/userinfo_provider.dart';
import 'package:payflexx/widgets/text_style/title_text.dart';
import 'package:provider/provider.dart';

import '../../models/userbankinfo_model.dart';
import '../../Controllers/providers/clientbankInfo_provider.dart';
import '../image_picker/camera_dialog.dart';

class headWidgetClient extends StatefulWidget {
  const headWidgetClient({super.key});

  @override
  State<headWidgetClient> createState() => _headWidgetClientState();
}

class _headWidgetClientState extends State<headWidgetClient> {
  UserModel? userModel;
  User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;
  Future<void> fetchUserInfo() async {
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      userModel = await userProvider.fetchUserInfo();
    } catch (error) {
      await MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Une erreur s'est produite : $error",
        fct: () {},
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  ClientBankInfo? clientBankInfoModel;
  User? client = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    fetchClientBankInfo();
    fetchUserInfo();
  }

  Future<void> fetchClientBankInfo() async {
    if (client == null) {
      // Corrected variable name
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
        subtitle: "Une erreur s'est produite : $error",
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
            //grey container
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
              //
              child: Stack(
                children: [
                  //greeting+username
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TitlesTextWidget(label: getGreeting()),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 7,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TitlesTextWidget(
                                  label: userModel?.userName.toString() ?? '',
                                ),
                              ],
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
        //black container
        Positioned(
          top: size.width * 0.22,
          left: size.width * 0.079,
          child: Container(
            height: size.height * 0.21,
            width: size.width * 0.8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E1E2C), // Dark Grey-Blue
                  const Color(0xFF4B4B61) // Medium Grey-Blue
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(126, 19, 68, 94),
                  offset: Offset(0, 6),
                  blurRadius: 12,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Solde Total',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 19,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 7),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FutureBuilder(
                        future: Provider.of<ClientBankInfoProvider>(context,
                                listen: false)
                            .fetchClientBankInfo(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator(); // Show loading indicator
                          }
                          if (snapshot.error != null) {
                            return Text('Une erreur s\'est produite'); // Error handling
                          }
                          return Consumer<ClientBankInfoProvider>(
                            builder: (ctx, data, child) => TitlesTextWidget(
                              label: '${data.getClientBankInfo?.salary} TND',
                              color: Colors.white,
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
