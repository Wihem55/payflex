// ignore_for_file: unused_import, prefer_const_constructors, unused_local_variable, avoid_print, prefer_interpolation_to_compose_strings

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:payflexx/Controllers/providers/checksolvability_provider.dart';
import 'package:payflexx/Controllers/providers/clientbankInfo_provider.dart';
import 'package:payflexx/Controllers/providers/fullorder_provider.dart';
import 'package:payflexx/Controllers/providers/productDescription_provider.dart';
import 'package:payflexx/Controllers/providers/providerinfo_provider.dart';
import 'package:payflexx/screens/client_screens/adresse.dart';
import 'package:payflexx/screens/client_screens/update_userInfo.dart';
import 'package:payflexx/screens/client_screens/home_view_Client.dart';
import 'package:payflexx/screens/provider_screens/new_order.dart';
import 'package:payflexx/screens/welcome.dart';
import 'package:payflexx/widgets/image_picker/camera_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Colors/theme_data.dart';

import 'admin/Screens/dashboard.dart';
import 'models/productdescreption_model.dart';
import 'models/user_model.dart';
import 'Controllers/providers/theme_provider.dart';
import 'Controllers/providers/userinfo_provider.dart';

import 'root_screen.dart';
import 'screens/client_screens/loginClient.dart';
import 'screens/client_screens/ForgotPasswordPage.dart';
import 'screens/client_screens/bankinfopage.dart';
import 'screens/client_screens/signupclient.dart';
import 'screens/inner_screens/orders/orders_screen.dart';
import 'screens/provider_screens/forgetpassword_provider.dart';
import 'screens/provider_screens/home_view_provider.dart';
import 'screens/provider_screens/login_provider.dart';
import 'screens/provider_screens/signup_provider.dart';
import 'screens/provider_screens/score_solvability.dart';
import 'screens/provider_screens/footer_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

//----------------

void main() async {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  // await initializeDateFormatting();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyDPBzLSfCYb1bKt1WLQAL-Pbode2BgTMok',
            appId: '1:889533267136:android:bd4c9c056b3ab57681c125',
            messagingSenderId: '889533267136',
            projectId: 'payflexx-70a57',
            storageBucket: 'gs://payflexx-70a57.appspot.com',
          ),
        )
      : await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  // static void setLocale(BuildContext context, Locale newLocale) {
  //   print('Changing locale to $newLocale');
  //   _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
  //   if (state != null) {
  //     state.setLocale(newLocale);
  //   }
  // }

  @override
  State<MyApp> createState() => _MyAppState();
  // static void setLocale(BuildContext context, Locale newLocale) {
  //   _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
  //   state.setLocale(newLocale);
  // }
}

class _MyAppState extends State<MyApp> {
  late UserModel? userModel;
  // late Locale _locale;
  // void setLocale(Locale newLocale) {
  //   setState(() {
  //     _locale = newLocale;
  //   });
  //   MyApp.setLocale(context, newLocale); // Update the locale in MyApp
  // }

  // Future<void> _getSavedLocale() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final languageCode = prefs.getString('languageCode');
  //   final countryCode = prefs.getString('countryCode');
  //   if (languageCode != null && countryCode != null) {
  //     setLocale(Locale(languageCode, countryCode));
  //   }
  // }

  @override
  void initState() {
    // _getSavedLocale();
    fetchUserType();
    super.initState();
  }

  //
  Future<String?> fetchUserType() async {
    try {
      // Fetch the current user from Firebase Authentication
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Get the Firestore documents corresponding to the user from both collections
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        DocumentSnapshot providerDoc = await FirebaseFirestore.instance
            .collection('providers')
            .doc(user.uid)
            .get();

        String? userType;
        // Check if user document exists and retrieve userType from it
        if (userDoc.exists) {
          userType = userDoc.get('userType');
        }
        // If userType is not found in user document, check provider document
        if (userType == null && providerDoc.exists) {
          userType = providerDoc.get('userType');
        }

        if (userType != null) {
          print('User Type: $userType');
          return userType;
        } else {
          print('User Type is null');
          return null;
        }
      } else {
        print('No user signed in');
        return null;
      }
    } catch (error) {
      print('Error fetching user type: $error');
      return null;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Directionality(
              textDirection: TextDirection.ltr,
              child: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: Scaffold(
                body: Center(
                  child: SelectableText(
                      "An error has been occured ${snapshot.error}"),
                ),
              ),
            );
          }
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => ThemeProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => UserProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => ClientBankInfoProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => ProviderInfo(),
              ),
              ChangeNotifierProvider(
                create: (_) => ChequeProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => ProductProvider(),
              ),
              Provider<ProductDescriptionDataModel>(
                create: (_) => ProductDescriptionDataModel(),
              ),
              Provider<OrderProvider>(
                create: (_) => OrderProvider(),
              ),
              Provider<ProductDescriptionDataModel>(
                create: (_) => ProductDescriptionDataModel(),
              ),
            ],
            child: Consumer<ThemeProvider>(
              builder: (
                context,
                themeProvider,
                child,
              ) {
                return KeyedSubtree(
                  key: UniqueKey(),
                  child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'Payflexx',
                    theme: Styles.themeData(
                      isDarkTheme: themeProvider.getIsDarkTheme,
                      context: context,
                    ),
                    home: FutureBuilder<String?>(
                      future: fetchUserType(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // While waiting for the userType to be fetched, show a loading indicator
                          return SizedBox(
                            width:
                                50.0, // Set the size of CircularProgressIndicator
                            height: 50.0,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 4.0, // Adjust the stroke width
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue), // Set color
                              ),
                            ),
                          );
                        } else if (snapshot.hasError || snapshot.data == null) {
                          // If an error occurs or userType is null, show Welcome screen
                          return Welcome();
                        } else {
                          // If userType is fetched successfully, determine which screen to show
                          String userType = snapshot.data!;
                          if (userType == 'Client') {
                            // If userType is 'Client', show RootScreen
                            return RootScreen();
                          } else if (userType == 'provider') {
                            // If userType is anything else, show ProviderHomeView
                            return MainTabView();
                          } else if (userType == 'admin') {
                            // If userType is anything else, show ProviderHomeView
                            return DashBoard();
                          } else {
                            return CircularProgressIndicator.adaptive();
                          }
                        }
                      },
                    ),
                    routes: {
                      '/wlcm': (context) => Welcome(),
                      '/HomeViewProvider': (context) => HomeViewProvider(),
                      LoginScreen.routName: (context) => const LoginScreen(),
                      OrdersPage().routename: (context) => OrdersPage(),
                      RootScreen.routName: (context) => const RootScreen(),
                      '/ForgotPasswordPage': (context) =>
                          const ForgotPasswordPage(),
                      '/BankInfoPage': (context) => const BankInfoPage(),
                      '/SignUpClient': (context) => const SignUpClient(),
                      // provider pages

                      '/LoginProviderPage': (context) => LoginProviderPage(),
                      '/SignUpProviderPage': (context) =>
                          const SignUpProviderPage(),

                      '/ForgotPasswordProviderPage': (context) =>
                          const ForgotPasswordProviderPage(),

                      Welcome.routName: (context) => const Welcome(),
                      MainTabView.routName: (context) => const MainTabView(),
                      updateUserInfo.routName: (context) =>
                          const updateUserInfo(),
                      HomeScreen.routName: (context) => const HomeScreen(),
                      proceedCommand.routeName: (context) =>
                          const proceedCommand(),
                      DashBoard.routeName: (context) => DashBoard(),
                      AddressPage.routeName: (context) => AddressPage(),
                    },
                  ),
                );
              },
            ),
          );
        });
  }
}
