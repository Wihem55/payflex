// ignore_for_file: annotate_overrides, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/userbankinfo_model.dart'; 

class ClientBankInfoProvider with ChangeNotifier {
  ClientBankInfo? clientBankInfo; // Store the client bank info

  // Getter to retrieve the client bank info
  ClientBankInfo? get getClientBankInfo {
    return clientBankInfo;
  }

  // Method to fetch client bank info from Firestore
  Future<ClientBankInfo?> fetchClientBankInfo() async {
    final FirebaseAuth auth = FirebaseAuth.instance; // Firebase Auth instance
    User? user = auth.currentUser; // Get current user
    if (user == null) {
      return null; // Return null if no user is logged in
    }
    var uid = user.uid; // Get user ID
    try {
      // Get client bank info document from Firestore
      final clientBankInfoDoc = await FirebaseFirestore.instance
          .collection("clientBankInfos")
          .doc(uid)
          .get();
      final clientBankInfoData = clientBankInfoDoc.data(); // Get document data
      if (clientBankInfoData != null) {
        // Create ClientBankInfo object from document data
        clientBankInfo = ClientBankInfo(
          clientId: clientBankInfoData['clientId'] as String,
          bankName: clientBankInfoData['bankName'] as String,
          accountNumber: clientBankInfoData['accountNumber'] as String,
          ribKey: clientBankInfoData['ribKey'] as String,
          paySlipImageUrl: clientBankInfoData['paySlipImageUrl'] as String,
          chequeImageUrl: clientBankInfoData['chequeImageUrl'] as String,
          salary: clientBankInfoData['Salary'] as String,
        );
        notifyListeners(); // Notify listeners to update UI
      }
      return clientBankInfo; // Return the fetched client bank info
    } on FirebaseException catch (error) {
      throw Exception(error.message.toString()); // Handle Firebase exception
    } catch (error) {
      rethrow; // Rethrow other exceptions
    }
  }
}
