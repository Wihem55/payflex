// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DeleteProviderPage extends StatefulWidget {
  @override
  _DeleteProviderPageState createState() => _DeleteProviderPageState();
}

class _DeleteProviderPageState extends State<DeleteProviderPage> {
  late List<DocumentSnapshot> providers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProviders();
  }

  void fetchProviders() async {
    var snapshot = await FirebaseFirestore.instance.collection('providers').get();
    setState(() {
      providers = snapshot.docs;
      isLoading = false;
    });
  }

  void deleteProvider(String providerId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Provider'),
          content: const Text('Are you sure you want to delete this provider? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('providers').doc(providerId).delete();
                Fluttertoast.showToast(msg: "Provider deleted successfully");
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                fetchProviders();  // Refresh the list after deletion
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Provider'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: providers.length,
              itemBuilder: (context, index) {
                var provider = providers[index];
                return ListTile(
                  title: Text(provider['providerName'] ?? 'No Name'),
                  subtitle: Text(provider['email'] ?? 'No Email'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteProvider(provider.id),
                  ),
                );
              },
            ),
    );
  }
}
