import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  final String userId, // User ID
      userName, // User Name
      userEmail, // User Email
      phone, // User Phone
      dob, // User Date of Birth
      cin, // National Identity Card number
      securityPinCode, // Security PIN code
      userType; // Type of user
  final Timestamp createdAt; // Timestamp of when the user was created

  UserModel({
    required this.userId, // User ID
    required this.securityPinCode, // Security PIN code
    required this.userName, // User Name
    required this.userEmail, // User Email
    required this.createdAt, // Timestamp of when the user was created
    required this.phone, // User Phone
    required this.dob, // User Date of Birth
    required this.cin, // National Identity Card number
    required this.userType, // Type of user
  });

  // Factory constructor to create a UserModel from a Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: data['userId'] ?? '', // Get userId from Firestore document
      userName: data['userName'] ?? '', // Get userName from Firestore document
      userEmail: data['userEmail'] ?? '', // Get userEmail from Firestore document
      createdAt: data['createdAt'] as Timestamp, // Get createdAt from Firestore document
      phone: data['phoneNumber'] ?? '', // Get phoneNumber from Firestore document
      cin: data['cin'] ?? '', // Get cin from Firestore document
      dob: data['dob'] ?? '', // Get dob from Firestore document
      securityPinCode: data['securityPinCode'] ?? '', // Get securityPinCode from Firestore document
      userType: data['userType'] ?? '', // Get userType from Firestore document
    );
  }
}
