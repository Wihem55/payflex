// ignore_for_file: camel_case_types, use_build_context_synchronously, file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:payflexx/widgets/image_picker/camera_dialog.dart';

class authClientController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register a new user
  Future<bool> registerUser({
    required String userEmail,
    required String password,
    required String userName,
    required String phone,
    required String dob,
    required String cin,
    required String securityPinCode,
    String userType = 'Client',
    BuildContext? context,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: userEmail, password: password);
      User? user = _auth.currentUser;
      final uid = user!.uid;
      // After user creation
      FirebaseAuth.instance.currentUser!.sendEmailVerification();
      Fluttertoast.showToast(
        msg: "A verification email Has been sent!",
        toastLength: Toast.LENGTH_SHORT,
        textColor: Colors.white,
      );
      // Ensure the password is not included in the Firestore document
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'userId': uid,
        'userEmail': userEmail,
        'userName': userName,
        'phoneNumber': phone,
        'dob': dob,
        'cin': cin,
        'securityPinCode': securityPinCode,
        'createdAt': Timestamp.now(),
        'userType': userType,
      });

      Fluttertoast.showToast(
        msg: "An account has been created",
        toastLength: Toast.LENGTH_SHORT,
        textColor: Colors.white,
      );
      navigator?.pushReplacementNamed('/BankInfoPage');
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

  // User login
  Future<bool> loginUser(
      {required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true; // Successfully signed in
    } catch (e) {
      
      return false;
    }
  }
  //update user info
  Future<bool> updateUserInfo({
    required String userId,
    String? userName,
    String? phone,
    String? dob,
    String? cin,
    String? securityPinCode,
    BuildContext? context,
  }) async {
    try {
      Map<String, dynamic> dataToUpdate = {};
      if (userName != null) dataToUpdate['userName'] = userName;
      if (phone != null) dataToUpdate['phoneNumber'] = phone;
      if (dob != null) dataToUpdate['dob'] = dob;
      if (cin != null) dataToUpdate['cin'] = cin;
      if (securityPinCode != null) dataToUpdate['securityPinCode'] = securityPinCode;
      await FirebaseFirestore.instance.collection('users').doc(userId).update(dataToUpdate);

      Fluttertoast.showToast(
        msg: "User information updated successfully!",
        toastLength: Toast.LENGTH_SHORT,
        textColor: Colors.white,
      );

      // Optionally navigate or refresh UI
      if (context != null) {
        Navigator.of(context).pop(); // Go back to the previous screen
      }

      return true; // Successfully updated user information
    } catch (e) {
      if (context != null) {
        await MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "An error occurred while updating user info: $e",
          fct: () {},
        );
      }
      return false; // Failed to update user information
    }
  }
}
