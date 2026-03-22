// ignore_for_file: camel_case_types, use_build_context_synchronously, unused_local_variable, no_leading_underscores_for_local_identifiers, avoid_print, unused_element
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:payflexx/Controllers/providers/fullorder_provider.dart';
import 'package:payflexx/Controllers/providers/productDescription_provider.dart';
import 'package:payflexx/validators/My_validators.dart';
import 'package:payflexx/widgets/Qr%20code/qrcode%20produit.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/productdescreption_model.dart';
import '../../widgets/text_style/title_text.dart';
import '../../models/check_solvanbility_model.dart';
import '../../models/fullOrder_model.dart';
import '../../Controllers/providers/checksolvability_provider.dart';
import '../../services/Managers/assets_manager.dart';
import 'score_solvability.dart';

Size getScreenSize(BuildContext context) {
  final mediaQueryData = MediaQuery.of(context).size;
  return mediaQueryData;
}

class proceedCommand extends StatefulWidget {
  static const routeName = '/NewOrderScreen';

  const proceedCommand({Key? key}) : super(key: key);

  @override
  State<proceedCommand> createState() => _proceedCommandState();
}

enum SolvabilityLevel { healthy, stable, risky }

class _proceedCommandState extends State<proceedCommand> {
  bool get wantKeepAlive => true;
  String? providerName;
  String? providerLogo;
  String? providerPrice;
  String? providerChecks;
  String? productName;
  String? providerCode;
  String? itemSalary;
  String? itemRef;
  bool isActive = false;
  String? clientId;
  String? clientName;
  String? clientSalary;
  String? nbcheques;
  String? productPrice;
  void clearDialogFields() {
    setState(() {
      providerName = null;
      providerLogo = null;
      providerPrice = null;
      providerChecks = null;
      productName = null;
      providerCode = null;
      itemSalary = null;
      itemRef = null;
      isActive = false;
      clientId = null;
      clientName = null;
      clientSalary = null;
      nbcheques = null;
      productPrice = null;
    });
  }

  // Helper function to show customized SnackBars
  void showCustomSnackBar(BuildContext context, String message,
      {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold), // Larger and bolder text
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating, // Makes it floating
        margin: const EdgeInsets.all(16), // Adds margin around SnackBar
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)), // Rounded corners
      ),
    );
  }

  void showAddProviderDialog(BuildContext context) {
    TextEditingController priceController = TextEditingController();
    TextEditingController checksController = TextEditingController();
    TextEditingController itemSalaryController = TextEditingController();
    TextEditingController userIDController = TextEditingController();
    TextEditingController userNameController = TextEditingController();
    final ImagePicker picker = ImagePicker();

    String extractUsername(String qrContent) {
      List<String> entries = qrContent.split(', ');

      String userNameEntry = entries.firstWhere(
          (entry) => entry.startsWith('UserName: '),
          orElse: () => 'UserName: Not Found');

      String userNameValue = userNameEntry.split(': ').last.trim();
      return userNameValue;
    }

    String extractSalary(String qrContent) {
      List<String> entries = qrContent.split(', ');

      String salaryEntry = entries.firstWhere(
          (entry) => entry.startsWith('Salary: '),
          orElse: () => 'Salary: Not Found');

      String salaryValue = salaryEntry.split(': ').last.trim();
      return salaryValue;
    }

    String extractUserID(String qrContent) {
      List<String> entries = qrContent.split(', ');

      String userIDEntry = entries.firstWhere(
          (entry) => entry.startsWith('UserID: '),
          orElse: () => 'UserID: Not Found');

      String userIDValue = userIDEntry.split(': ').last.trim();
      return userIDValue;
    }

    Future<void> pickAndProcessImage(
        BuildContext context,
        TextEditingController itemSalaryController,
        TextEditingController userIDController,
        TextEditingController userNameController) async {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final inputImage = InputImage.fromFilePath(image.path);
        final BarcodeScanner barcodeScanner =
            GoogleMlKit.vision.barcodeScanner();
        final List<Barcode> barcodes =
            await barcodeScanner.processImage(inputImage);

        if (barcodes.isNotEmpty) {
          String qrCodeContent = barcodes.first.displayValue ?? "";

          String salaryValue = extractSalary(qrCodeContent);
          String userIDValue = extractUserID(qrCodeContent);
          String userNameValue = extractUsername(qrCodeContent);

          if (salaryValue != 'Not Found') {
            itemSalaryController.text = salaryValue;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Salary not found in QR code")),
            );
          }

          if (userIDValue != 'Not Found') {
            userIDController.text = userIDValue;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("User ID not found in QR code")),
            );
          }

          if (userNameValue != 'Not Found') {
            userNameController.text = userNameValue;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Username not found in QR code")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No barcodes found in the image")));
        }
        await barcodeScanner.close();
      }
    }

    SolvabilityLevel _solvabilityLevel = SolvabilityLevel.risky;
    void checkSolvability(BuildContext context, ChequeModel cheque) async {
      double salary = double.tryParse(cheque.clientSalary) ?? 0;
      int checks = int.tryParse(cheque.nbCheques) ?? 0;
      double price = double.tryParse(cheque.articalPrice) ?? 0;

      if (checks == 0) checks = 1;
      double monthlyPayment = price / checks;
      double remainingSalaryPercentage =
          ((salary - monthlyPayment) / salary) * 100;
      double thresholdPercentage = 40.0;

      bool isSolvent = salary > monthlyPayment &&
          remainingSalaryPercentage >= thresholdPercentage;

      if (!isSolvent) {
        await Provider.of<ChequeProvider>(context, listen: false)
            .addNonSolventClient(cheque);
        showCustomSnackBar(
            context, "Client is not solvent. you can't add product .",
            backgroundColor: const Color.fromARGB(255, 107, 154, 19));
      } else {
        Provider.of<ChequeProvider>(context, listen: false)
            .addChequeToFirestore(
                clientId: cheque.clientId,
                articalPrice: cheque.articalPrice,
                clientName: cheque.clientName,
                clientSalary: cheque.clientSalary,
                nbCheques: cheque.nbCheques,
                visitDate: cheque.visitDate,
                context: context);

        showCustomSnackBar(context, "Client is solvent. you can add product .",
            backgroundColor: const Color.fromARGB(255, 107, 154, 19));
      }
    }

    String? selectedProvider;
    showDialog(
      useSafeArea: true,
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    'Ajouter des informations pour vérifier la solvabilité du client',
                    style: Theme.of(context).textTheme.headline6),
                const SizedBox(height: 15),
                TextField(
                  controller: userIDController,
                  decoration: const InputDecoration(
                      labelText: 'UserId',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(IconlyLight.paper)),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: userNameController,
                  decoration: const InputDecoration(
                      labelText: 'UserName',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(IconlyLight.paper)),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: itemSalaryController,
                  decoration: const InputDecoration(
                      labelText: 'Salaire (Dinar)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.wallet)),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => openQRScannerClient(
                          context,
                          itemSalaryController,
                          userIDController,
                          userNameController),
                      child: const Text('Scanner le code QR'),
                    ),
                    ElevatedButton(
                      onPressed: () => pickAndProcessImage(
                          context,
                          itemSalaryController,
                          userIDController,
                          userNameController),
                      child: const Text('Importer une image'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Prix total de l\'article (Dinar)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: checksController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de chèques',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit_attributes),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (priceController.text.isNotEmpty &&
                        checksController.text.isNotEmpty) {
                      int checks =
                          int.tryParse(checksController.text.trim()) ?? 0;
                      if (checks > 24) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Le nombre de chèques ne doit pas dépasser 24"),
                            duration: Duration(seconds: 3),
                          ),
                        );
                        return;
                      } else if (checks < 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Le nombre de chèques ne doit pas être inférieur à 1"),
                            duration: Duration(seconds: 3),
                          ),
                        );
                        return;
                      }

                      ChequeModel cheque = ChequeModel(
                        clientId: userIDController.text.trim(),
                        clientName: userNameController.text.trim(),
                        clientSalary: itemSalaryController.text.trim(),
                        articalPrice: priceController.text.trim(),
                        nbCheques: checksController.text.trim(),
                        visitDate: DateTime.now(),
                      );
                      clientId = userIDController.text.trim();
                      clientName = userNameController.text.trim();
                      clientSalary = itemSalaryController.text.trim();
                      nbcheques = checksController.text.trim();
                      productPrice = priceController.text.trim();
                      checkSolvability(context, cheque);
                      Future.delayed(
                        Durations.extralong1,
                        () => Navigator.pop(context),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all fields"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Vérifier la solvabilité'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

//*********************************************** */
  void showAddProductDesceptionDialog(BuildContext context) {
    // Desclartion des chapms

    TextEditingController priceController = TextEditingController();
    TextEditingController itemNameController = TextEditingController();
    TextEditingController itemCodeController = TextEditingController();
    TextEditingController itemDescreptionController = TextEditingController();
    TextEditingController itemRefController = TextEditingController();
    TextEditingController itemQetController = TextEditingController();
    TextEditingController adresseController = TextEditingController();

    final ImagePicker picker = ImagePicker();
    String? selectedProvider;

    List<Map<String, String>> providers = [
      {"name": "Mytek", "image": "assets/images/mytek.png"},
      {"name": "Tunisianet", "image": AssetsManager.tunisianet},
      {"name": "Spacenet", "image": AssetsManager.spacenet},
      {"name": "Poulina", "image": AssetsManager.poulina},
      {"name": "IPEC Tunisie", "image": "assets/images/IPEC Tunisie.png"},
    ];

    Future<void> pickAndProcessImage(
        BuildContext context, TextEditingController itemCodeController) async {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final inputImage = InputImage.fromFilePath(image.path);
        final BarcodeScanner barcodeScanner =
            GoogleMlKit.vision.barcodeScanner();
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

    showDialog(
      context: context,
      builder: (context) {
        double availableHeight = MediaQuery.of(context).size.height -
            MediaQuery.of(context).viewInsets.bottom -
            MediaQuery.of(context).padding.top - // status bar height
            MediaQuery.of(context).padding.bottom;
        return Dialog(
          insetPadding: const EdgeInsets.all(8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: availableHeight * 0.9),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ajouter une description de produit',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    padding: const EdgeInsets.all(2.0),
                    decoration: const InputDecoration(
                      hintText: 'Sélectionner le fournisseur',
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
                              width: MediaQuery.of(context).size.width * 0.1,
                              height: MediaQuery.of(context).size.width * 0.1,
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
                      labelText: 'Adresses',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.woo_commerce),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: itemNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du produit',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.woo_commerce),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: itemRefController,
                    decoration: const InputDecoration(
                      labelText: 'Référence du produit',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.room_preferences),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: itemQetController,
                    decoration: const InputDecoration(
                      labelText: 'Quantité de produit',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.production_quantity_limits),
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            openQRScanner(context, itemCodeController),
                        child: const Text('Scanner le code QR'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            pickAndProcessImage(context, itemCodeController),
                        child: const Text('Importer une image'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: itemDescreptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description des produits',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.production_quantity_limits),
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
                      labelText: 'Retaper prix total',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (selectedProvider != null &&
                          priceController.text.isNotEmpty &&
                          itemDescreptionController.text.isNotEmpty &&
                          itemNameController.text.isNotEmpty &&
                          itemCodeController.text.isNotEmpty &&
                          itemRefController.text.isNotEmpty &&
                          itemQetController.text.isNotEmpty &&
                          adresseController.text.isNotEmpty) {
                        FullOrderModel newOrder = FullOrderModel(
                          chequeDates: [],
                          timestamp: DateTime.now(),
                          orderID: const Uuid().v4(),
                          clientId: clientId,
                          clientName: clientName,
                          clientSalary: clientSalary,
                          price: productPrice,
                          productName: itemNameController.text,
                          productDescription: itemDescreptionController.text,
                          code: itemCodeController.text,
                          productRef: itemRefController.text,
                          adresse: adresseController.text,
                          quantity: itemQetController.text,
                          providerSelected: selectedProvider,
                          productId: clientId,
                          articalPrice: priceController.text.trim(),
                          nbCheques: nbcheques,
                        );
                        ProductDescriptionDataModel product =
                            ProductDescriptionDataModel(
                          price: productPrice,
                          productName: itemNameController.text,
                          productDescription: itemDescreptionController.text,
                          code: itemCodeController.text,
                          productRef: itemRefController.text,
                          adresse: adresseController.text,
                          quantity: itemQetController.text,
                          providerSelected: selectedProvider,
                          productId: clientId,
                        );
                        Provider.of<ProductProvider>(context, listen: false)
                            .addProductToFirestore(product);
                        Provider.of<OrderProvider>(context, listen: false)
                            .addOrderToFirebase(newOrder, newOrder.orderID)
                            .then((_) {
                          Provider.of<ChequeProvider>(context, listen: false)
                              .setCurrentClientId(clientId);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeView(
                                    clientId: clientId,
                                    orderId: newOrder.orderID),
                              ));
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Failed to add product: $error')));
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                "Please fill all fields and select a provider")));
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Enregistrer le produit'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TitlesTextWidget(
          label: 'Nouvelle commande',
        ),
      ),
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.spaceEvenly, // Ensures even spacing vertically
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () {
                showAddProviderDialog(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeIn,
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF00796B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 30),
                    SizedBox(width: 10),
                    Text("Vérifier la solvabilité du client",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () {
                showAddProductDesceptionDialog(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeIn,
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2540),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.settings_applications,
                        color: Colors.white, size: 30),
                    SizedBox(width: 10),
                    Text("Ajouter des détails sur le produit",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              onTap: () {
                clearDialogFields();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeIn,
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                decoration: BoxDecoration(
                  color: const Color(
                      0xFF1A5276), // Light Blue color matching Smart Eco theme
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, color: Colors.white, size: 30),
                    SizedBox(width: 10),
                    Text("Effacer",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
