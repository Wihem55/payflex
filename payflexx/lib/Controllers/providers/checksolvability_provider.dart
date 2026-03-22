// ignore_for_file: unused_local_variable, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payflexx/models/check_solvanbility_model.dart';
import 'package:uuid/uuid.dart';

class ChequeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  final List<ChequeModel> _nonSolventClients = []; // List to store non-solvent clients

  // Function to add a cheque to Firestore
  Future<void> addChequeToFirestore({
    required String clientId,
    required String clientName,
    required String clientSalary,
    required String articalPrice,
    required String nbCheques,
    required DateTime visitDate,
    required BuildContext context,
  }) async {
    final User? user = _auth.currentUser; // Get current user
    if (user == null) {
      return;
    }
    final String uid = user.uid;
    final chequeId = const Uuid().v4(); // Generate a unique ID for the cheque
    try {
      await _firestore.collection('cheques').doc(clientId).set({
        'clientId': clientId,
        'clientName': clientName,
        'clientSalary': clientSalary,
        'articalPrice': articalPrice,
        'nbCheques': nbCheques,
        'visitDate': Timestamp.fromDate(visitDate),
      });
      notifyListeners(); // Notify listeners to update UI
    } catch (e) {
      rethrow; // Rethrow the error
    }
  }

  // Function to fetch cheque details from Firestore
  Future<Map<String, dynamic>?> fetchChequeDetailsFromFirestore(
      String clientId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('cheques').doc(clientId).get();
      if (!doc.exists) {
        print("No such document!");
        return null; 
      }
      Map<String, dynamic> chequeDetails = {
        'clientId': doc.get('clientId') ?? '',
        'clientName': doc.get('clientName') ?? '',
        'clientSalary': doc.get('clientSalary') ?? '',
        'articalPrice': doc.get('articalPrice') ?? '',
        'nbCheques': doc.get('nbCheques') ?? '',
        'visitDate': (doc.get('visitDate') as Timestamp).toDate(),
      };
      return chequeDetails;
    } on FirebaseException catch (e) {
      print("Failed with error '${e.message}'");
      rethrow; 
    } catch (e) {
      print("Failed with error '$e'");
      rethrow; 
    }
  }

  String? _currentClientId;

  // Set the current client ID
  void setCurrentClientId(String? clientId) {
    _currentClientId = clientId;
    notifyListeners(); // Notify listeners to update UI
  }

  // Get the current client ID
  String getCurrentClientId() {
    return _currentClientId!;
  }

  // Function to add a non-solvent client to Firestore
  Future<void> addNonSolventClient(ChequeModel cheque) async {
    try {
      await _firestore
          .collection('nonSolventClients')
          .doc(cheque.clientId)
          .set({
        'clientId': cheque.clientId,
        'clientName': cheque.clientName,
        'clientSalary': cheque.clientSalary,
        'articalPrice': cheque.articalPrice,
        'nbCheques': cheque.nbCheques,
        'isNonSolvent': true, // Mark the client as non-solvent
      });
      notifyListeners(); // Notify listeners to update UI
    } catch (e) {
      print("Error adding non-solvent client: $e");
      rethrow;
    }
  }

  // Function to fetch the count of non-solvent clients from Firestore
  Future<String> fetchNonSolventClientsCount() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('nonSolventClients').get();
      return querySnapshot.docs.length.toString(); // Return the count of documents
    } catch (e) {
      print("Error fetching non-solvent clients count: $e");
      return "0".toString(); // Return 0 if an error occurs
    }
  }

  int get nonSolventClientsCount => _nonSolventClients.length;

  // This method fetches the count of cheques per month for the current year
  Future<Map<String, int>> fetchChequesCountPerMonth() async {
    Map<String, int> monthlyCounts = {};
    try {
      for (int month = 1; month <= 12; month++) {
        var startDate = DateTime(DateTime.now().year, month, 1);
        var endDate = DateTime(DateTime.now().year, month + 1, 0);

        var querySnapshot = await _firestore
            .collection('cheques')
            .where('visitDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .where('visitDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
            .get();

        monthlyCounts[month.toString()] = querySnapshot.docs.length;
      }
      notifyListeners();
      return monthlyCounts;
    } catch (e) {
      print("Error fetching monthly cheques count: $e");
      return {};
    }
  }
}
