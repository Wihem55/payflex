import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:payflexx/models/check_solvanbility_model.dart';
import 'package:payflexx/models/clientinfo_model.dart';
import 'package:provider/provider.dart';
import 'package:payflexx/admin/widgets/custom_card.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payflexx/admin/model/dashboard_model.dart';
import 'package:payflexx/admin/Responsive.dart';

import '../../Controllers/providers/checksolvability_provider.dart';

class ActivityDetailsCard extends StatelessWidget {
  const ActivityDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChequeProvider>(builder: (context, chequeProvider, child) {
      final healthDetails = [
        HealthModel(
            icon: 'assets/svg/profile.svg',
            value: Future.value(countUniqueClients()),
            title: "NB° Clients"),
        HealthModel(
            icon: 'assets/svg/ic_user.svg',
            value: Future.value(countUsers()),
            title: "NB° Users"),
        HealthModel(
            icon: 'assets/svg/soil.svg',
            value: Future.value(
                countUniqueClients()), // Simulated value for solvable
            title: "NB° Solvable Clients"),
        HealthModel(
            icon: 'assets/svg/soil.svg',
            value: Provider.of<ChequeProvider>(context, listen: false)
                .fetchNonSolventClientsCount(),
            title: "NB° No-Solvable Clients"),
      ];

      return GridView.builder(
        itemCount: healthDetails.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
            crossAxisSpacing: !Responsive.isMobile(context) ? 15 : 12,
            mainAxisSpacing: 12.0),
        itemBuilder: (context, i) {
          return FutureBuilder<String>(
            future: healthDetails[i].value,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else {
                return CustomCard(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(healthDetails[i].icon),
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 4),
                        child: Text(
                          snapshot.data ?? "Loading",
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        healthDetails[i].title,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      );
    });
  }

  // Dummy function to simulate counting clients (replace with your actual function)
  Future<String> countUniqueClients() async {
    Set<String> uniqueClientIds = {}; // A set to store unique client IDs
    // Reference to the Firestore collection
    var collectionRef = FirebaseFirestore.instance.collection('cheques');
    // Fetch all documents in the collection
    var snapshot = await collectionRef.get();
    // Iterate over each document and add client ID to the set
    for (var doc in snapshot.docs) {
      var cheque = ChequeModel.fromFirestore(doc);
      uniqueClientIds.add(cheque.clientId);
    }
    return uniqueClientIds.length.toString(); // Convert count to string
  }

  Future<String> countUsers() async {
    Set<String> uniqueUserIds = {}; // A set to store unique client IDs
    // Reference to the Firestore collection
    var collectionRef = FirebaseFirestore.instance.collection('users');
    // Fetch all documents in the collection
    var snapshot = await collectionRef.get();
    // Iterate over each document and add client ID to the set
    for (var doc in snapshot.docs) {
      var user = UserModel.fromFirestore(doc);
      uniqueUserIds.add(user.userId);
    }
    return uniqueUserIds.length.toString(); // Convert count to string
  }
}
