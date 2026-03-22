// ignore_for_file: use_build_context_synchronously, await_only_futures, unnecessary_null_comparison, avoid_print

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:payflexx/root_screen.dart';
import '../../validators/My_validators.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:payflexx/services/ocr/RecognizationPageCheque.dart';
import 'package:payflexx/services/ocr/RecognizationPageSalary.dart';
import '../../Controllers/clientbankinfoController.dart';
import '../../models/userbankinfo_model.dart';
import '../../widgets/image_picker/camera_dialog.dart';
import '../../widgets/image_picker/pick_image_widget1.dart';
import '../../widgets/text_style/title_text.dart';

class BankInfoPage extends StatefulWidget {
  static const routName = '/BankInfoPage';
  const BankInfoPage({super.key});

  @override
  State<BankInfoPage> createState() => _BankInfoPageState();
}

class _BankInfoPageState extends State<BankInfoPage> {
  bool isUpdating =
      false; //var to know wether the user is updating his informayions or he's new!
  bool isSalaryVerified = false;
  bool isChequeVerified = false;
  //text editing controllers
  late TextEditingController numcompteController,
      salaryController,
      ribkeyController;

  String? _selectedBank;
  // Liste des banques (map pour le nom et le logo de la banque)
  List<Map<String, dynamic>> banks = [
    {"name": "AL BARKA", "logo": "assets/images/AL BARKA.png"},
    {"name": "Attijari Bank", "logo": "assets/images/attijaribank.png"},
    {"name": "ATB", "logo": "assets/images/atb.png"},
    {"name": "Amen Bank", "logo": "assets/images/amenbank.png"},
/************** */
    {"name": "BNA", "logo": "assets/images/bna_logo.png"},
    {"name": "BFPME", "logo": "assets/images/BFPME.png"},
    {"name": "BTE", "logo": "assets/images/BTE.png"},
    {"name": "BT", "logo": "assets/images/BT.png"},
    {"name": "BTK", "logo": "assets/images/BTK.png"},
    {"name": "BTL", "logo": "assets/images/BTL.png"},
    {"name": "BTS", "logo": "assets/images/BTS.png"},
    {"name": "BH", "logo": "assets/images/BH.png"},
    {"name": "Biat", "logo": "assets/images/BIAT.png"},
    /**************************************** */
    {"name": "QNB", "logo": "assets/images/QNB.png"},
    {"name": "STB", "logo": "assets/images/stb_logo.png"},
    {"name": "TSB", "logo": "assets/images/TSB.png"},
    {"name": "UBCI", "logo": "assets/images/UBCI.png"},
    {"name": "UIB", "logo": "assets/images/UIB.png"},
  ];
  final BankInfoController bankInfoController = BankInfoController();

  late final FocusNode numcompteFocusNode, salaryFocusNode, ribkeyFocusNode;

  late final _formKey = GlobalKey<FormState>();
  bool obscureText = true;
  XFile? pickedImage;
  XFile? pickedImage2;
  //fetchAndSetBankInfo method
  Future<void> fetchAndSetBankInfo() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot bankInfoSnapshot = await FirebaseFirestore.instance
          .collection('clientBankInfos')
          .doc(currentUser.uid)
          .get();

      setState(() {
        isUpdating = bankInfoSnapshot.exists;
        if (isUpdating) {
          Map<String, dynamic> bankInfoData =
              bankInfoSnapshot.data() as Map<String, dynamic>;
          numcompteController.text = bankInfoData['accountNumber'] ?? '';
          ribkeyController.text = bankInfoData['ribKey'] ?? '';
          salaryController.text = bankInfoData['salary'] ?? '';
          _selectedBank = bankInfoData['bankName'] ?? '';
          // Handle images if necessary
        }
      });
    }
  }

  @override
  //intialize the focus nodes and the controllers
  void initState() {
    //focus nodes

    numcompteFocusNode = FocusNode();
    salaryFocusNode = FocusNode();
    ribkeyFocusNode = FocusNode();

    // controllers

    numcompteController = TextEditingController();

    salaryController = TextEditingController();
    ribkeyController = TextEditingController();
//
    fetchAndSetBankInfo();
    super.initState();
  }

  @override
  // dispose the focus nodes and the controllers
  void dispose() {
    numcompteController.dispose();

    salaryController.dispose();
    ribkeyController.dispose();
    //focus nodes

    numcompteFocusNode.dispose();

    salaryFocusNode.dispose();
    ribkeyFocusNode.dispose();
    super.dispose();
  }

// local image for payslip
  Future<void> localImagefichepaie() async {
    final ImagePicker picker = ImagePicker();
    await MyAppMethods.imagePickerDialog(
      context: context,
      cameraFCT: () async {
        pickedImage = await picker.pickImage(source: ImageSource.camera);
        if (pickedImage != null) {
          navigateToRecognitionPage(pickedImage!.path);
        } else {
          handleImageNotPicked();
        }
        setState(() {});
      },
      galleryFCT: () async {
        pickedImage = await picker.pickImage(source: ImageSource.gallery);
        if (pickedImage != null) {
          navigateToRecognitionPage(pickedImage!.path);
        } else {
          // Handle the case where no image was picked
          handleImageNotPicked();
        }
        setState(() {});
      },
      removeFCT: () {
        setState(() {
          pickedImage = null;
        });
      },
    );
  }

  // local image for cheque
  Future<void> localImagecheque() async {
    final ImagePicker picker = ImagePicker();
    await MyAppMethods.imagePickerDialog(
      context: context,
      cameraFCT: () async {
        pickedImage2 = await picker.pickImage(source: ImageSource.camera);
        if (pickedImage2 != null) {
          navigateToRecognitionPageCheque(
              pickedImage2!.path, _selectedBank ?? "");
        } else {
          handleImageNotPicked();
        }
        setState(() {});
      },
      galleryFCT: () async {
        pickedImage2 = await picker.pickImage(source: ImageSource.gallery);
        if (pickedImage2 != null) {
          navigateToRecognitionPageCheque(
              pickedImage2!.path, _selectedBank ?? "");
        } else {
          handleImageNotPicked();
        }
        setState(() {});
      },
      removeFCT: () {
        setState(() {
          pickedImage2 = null;
        });
      },
    );
  }

  // navigate to the recognition page payslip
  Future<bool> navigateToRecognitionPage(String imagePath) async {
    String expectedSalary = salaryController.text;
    if (expectedSalary.isEmpty) {
      Fluttertoast.showToast(
        msg: "Veuillez saisir le salaire avant de continuer.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color.fromARGB(255, 12, 56, 43),
        textColor: Colors.white,
      );
      return false;
    }

    final verificationResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RecognizationPage(path: imagePath, expectedSalary: expectedSalary),
      ),
    );

    if (verificationResult != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Vérification du Salaire"),
            content: Text(verificationResult),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return true; // Verification successful
    }

    return false; // Verification failed
  }

  Future<bool> navigateToRecognitionPageCheque(
      String imagePath, String bankName) async {
    if (bankName.isEmpty) {
      Fluttertoast.showToast(
        msg: "Vous devez sélectionner le nom de la banque avant de continuer.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Color.fromARGB(255, 69, 100, 16),
        textColor: Colors.white,
      );
      return false;
    }

    final verificationResult = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecognizationPageCheque(
            path: imagePath, expectedBankName: bankName),
      ),
    );

    if (verificationResult != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Vérification du Nom Du Bank"),
            content: Text(verificationResult),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return true; // Verification successful
    }

    return false; // Verification failed
  }

  // Handle the case where no image was picked
  void handleImageNotPicked() {
    Fluttertoast.showToast(
        msg: "Aucune image sélectionnée",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: const Color.fromARGB(255, 63, 14, 63),
        textColor: Colors.white,
        fontSize: 20.0);
  }

  Future<void> submitBankInfo(
      BuildContext context, File? pickedImage, File? pickedImage2) async {
    if (!_formKey.currentState!.validate() ||
        pickedImage == null ||
        pickedImage2 == null) {
      Fluttertoast.showToast(
          msg:
              "Veuillez remplir tous les champs et sélectionner les deux images");
      return;
    }
    try {
      // Upload images and prepare bank info object as before
      String payslipUrl =
          await bankInfoController.uploadImage(pickedImage, 'payslips');
      String chequeUrl =
          await bankInfoController.uploadImage(pickedImage2, 'cheques');
      User? currentUser = FirebaseAuth.instance.currentUser;

      ClientBankInfo bankInfo = ClientBankInfo(
        clientId: currentUser!.uid,
        bankName: _selectedBank ?? "",
        accountNumber: numcompteController.text,
        ribKey: ribkeyController.text,
        paySlipImageUrl: payslipUrl,
        chequeImageUrl: chequeUrl,
        salary: salaryController.text.trim(),
      );

      // Saving or updating bank info
      await bankInfoController.saveBankInfo(bankInfo);
      Fluttertoast.showToast(
          msg: "Les informations bancaires ont été sauvegardées avec succès.");
      Navigator.pushReplacementNamed(context, RootScreen.routName);
    } catch (e) {
      // Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "An error has been occured ${e.toString()}",
          fct: () {
            Navigator.pop(context);
          });
    }
  }

// core of the page
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      " Veuillez remplir les détails bancaires pour continuer :",
                      style: TextStyle(
                        color: Color.fromARGB(255, 198, 148, 244),
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              // Form to fill in the bank details
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    //banks drop down menu list
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.account_balance,
                            color: Color.fromARGB(255, 198, 148, 244)),
                        labelText: "Sélectionnez votre banque",
                        labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 198, 148, 244)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      value: _selectedBank,
                      onChanged: (value) =>
                          setState(() => _selectedBank = value),
                      items: banks.map<DropdownMenuItem<String>>((bank) {
                        return DropdownMenuItem<String>(
                          value: bank["name"],
                          child: Row(
                            children: [
                              Image.asset(bank["logo"], width: 23, height: 23),
                              const SizedBox(width: 13),
                              Text(bank["name"]),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                    //Bank account number textfield

                    TextFormField(
                      controller: numcompteController,
                      focusNode: numcompteFocusNode,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: obscureText,
                      decoration: InputDecoration(
                        hintText: "Numéro de compte bancaire",
                        prefixIcon: const Icon(IconlyLight.wallet,
                            color: Color.fromARGB(255, 198, 148, 244)),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                          icon: Icon(obscureText
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                      validator: (value) =>
                          MyValidators.accountNumberValidator(value),
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(numcompteFocusNode);
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    // rib key textfield
                    TextFormField(
                      controller: ribkeyController,
                      focusNode: ribkeyFocusNode,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: "Clé RIB",
                        prefixIcon: Icon(IconlyLight.bag,
                            color: Color.fromARGB(255, 198, 148, 244)),
                      ),
                      validator: (value) => MyValidators.ribKeyValidator(value),
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(ribkeyFocusNode);
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    //Salary with DT textfield
                    TextFormField(
                      controller: salaryController,
                      focusNode: salaryFocusNode,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "Salaire Net en DT",
                        prefixIcon: Icon(IconlyLight.wallet,
                            color: Color.fromARGB(255, 198, 148, 244)),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    //PaySlip and Cheque blanche
                    const TitlesTextWidget(label: "Fiche de paie"),
                    // PaySlip image picker
                    SizedBox(
                      height: size.width * 0.5,
                      width: size.width * 0.5,
                      child: PickImageWidget(
                        pickedImage: pickedImage,
                        function: () async {
                          await localImagefichepaie();
                        },
                      ),
                    ),
                    //Blank Check
                    const TitlesTextWidget(label: "Chèque vierge"),

                    SizedBox(
                      height: size.width * 0.5,
                      width: size.width * 0.5,
                      child: PickImageWidget(
                        pickedImage: pickedImage2,
                        function: () async {
                          await localImagecheque();
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),
                    //Sign up button
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () async {
                            if (pickedImage == null || pickedImage2 == null) {
                              Fluttertoast.showToast(
                                msg:
                                    "Veuillez sélectionner une fiche de paie et un chèque vierge",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                backgroundColor:
                                    const Color.fromARGB(255, 198, 148, 244),
                                textColor: Colors.white,
                              );
                              return;
                            }

                            File? imageFile = pickedImage != null
                                ? File(pickedImage!.path)
                                : null;
                            File? imageFile2 = pickedImage2 != null
                                ? File(pickedImage2!.path)
                                : null;

                            // Verify salary and cheque first
                            if (!isSalaryVerified) {
                              isSalaryVerified =
                                  await navigateToRecognitionPage(
                                      imageFile!.path);
                            }

                            if (!isChequeVerified) {
                              isChequeVerified =
                                  await navigateToRecognitionPageCheque(
                                      imageFile2!.path, _selectedBank ?? "");
                            }

                            if (isSalaryVerified && isChequeVerified) {
                              // Call the submitBankInfo function
                              await submitBankInfo(
                                  context, imageFile, imageFile2);
                            } else {
                              Fluttertoast.showToast(
                                msg:
                                    "La vérification de la fiche de paie ou du chèque a échoué.",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                backgroundColor:
                                    const Color.fromARGB(255, 198, 148, 244),
                                textColor: Colors.white,
                              );
                            }
                          },
                          icon: const Icon(IconlyLight.addUser),
                          label: Text(
                            isUpdating ? "Mettre à jour" : "S'inscrire",
                            style: const TextStyle(fontSize: 20),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
