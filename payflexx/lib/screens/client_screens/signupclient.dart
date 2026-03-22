// ignore_for_file: unused_field, use_build_context_synchronously, await_only_futures, unused_local_variable, non_constant_identifier_names, avoid_types_as_parameter_names

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:intl/intl.dart';
import 'package:payflexx/Controllers/clientController.dart';

import '../../validators/My_validators.dart';

class SignUpClient extends StatefulWidget {
  static const routName = '/SignUpClient';
  const SignUpClient({super.key});

  @override
  State<SignUpClient> createState() => SignUpClientState();
}

class SignUpClientState extends State<SignUpClient> {
  bool _termsAccepted = false;
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
      initialDate: DateTime(2000), // initial date
      firstDate: DateTime(1930), // Earliest allowable date
      lastDate: DateTime(2007), // Latest allowable date

      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary:
                  Color.fromARGB(255, 198, 148, 244), // header background color
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

  void registerUser() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Vous devez accepter les termes et conditions pour continuer.")),
        );
        return;
      }
    }
    if (_formKey.currentState?.validate() ?? false) {
      if (passwordController.text.trim() ==
          confirmpasswordController.text.trim()) {
        final bool didRegister = await authController.registerUser(
          userEmail: emailController.text.trim(),
          password: passwordController.text.trim(),
          userName: nameController.text.trim(),
          phone: phonecontroller.text.trim(),
          dob: dobController.text.trim(),
          cin: cinController.text.trim(),
          securityPinCode: sPCController.text.trim(),
        );

        if (didRegister) {
          // Navigate to home screen if the registration is successful
          Navigator.of(context).pushReplacementNamed('/BankInfoPage');
          clearForm();
        } else {
          // Handle registration failure
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Échec de l'inscription")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Les mots de passe ne correspondent pas")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Veuillez corriger les erreurs dans le formulaire")));
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
    sPCController.clear();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              const SizedBox(
                height: 16,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Inscrivez-vous afin que vous puissiez commencer à explorer l'application :",
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
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: emailController,
                      focusNode: emailFocusNode,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: "Adresse e-mail",
                        prefixIcon: Icon(IconlyLight.message,
                            color: Color.fromARGB(255, 111, 136, 19)),
                      ),
                      validator: (value) => MyValidators.emailValidator(value),
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(nameFocusNode);
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: nameController,
                      focusNode: nameFocusNode,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        hintText: "Nom complet",
                        prefixIcon: Icon(IconlyLight.user2,
                            color: Color.fromARGB(255, 111, 136, 19)),
                      ),
                      validator: (value) =>
                          MyValidators.displayNamevalidator(value),
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(passowrdFocusNode);
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                        controller:
                            cinController, // You need to initialize this controller in initState
                        focusNode:
                            cinFocusNode, // Initialize this FocusNode as well
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "CIN",
                          prefixIcon: Icon(Icons.credit_card,
                              color: Color.fromARGB(255, 111, 136, 19)),
                        ),
                        validator: (value) => MyValidators.cinValidator(value),
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(
                              dobFocusNode); // Prepare this FocusNode
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller:
                          phonecontroller, // You need to initialize this controller in initState
                      focusNode: phoneFocusNode,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "Numéro de téléphone",
                        prefixIcon: Icon(IconlyLight.call,
                            color: Color.fromARGB(255, 111, 136, 19)),
                      ),
                      validator: (value) => MyValidators.phoneValidator(value),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller:
                          dobController, // Assuming you have initialized this controller
                      focusNode: dobFocusNode, // And this focus node
                      decoration: InputDecoration(
                        hintText: "Date de naissance",
                        prefixIcon: const Icon(Icons.calendar_today,
                            color: Color.fromARGB(255, 111, 136, 19)),
                        suffixIcon: IconButton(
                          onPressed: () => _selectDate(
                              context), // Here is where you call the method
                          icon: const Icon(Icons.date_range),
                        ),
                      ),
                      readOnly:
                          true, // Make the field read-only since the dialog will handle input
                      validator: (value) {
                        // Implement validation logic or use MyValidators.dobValidator
                        return null;
                      },
                      onTap: () => _selectDate(
                          context), // Open date picker when the field is tapped
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: passwordController,
                      focusNode: passowrdFocusNode,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: obscureText,
                      decoration: InputDecoration(
                        hintText: "Mot de passe",
                        prefixIcon: const Icon(IconlyLight.password,
                            color: Color.fromARGB(255, 111, 136, 19)),
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
                          MyValidators.passwordValidator(value),
                      onFieldSubmitted: (value) {
                        FocusScope.of(context)
                            .requestFocus(confirmpasswordFocusNode);
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: confirmpasswordController,
                      focusNode: confirmpasswordFocusNode,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: obscureText,
                      decoration: InputDecoration(
                        hintText: "Confirmez le mot de passe",
                        prefixIcon: const Icon(IconlyLight.password,
                            color: Color.fromARGB(255, 111, 136, 19)),
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
                          MyValidators.repeatPasswordValidator(
                              value: value, password: passwordController.text),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: sPCController,
                      focusNode: sPCFocusNode,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      obscureText: obscureText,
                      decoration: InputDecoration(
                        hintText: "Votre code PIN de sécurité",
                        prefixIcon: const Icon(IconlyLight.password,
                            color: Color.fromARGB(255, 111, 136, 19)),
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
                      validator: (Value) {
                        return MyValidators.fourDigitValidator(
                            Value); // Assuming this is a static method in MyValidators class
                      },
                    ),
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: _termsAccepted,
                          onChanged: (bool? value) {
                            setState(() {
                              _termsAccepted = value ?? false;
                            });
                          },
                        ),
                        GestureDetector(
                          onTap: () {
                            // Open terms and conditions page
                          },
                          child: const Text(
                            'J\'accepte les termes et conditions',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: registerUser,
                        icon: const Icon(IconlyLight.arrowRightCircle),
                        label: const Text(
                          "Étape suivante",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
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
