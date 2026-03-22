// ignore_for_file: avoid_print

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import '../../models/userbankinfo_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BankInfoController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File image, String folderPath) async {
    try {
      String fileName = path.basename(image.path);
      Reference ref = _storage.ref().child('$folderPath/$fileName');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Failed to upload image: ${e.toString()}");
    }
  }
// save bank info in fire store
  Future<void> saveBankInfo(ClientBankInfo bankInfo) async {
    try {
      await _db.collection('clientBankInfos').doc(bankInfo.clientId).set({
        ...bankInfo.toJson(),
        'lastUpdated':
            FieldValue.serverTimestamp(), 
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Failed to save bank info: ${e.toString()}");
    }
  }

  Future<bool> needsBankingInfoUpdate() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('clientBankInfos')
          .doc(currentUser.uid)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('lastUpdated')) {
          Timestamp lastUpdated = data['lastUpdated'] as Timestamp;
          DateTime lastUpdateDate = lastUpdated.toDate();
          DateTime twoMonthsAgo =
              DateTime.now().subtract(const Duration(days: 30));

          // Return true if the last update was more than two months ago
          return lastUpdateDate.isBefore(twoMonthsAgo);
        }
        return true; // Assume update is needed if 'lastUpdated' is not found
      }
    }
    return true; // Assume update is needed if user is not logged in or doc does not exist
  }
}
