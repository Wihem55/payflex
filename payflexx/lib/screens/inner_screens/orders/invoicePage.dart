// ignore_for_file: file_names, non_constant_identifier_names, avoid_print, sized_box_for_whitespace
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import '../checkdate_screen.dart';
import 'package:payflexx/services/Managers/assets_manager.dart';
import 'package:provider/provider.dart';

import '../../../Controllers/providers/checksolvability_provider.dart';
import '../../../Controllers/providers/fullorder_provider.dart';
import '../../../models/fullOrder_model.dart';
import '../../../widgets/Qr code/qrcode produit.dart';

class InvoicePage extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const InvoicePage({
    required this.orderData,
    Key? key,
  }) : super(key: key);

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  Future<String?> fetchUserType() async {
    try {
      // Fetch the current user from Firebase Authentication
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Get the Firestore documents corresponding to the user from both collections
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        DocumentSnapshot providerDoc = await FirebaseFirestore.instance
            .collection('providers')
            .doc(user.uid)
            .get();

        String? userType;
        // Check if user document exists and retrieve userType from it
        if (userDoc.exists) {
          userType = userDoc.get('userType');
        }
        // If userType is not found in user document, check provider document
        if (userType == null && providerDoc.exists) {
          userType = providerDoc.get('userType');
        }

        if (userType != null) {
          print('User Type: $userType');
          return userType;
        } else {
          print('User Type is null');
          return null;
        }
      } else {
        print('No user signed in');
        return null;
      }
    } catch (error) {
      print('Error fetching user type: $error');
      return null;
    }
  }

  List<Map<String, String>> providers = [
    {"name": "Mytek", "image": "assets/images/mytek.png"},
    {"name": "Tunisianet", "image": AssetsManager.tunisianet},
    {"name": "Spacenet", "image": AssetsManager.spacenet},
    {"name": "Poulina", "image": AssetsManager.poulina},
    {"name": "IPEC Tunisie", "image": "assets/images/IPEC Tunisie.png"},
  ];
  bool isActive = false;
  String? selectedProvider;

  TextEditingController priceController = TextEditingController();

  TextEditingController itemNameController = TextEditingController();

  TextEditingController itemCodeController = TextEditingController();

  TextEditingController itemDescreptionController = TextEditingController();

  TextEditingController itemRefController = TextEditingController();

  TextEditingController itemQetController = TextEditingController();

  TextEditingController adresseController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  Future<void> pickAndProcessImage(
      BuildContext context, TextEditingController itemCodeController) async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final inputImage = InputImage.fromFilePath(image.path);
      final BarcodeScanner barcodeScanner = GoogleMlKit.vision.barcodeScanner();
      final List<Barcode> barcodes =
          await barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        itemCodeController.text = barcodes.first.displayValue ?? "";
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No barcodes found in the image")));
      }
      await barcodeScanner.close();
    }
  }

  late String orderId;
  late String ClientId;
  late String ClientName;
  late String ClientSalary;
  late String nbcheques;

  @override
  void initState() {
    super.initState();
    orderId = widget.orderData['orderID'];
    ClientId = widget.orderData['clientId'];
    ClientName = widget.orderData['clientName'];
    ClientSalary = widget.orderData['clientSalary'];
    nbcheques = widget.orderData['nbCheques'];
    priceController.text = widget.orderData['articalPrice'];
    itemNameController.text = widget.orderData['productName'];
    itemCodeController.text = widget.orderData['code'];
    itemDescreptionController.text = widget.orderData['productDescription'];
    itemRefController.text = widget.orderData['productRef'];
    itemQetController.text = widget.orderData['quantity'];
    adresseController.text = widget.orderData['adresse'];
    selectedProvider = widget.orderData['providerSelected'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facture'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: <Widget>[
          FutureBuilder<String?>(
            future: fetchUserType(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show a loading indicator while waiting for userType to be fetched
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError || snapshot.data == null) {
                // Show Welcome screen if an error occurs or userType is null
                return const Text('');
              } else {
                // If userType is fetched successfully, determine which buttons to show
                String userType = snapshot.data!;
                if (userType == 'provider') {
                  // If userType is 'provider', show the buttons
                  return Row(
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          Provider.of<OrderProvider>(context, listen: false)
                              .deleteOrder(
                                  context, widget.orderData['orderID']);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                double availableHeight = MediaQuery.of(context)
                                        .size
                                        .height -
                                    MediaQuery.of(context).viewInsets.bottom -
                                    MediaQuery.of(context)
                                        .padding
                                        .top - // status bar height
                                    MediaQuery.of(context).padding.bottom;
                                return Dialog(
                                  insetPadding: const EdgeInsets.all(8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxHeight: availableHeight * 0.9),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                              'Ajouter une description de produit',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge),
                                          const SizedBox(height: 15),
                                          DropdownButtonFormField<String>(
                                            padding: const EdgeInsets.all(2.0),
                                            decoration: const InputDecoration(
                                              hintText:
                                                  'S\u00E9lectionner le fournisseur',
                                              border: OutlineInputBorder(),
                                              prefixIcon: Icon(Icons.business),
                                            ),
                                            items: providers.map((provider) {
                                              return DropdownMenuItem(
                                                value: provider["name"],
                                                child: Row(
                                                  children: [
                                                    Image.asset(
                                                      provider["image"]!,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.1,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.1,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(provider["name"]!),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              selectedProvider = value;
                                            },
                                            value: selectedProvider,
                                          ),
                                          const SizedBox(height: 15),
                                          TextField(
                                            controller: adresseController,
                                            decoration: const InputDecoration(
                                              labelText: 'Adresse',
                                              border: OutlineInputBorder(),
                                              prefixIcon:
                                                  Icon(Icons.woo_commerce),
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          TextField(
                                            controller: itemNameController,
                                            decoration: const InputDecoration(
                                              labelText: 'Nom du produit',
                                              border: OutlineInputBorder(),
                                              prefixIcon:
                                                  Icon(Icons.woo_commerce),
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          TextField(
                                            controller: itemRefController,
                                            decoration: const InputDecoration(
                                              labelText:
                                                  'R\u00E9A9f\u00E9A9rence du produit',
                                              border: OutlineInputBorder(),
                                              prefixIcon:
                                                  Icon(Icons.room_preferences),
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          TextField(
                                            controller: itemQetController,
                                            decoration: const InputDecoration(
                                              labelText:
                                                  'Quantit\u00E9  de produit',
                                              border: OutlineInputBorder(),
                                              prefixIcon: Icon(Icons
                                                  .production_quantity_limits),
                                            ),
                                            keyboardType: TextInputType.number,
                                          ),
                                          const SizedBox(height: 15),
                                          TextField(
                                            controller: itemCodeController,
                                            decoration: const InputDecoration(
                                              labelText: 'Code produit',
                                              border: OutlineInputBorder(),
                                              prefixIcon: Icon(Icons.code),
                                            ),
                                            keyboardType: TextInputType.number,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () => openQRScanner(
                                                    context,
                                                    itemCodeController),
                                                child: const Text(
                                                    'Scanner le code QR'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    pickAndProcessImage(context,
                                                        itemCodeController),
                                                child: const Text(
                                                    'Importer une image'),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          TextField(
                                            controller:
                                                itemDescreptionController,
                                            decoration: const InputDecoration(
                                              labelText:
                                                  'Description du produit',
                                              border: OutlineInputBorder(),
                                              prefixIcon: Icon(Icons
                                                  .production_quantity_limits),
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          SwitchListTile(
                                            secondary: Image.asset(
                                              AssetsManager.tva,
                                              height: 30,
                                            ),
                                            title: const Text('TVA'),
                                            value: isActive,
                                            onChanged: (value) {
                                              setState(() {
                                                isActive = value;
                                              });
                                            },
                                          ),
                                          const SizedBox(height: 20),
                                          TextField(
                                            controller: priceController,
                                            decoration: const InputDecoration(
                                              labelText: ' Prix total ',
                                              border: OutlineInputBorder(),
                                              prefixIcon:
                                                  Icon(Icons.attach_money),
                                            ),
                                            keyboardType: TextInputType.number,
                                          ),
                                          const SizedBox(height: 20),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              if (selectedProvider != null &&
                                                  priceController
                                                      .text.isNotEmpty &&
                                                  itemDescreptionController
                                                      .text.isNotEmpty &&
                                                  itemNameController
                                                      .text.isNotEmpty &&
                                                  itemCodeController
                                                      .text.isNotEmpty &&
                                                  itemRefController
                                                      .text.isNotEmpty &&
                                                  itemQetController
                                                      .text.isNotEmpty &&
                                                  adresseController
                                                      .text.isNotEmpty) {
                                                FullOrderModel updatedOrder =
                                                    FullOrderModel(
                                                  chequeDates: [],
                                                  timestamp: DateTime.now(),
                                                  orderID: orderId,
                                                  clientId: ClientId,
                                                  clientName: ClientName,
                                                  clientSalary: ClientSalary,
                                                  price: priceController.text
                                                      .trim(),
                                                  productName:
                                                      itemNameController.text,
                                                  productDescription:
                                                      itemDescreptionController
                                                          .text,
                                                  code: itemCodeController.text,
                                                  productRef:
                                                      itemRefController.text,
                                                  adresse:
                                                      adresseController.text,
                                                  quantity:
                                                      itemQetController.text,
                                                  providerSelected:
                                                      selectedProvider,
                                                  productId: ClientId,
                                                  articalPrice:
                                                      priceController.text,
                                                  nbCheques: nbcheques,
                                                );

                                                Map<String, dynamic>
                                                    updatedData =
                                                    updatedOrder.toJson();

                                                Provider.of<OrderProvider>(
                                                  context,
                                                  listen: false,
                                                )
                                                    .updateOrder(orderId,
                                                        updatedData, context)
                                                    .then((_) {
                                                  Provider.of<ChequeProvider>(
                                                    context,
                                                    listen: false,
                                                  ).setCurrentClientId(
                                                      ClientId);
                                                  Navigator.pop(context);
                                                }).catchError((error) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Failed to update product: $error'),
                                                    ),
                                                  );
                                                });
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        "Please fill all fields and select a provider"),
                                                  ),
                                                );
                                              }
                                            },
                                            icon: const Icon(Icons.add),
                                            label: const Text('Mettre Ã  jour'),
                                            style: ElevatedButton.styleFrom(
                                              minimumSize:
                                                  const Size.fromHeight(50),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                    ],
                  );
                } else {
                  // If userType is not 'provider', don't show any buttons
                  return const SizedBox.shrink();
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                height: 100,
                child: Image.asset(AssetsManager
                    .investment), // Use Image.network if your image is hosted online
              ),
            ),
            Text(
              'Nom de l\'entreprise du fournisseur : ${widget.orderData['providerSelected']}', // Adjust key as per your order data
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Nom du client : ${widget.orderData['clientName']}', // Adjust key as per your order data
              style: const TextStyle(fontSize: 18),
            ),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'D\u00E9tails du produit :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ProductCard(
              productRef: widget.orderData['productRef'],
              productCode: widget.orderData['code'],
              productName: widget.orderData['productName'],
              productDescription: widget.orderData['productDescription'],
              productPrice: widget.orderData['price'],
              quantity: widget.orderData['quantity'],
              nbcheques: widget.orderData['nbCheques'],
            ),
            // Add more ProductCard widgets for more products
            const SizedBox(height: 20),
            TotalSection(
                total: widget
                    .orderData['price']), // Adjust key as per your order data
            const SizedBox(height: 20),
            FutureBuilder<String?>(
              future: fetchUserType(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While waiting for the userType to be fetched, show a loading indicator
                  return const SizedBox(
                    width: 50.0, // Set the size of CircularProgressIndicator
                    height: 50.0,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 4.0, // Adjust the stroke width
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue), // Set color
                      ),
                    ),
                  );
                } else if (snapshot.hasError || snapshot.data == null) {
                  // If an error occurs or userType is null, show Welcome screen
                  return const Text('');
                } else {
                  // If userType is fetched successfully, determine which screen to show
                  String userType = snapshot.data!;
                  if (userType == 'Client') {
                    // If userType is 'Client', show RootScreen
                    return const Text('');
                  } else if (userType == 'provider') {
                    // If userType is anything else, show ProviderHomeView
                    return Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChequeDatePage(
                                orderId: widget.orderData['orderID'],
                                clientId: widget.orderData['clientId'],
                                nbcheques: widget.orderData['nbCheques'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF003366), // Dark Blue
                                Color(0xFF48A999), // Teal
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 20),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_right,
                                    color: Colors.white, size: 25),
                                SizedBox(width: 15),
                                Text(
                                  "l'Etape Suivante",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator.adaptive();
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String productRef;
  final String productCode;
  final String productName;
  final String productDescription;
  final String productPrice;
  final String quantity;
  final String nbcheques;

  const ProductCard({
    Key? key,
    required this.productRef,
    required this.productCode,
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    required this.quantity,
    required this.nbcheques,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.vpn_key),
              title: Text('Ref: $productRef'),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: Text('Code: $productCode'),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: Text('Nom de produit: $productName'),
            ),
            ListTile(
              leading: const Icon(Icons.description_rounded),
              title: Text('Description: $productDescription'),
            ),
            ListTile(
              leading: const Icon(Icons.production_quantity_limits),
              title: Text('Quantit\u00E9: $quantity'),
            ),
            ListTile(
              leading: const Icon(Icons.production_quantity_limits),
              title: Text('Nombre de ch\u00E9ques: $nbcheques'),
            ),
          ],
        ),
      ),
    );
  }
}

class TotalSection extends StatelessWidget {
  final String total;

  const TotalSection({
    Key? key,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(AssetsManager
          .total), // Use Image.network if your image is hosted online
      title: Text('Total: $total',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      tileColor: const Color.fromARGB(255, 70, 70, 70),
    );
  }
}
