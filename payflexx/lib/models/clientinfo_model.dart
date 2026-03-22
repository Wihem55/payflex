import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String userName;
  final String userEmail;
  final String phone;
  final String dob; // Date of Birth
  final String cin; // National Identity Card number

  UserModel({
    required this.userId, // User ID
    required this.userName, // User Name
    required this.userEmail, // User Email
    required this.phone, // User Phone
    required this.dob, // User Date of Birth
    required this.cin, // User National Identity Card number
  });

  // Factory constructor to create a UserModel from a Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: doc.id, // Get document ID as userId
      userName: data['userName'] ?? '', // Get userName from Firestore document
      userEmail: data['userEmail'] ?? '', // Get userEmail from Firestore document
      phone: data['phone'] ?? '', // Get phone from Firestore document
      dob: data['dob'] ?? '', // Get date of birth from Firestore document
      cin: data['cin'] ?? '', // Get CIN from Firestore document
    );
  }

  // Method to convert UserModel to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userName': userName, // Set userName in Firestore document
      'userEmail': userEmail, // Set userEmail in Firestore document
      'phone': phone, // Set phone in Firestore document
      'dob': dob, // Set date of birth in Firestore document
      'cin': cin, // Set CIN in Firestore document
    };
  }
}
