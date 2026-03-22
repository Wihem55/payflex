import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderUserModel {
  String? email; // Email of the provider
  String? providerName; // Name of the provider
  String? phoneNumber; // Phone number of the provider
  String? dob; // Date of birth of the provider
  String? cin; // National Identity Card number of the provider
  String? securityPinCode; // Security PIN code of the provider
  String? providerId; // ID of the provider
  Timestamp? createdAt; // Timestamp of when the provider was created
  String? userType = 'provider'; // Type of user, default is 'provider'

  ProviderUserModel({
    this.createdAt, // Optional parameter for createdAt
    this.providerId, // Optional parameter for providerId
    this.email, // Optional parameter for email
    this.providerName, // Optional parameter for providerName
    this.phoneNumber, // Optional parameter for phoneNumber
    this.dob, // Optional parameter for dob
    this.cin, // Optional parameter for cin
    this.securityPinCode, // Optional parameter for securityPinCode
    this.userType, // Optional parameter for userType
  });

  // Method to convert ProviderUserModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'providerId': providerId, // Set providerId in Firestore document
      'createdAt': createdAt, // Set createdAt in Firestore document
      'email': email, // Set email in Firestore document
      'providerName': providerName, // Set providerName in Firestore document
      'phoneNumber': phoneNumber, // Set phoneNumber in Firestore document
      'dob': dob, // Set dob in Firestore document
      'cin': cin, // Set cin in Firestore document
      'securityPinCode': securityPinCode, // Set securityPinCode in Firestore document
      'userType': userType, // Set userType in Firestore document
    };
  }
}
