// ignore_for_file: use_build_context_synchronously, camel_case_types

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payflexx/Controllers/clientController.dart';
import 'package:payflexx/validators/My_validators.dart';
import '../../root_screen.dart';

class updateUserInfo extends StatefulWidget {
  static const routName = '/updateUser';
  const updateUserInfo({super.key});

  @override
  State<updateUserInfo> createState() => updateUserInfoState();
}

class updateUserInfoState extends State<updateUserInfo> {
  late TextEditingController nameController,
      phonecontroller,
      emailController,
      passwordController,
      confirmpasswordController,
      dobController,
      sPCController,
      cinController;
  authClientController authController = authClientController();
  late final FocusNode emailFocusNode,
      phoneFocusNode,
      passowrdFocusNode,
      confirmpasswordFocusNode,
      nameFocusNode,
      dobFocusNode,
      sPCFocusNode,
      cinFocusNode;

  late final _formKey = GlobalKey<FormState>();
  String userId = FirebaseAuth.instance.currentUser!.uid;
  bool obscureText = true;
  bool isLoading = false; // Declare the loading state variable

  @override
  void initState() {
    //focus nodes
    emailFocusNode = FocusNode();
    phoneFocusNode = FocusNode();
    passowrdFocusNode = FocusNode();
    nameFocusNode = FocusNode();
    dobFocusNode = FocusNode();
    confirmpasswordFocusNode = FocusNode();
    cinFocusNode = FocusNode();
    sPCFocusNode = FocusNode();

    //controllers
    emailController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
    phonecontroller = TextEditingController();
    confirmpasswordController = TextEditingController();
    dobController = TextEditingController();
    cinController = TextEditingController();
    sPCController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmpasswordController.dispose();
    phonecontroller.dispose();
    dobController.dispose();
    cinController.dispose();
    sPCController.dispose();

    //focus nodes

    emailFocusNode.dispose();
    passowrdFocusNode.dispose();
    nameFocusNode.dispose();
    phoneFocusNode.dispose();
    confirmpasswordFocusNode.dispose();
    dobFocusNode.dispose();
    cinFocusNode.dispose();
    sPCFocusNode.dispose();
    super.dispose();
  }

  //date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1930), // Earliest allowable date
      lastDate: DateTime(2007), // Latest allowable date
      // You can customize the theme of the date picker below
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(
                  0xFF00796B), // header background color matching Smart Eco theme
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            dialogBackgroundColor: Colors.white, // background color
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != DateTime.now()) {
      // Formatting and setting the date to _dobController
      dobController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }
// ****

  void updateUser() async {
    FocusScope.of(context).unfocus(); // Close the keyboard
    if (_formKey.currentState?.validate() ?? false) {
      if (passwordController.text.trim() ==
          confirmpasswordController.text.trim()) {
        final bool didUpdate = await authController.updateUserInfo(
          userId: userId,
          userName: nameController.text.trim(),
          phone: phonecontroller.text.trim(),
          dob: dobController.text.trim(),
          cin: cinController.text.trim(),
          securityPinCode: sPCController.text.trim(),
        );

        if (didUpdate) {
          // Navigate to home screen if the registration is successful
          Navigator.of(context).pushReplacementNamed(RootScreen.routName);
          clearForm();
        } else {
          // Handle registration failure
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Update failed")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Please correct the errors in the form")));
      }
    }
  }

// clear form
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    phonecontroller.clear();
    confirmpasswordController.clear();
    dobController.clear();
    cinController.clear();
    //sPCController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier vos informations."),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF003366), // Dark Blue from Smart Eco theme
                Color(0xFF48A999) // Teal from Smart Eco theme
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        //update user informations form
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 50),

              // logo
              Image.asset(
                "assets/images/edit.png",
                height: 150,
              ),

              const SizedBox(height: 25),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => MyValidators.displayNamevalidator(value),
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(passowrdFocusNode);
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: phonecontroller,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => MyValidators.phoneValidator(value),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: dobController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date de naissance',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'This field cannot be empty' : null,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),
              TextFormField(
                  controller: cinController,
                  decoration: InputDecoration(
                    labelText: 'CIN',
                    prefixIcon: const Icon(Icons.credit_card),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => MyValidators.cinValidator(value),
                  onFieldSubmitted: (value) {
                    FocusScope.of(context)
                        .requestFocus(dobFocusNode); // Prepare this FocusNode
                  }),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.update,
                  color: Color(0xFF003366), // Dark Blue from Smart Eco theme
                  size: 30,
                ),
                // Custom icon
                label: const Text(
                  'Mettre à jour les informations',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF003366), // Dark Blue from Smart Eco theme
                  ),
                  textAlign: TextAlign.center,
                ),

                onPressed: updateUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF48A999), // Teal from Smart Eco theme
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
