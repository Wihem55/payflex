// ignore_for_file: sized_box_for_whitespace, avoid_print, prefer_const_constructors_in_immutables, library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../Controllers/providers/fullorder_provider.dart';

class EmailSenderPage extends StatefulWidget {
  final String orderId;
  final String nbCheques;
  final List<DateTime> chequeDates;

  EmailSenderPage(
      {Key? key,
      required this.orderId,
      required this.chequeDates,
      required this.nbCheques})
      : super(key: key);

  @override
  _EmailSenderPageState createState() => _EmailSenderPageState();
}

class _EmailSenderPageState extends State<EmailSenderPage> {
  final List<Map<String, String>> banks = [
    {
      "name": "Attijaribank",
      "logo": "assets/images/attijaribank.png",
      "email": "relation.client@attijaribank.com.tn​ "
    },
    {
      "name": "ATB",
      "logo": "assets/images/atb.png",
      "email": "contact@atb.com.tn"
    },
    {
      "name": "Amen Bank",
      "logo": "assets/images/amenbank.png",
      "email": "crc@amenbank.com.tn"
    },
    {
      "name": "BNA",
      "logo": "assets/images/bna_logo.png",
      "email": "bna@bna.tn​"
    },
    {
      "name": "BFPME",
      "logo": "assets/images/BFPME.png",
      "email": "bfpme@bfpme.com.tn"
    },
    {
      "name": "BTE",
      "logo": "assets/images/BTE.png",
      "email": "elyes.chetoui@bte.com.tn"
    },
    {
      "name": "BT",
      "logo": "assets/images/BT.png",
      "email": "callcenter@bt.com.tn​"
    },
    {
      "name": "BTK",
      "logo": "assets/images/BTK.png",
      "email": "satisfaction.client@btknet.com"
    },
    {
      "name": "BTL",
      "logo": "assets/images/BTL.png",
      "email": "Banque Tuniso-Libyenne@btl.tn"
    },
    {
      "name": "BTS",
      "logo": "assets/images/BTS.png",
      "email": "bts@email.ati.tn"
    },
    {
      "name": "BH",
      "logo": "assets/images/BH.png",
      "email": "contact@bhbank.tn"
    },
    {
      "name": "Biat",
      "logo": "assets/images/BIAT.png",
      "email": "tre@biat.com.tn"
    },
    {
      "name": "QNB",
      "logo": "assets/images/QNB.png",
      "email": "bellil@tqb.com.tn"
    },
    {
      "name": "STB",
      "logo": "assets/images/stb_logo.png",
      "email": "stb@stb.com.tn"
    },
    {
      "name": "TSB",
      "logo": "assets/images/TSB.png",
      "email": "contact@tsb.com.tn"
    },
    {
      "name": "UBCI",
      "logo": "assets/images/UBCI.png",
      "email": "ubcireclamations@ubci.com.tn"
    },
    {
      "name": "UIB",
      "logo": "assets/images/UIB.png",
      "email": "uibcontact@uib.com"
    },
  ];

  Map<String, String>? selectedBank; // Selected bank for email
  List<File> scannedCheques = []; // List of scanned cheques

  // Function to scan cheques using the camera
  Future<void> scanCheques() async {
    final picker = ImagePicker();
    for (int i = 0; i < int.parse(widget.nbCheques); i++) {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        scannedCheques.add(File(pickedFile.path)); // Add scanned cheque to list
      }
    }
  }

  late Future<Map<String, dynamic>> orderDetailsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch order details once the widget is initialized
    orderDetailsFuture = Provider.of<OrderProvider>(context, listen: false)
        .fetchOrderDetailsAsMap(widget.orderId);
  }

  // Function to send email with order details, cheque dates, and scanned cheques
  Future<void> sendEmail1(Map<String, dynamic> orderDetails) async {
    final chequeDatesFormatted = widget.chequeDates
        .map((date) => "${date.toLocal()}".split(' ')[0])
        .join(', ');

    final email = Email(
      body:
          'Bonjour \n  Détails de la commande du client :${orderDetails['clientName']}\n Nom du produit : ${orderDetails['productName']}\n\n Quantité: ${orderDetails['quantity']}\nPrix: ${orderDetails['price']} TND\n\nDates des chèques : $chequeDatesFormatted\n\nVous trouverez ci-joint les chèques scannés.',
      subject:
          'Détails de votre commande pour ce produit ${orderDetails['productName']}',
      recipients: [selectedBank!['email']!], // Recipient email address
      attachmentPaths: scannedCheques
          .map((file) => file.path)
          .toList(), // Attach scanned cheques
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email); // Send the email
      print('Email sent!');
    } catch (error) {
      print('Error sending email: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Email to Bank'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            Center(
              child: Container(
                height: 200,
                width: MediaQuery.of(context).size.width *
                    0.8, // 80% of screen width
                child: Image.asset('assets/images/mail.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email, color: Colors.amber, size: 30),
                  SizedBox(width: 10),
                  Text(
                    'Nous allons envoyer un e-mail à :',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color.fromARGB(255, 79, 106, 12), width: 2),
                color: Colors.black54,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Map<String, String>>(
                  hint: const Text("Sélectionner la banque",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Color.fromARGB(255, 79, 106, 12), size: 30),
                  dropdownColor: Colors.black87,
                  items: banks.map((Map<String, String> bank) {
                    return DropdownMenuItem<Map<String, String>>(
                      value: bank,
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            bank['logo']!,
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            bank['name']!,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBank = value; // Set selected bank
                    });
                  },
                  value: selectedBank, // Current selected bank
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color.fromARGB(255, 79, 106, 12), width: 2),
                color: Colors.black54,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      "Nombre de chèques à scanner : ${widget.nbCheques}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await scanCheques(); // Scan cheques before sending email
                if (selectedBank != null) {
                  final orderDetails =
                      await orderDetailsFuture; // Fetch order details
                  await sendEmail1(orderDetails); // Send email
                } else {
                  print('Please select a bank first!');
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Envoyer Email',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
