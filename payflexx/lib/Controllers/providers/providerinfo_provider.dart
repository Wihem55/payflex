// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/provider_model.dart';

class ProviderInfo with ChangeNotifier {
  ProviderUserModel? providerModel; // Provider user model

  // Getter to retrieve the provider user model
  ProviderUserModel? get getproviderModel {
    return providerModel;
  }

  // Function to fetch provider information from Firestore
  Future<ProviderUserModel?> fetchProviderInfo() async {
    final FirebaseAuth auth = FirebaseAuth.instance; // Firebase Auth instance
    User? user = auth.currentUser; // Get current user
    if (user == null) {
      return null; // Return null if no user is logged in
    }
    var uid = user.uid; // Get user ID
    try {
      // Get provider document from Firestore
      final providerDoc = await FirebaseFirestore.instance
          .collection("providers")
          .doc(uid)
          .get();
      final providerDocDict = providerDoc.data(); // Get document data
      // Create ProviderUserModel from document data
      providerModel = ProviderUserModel(
        providerId: providerDoc.get("providerId"),
        providerName: providerDoc.get('providerName'),
        email: providerDoc.get('email'),
        createdAt: providerDoc.get('CreatedAt'),
        phoneNumber: providerDoc.get('phoneNumber'),
        cin: providerDoc.get('cin'),
        dob: providerDoc.get('dob'),
        securityPinCode: providerDoc.get('securityPinCode'),
      );
      return providerModel; // Return provider model
    } on FirebaseException catch (error) {
      throw error.message.toString(); // Handle Firebase exception
    } catch (error) {
      rethrow; // Rethrow other exceptions
    }
  }
}
