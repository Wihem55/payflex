// ignore_for_file: camel_case_types, use_build_context_synchronously, non_constant_identifier_names, avoid_print

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:payflexx/screens/provider_screens/footer_provider.dart';

import '../widgets/image_picker/camera_dialog.dart';

class authProviderController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check Internet Connectivity
  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Register Provider
  Future<bool> registerProvider({
    required String email,
    required String password,
    required String providerName,
    required String phoneNumber,
    required String dob,
    required String cin,
    required String securityPinCode,
    String userType = 'provider',
    BuildContext? context,
  }) async {
    if (!await checkInternetConnectivity()) {
      MyAppMethods.showErrorORWarningDialog(
          context: context!,
          subtitle:
              "There was an error while trying to connect to the server!Please check your internet!",
          fct: () {
            SystemNavigator.pop();
          });
    }

    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = _auth.currentUser;
      final uid = user!.uid;
      // Ensure the password is not included in the Firestore document
      await FirebaseFirestore.instance.collection('providers').doc(uid).set({
        'providerId': uid,
        'email': email,
        'providerName': providerName,
        'phoneNumber': phoneNumber,
        'dob': dob,
        'cin': cin,
        'CreatedAt': Timestamp.now(),
        'userType': userType,
        'securityPinCode': securityPinCode,
      });
      Fluttertoast.showToast(
        msg: "An account has been created",
        toastLength: Toast.LENGTH_SHORT,
        textColor: Colors.white,
      );

      Navigator.pushReplacementNamed(context!, MainTabView.routName);
      return true;
// Successful registration
    } on FirebaseAuthException catch (e) {
      await MyAppMethods.showErrorORWarningDialog(
        context: context!,
        subtitle: "An error has been occured $e",
        fct: () {},
      );
      return false;
    }
  }

  Future<bool> registerProviderWithoutNavigation({
    required String email,
    required String password,
    required String providerName,
    required String phoneNumber,
    required String dob,
    required String cin,
    required String securityPinCode,
    String userType = 'provider',
    BuildContext? context,
  }) async {
    if (!await checkInternetConnectivity()) {
      MyAppMethods.showErrorORWarningDialog(
        context: context!,
        subtitle:
            "There was an error while trying to connect to the server!Please check your internet!",
        fct: () {
          SystemNavigator.pop();
        },
      );
      return false;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = _auth.currentUser;
      final uid = user!.uid;
      // Ensure the password is not included in the Firestore document
      await FirebaseFirestore.instance.collection('providers').doc(uid).set({
        'providerId': uid,
        'email': email,
        'providerName': providerName,
        'phoneNumber': phoneNumber,
        'dob': dob,
        'cin': cin,
        'CreatedAt': Timestamp.now(),
        'userType': userType,
        'securityPinCode': securityPinCode,
      });
      Fluttertoast.showToast(
        msg: "An account has been created",
        toastLength: Toast.LENGTH_SHORT,
        textColor: Colors.white,
      );
      return true; // Successful registration
    } on FirebaseAuthException catch (e) {
      await MyAppMethods.showErrorORWarningDialog(
        context: context!,
        subtitle: "An error has been occurred $e",
        fct: () {},
      );
      return false;
    }
  }

  // Login User
  Future<bool> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    if (!await checkInternetConnectivity()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No internet connection.")));
      return false;
    }

    try {
      print('Attempting login for email: $email'); // Debugging line
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('Login successful for email: $email'); // Debugging line
      return true; // Successful login
    } on FirebaseAuthException catch (e) {
      print(
          'Login failed for email: $email with error: ${e.message}'); // Debugging line
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(SnackBar(content: Text(e.message ?? "Login failed")));
      MyAppMethods.showErrorORWarningDialog(
          context: context, subtitle: '${e.message}', fct: () {});
      return false;
    }
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    if (!await checkInternetConnectivity()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No internet connection.")));
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset email sent.")));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message ?? "Error sending password reset email.")));
    }
  }
}
