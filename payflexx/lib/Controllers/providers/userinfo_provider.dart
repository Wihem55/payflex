// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? userModel; // User model

  // Getter to retrieve the user model
  UserModel? get getUserModel {
    return userModel;
  }

  // Function to fetch user information from Firestore
  Future<UserModel?> fetchUserInfo() async {
    final FirebaseAuth auth = FirebaseAuth.instance; // Firebase Auth instance
    User? user = auth.currentUser; // Get current user
    if (user == null) {
      return null; // Return null if no user is logged in
    }
    var uid = user.uid; // Get user ID
    try {
      // Get user document from Firestore
      final userDoc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
      final userDocDict = userDoc.data(); // Get document data
      if (userDocDict != null) {
        // Create UserModel from document data
        userModel = UserModel(
          userId: userDocDict["userId"] ?? '',
          userName: userDocDict["userName"] ?? '',
          userEmail: userDocDict['userEmail'] ?? '',
          createdAt: Timestamp.now(),
          phone: userDocDict['phoneNumber'] ?? '',
          cin: userDocDict['cin'] ?? '',
          dob: userDocDict['dob'] ?? '',
          securityPinCode: userDocDict['securityPinCode'] ?? '',
          userType: userDocDict['userType'] ?? '',
        );
        return userModel; // Return user model
      }
      return null; // Return null if user document is empty
    } on FirebaseException catch (error) {
      throw error.message.toString(); // Handle Firebase exception
    } catch (error) {
      rethrow; // Rethrow other exceptions
    }
  }
}
