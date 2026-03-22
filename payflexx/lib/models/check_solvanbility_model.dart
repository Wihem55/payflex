import 'package:cloud_firestore/cloud_firestore.dart';

class ChequeModel {
  final String clientId, clientName, clientSalary, articalPrice, nbCheques;
  final DateTime visitDate;

  ChequeModel({
    required this.clientId, // Client ID
    required this.clientName, // Client Name
    required this.clientSalary, // Client Salary
    required this.articalPrice, // Article Price
    required this.nbCheques, // Number of Cheques
    required this.visitDate, // Visit Date
  });

  // Factory constructor to create a ChequeModel from a Firestore document
  factory ChequeModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChequeModel(
      clientId: data['clientId'] ?? '', // Get client ID from Firestore document
      clientName: data['clientName'] ?? '', // Get client name from Firestore document
      clientSalary: data['clientSalary'] ?? '', // Get client salary from Firestore document
      articalPrice: data['articalPrice'] ?? '', // Get article price from Firestore document
      nbCheques: data['nbCheques'] ?? '', // Get number of cheques from Firestore document
      visitDate: (data['visitDate'] as Timestamp).toDate(), // Convert Firestore Timestamp to DateTime
    );
  }
}
