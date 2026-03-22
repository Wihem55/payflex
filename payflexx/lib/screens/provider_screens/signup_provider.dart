// ignore_for_file: use_build_context_synchronously, unused_field, non_constant_identifier_names

import 'package:intl/intl.dart';
import 'package:payflexx/screens/provider_screens/footer_provider.dart';

import '../../Controllers/providerController.dart';
import '../../validators/My_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class SignUpProviderPage extends StatefulWidget {
  static const routName = '/SignUpProviderPage';
  const SignUpProviderPage({super.key});

  @override
  State<SignUpProviderPage> createState() => SignUpProviderPageState();
}

authProviderController AuthProviderController = authProviderController();

class SignUpProviderPageState extends State<SignUpProviderPage> {
  bool _termsAccepted = false;
  late TextEditingController nameController,
      phonecontroller,
      emailController,
      passwordController,
      confirmpasswordController,
      dobController,
      sPCController,
      cinController;

  late final FocusNode emailFocusNode,
      phoneFocusNode,
      passowrdFocusNode,
      confirmpasswordFocusNode,
      nameFocusNode,
      dobFocusNode,
      sPCFocusNode,
      cinFocusNode;
  final _formKey = GlobalKey<FormState>();
  bool obscureText = true;
  @override
  void initState() {
    //focus nodes
    emailFocusNode = FocusNode();
    sPCFocusNode = FocusNode();
    phoneFocusNode = FocusNode();
    passowrdFocusNode = FocusNode();
    nameFocusNode = FocusNode();
    dobFocusNode = FocusNode();
    confirmpasswordFocusNode = FocusNode();
    cinFocusNode = FocusNode();

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

  void registerProvider() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("Vous devez accepter les termes et conditions pour continuer.")),
        );
        return;
      }
    }
    if (_formKey.currentState?.validate() ?? false) {
      if (passwordController.text.trim() ==
          confirmpasswordController.text.trim()) {
        bool success = await AuthProviderController.registerProvider(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          providerName: nameController.text.trim(),
          phoneNumber: phonecontroller.text.trim(),
          dob: dobController.text.trim(),
          cin: cinController.text.trim(),
          securityPinCode: sPCController.text.trim(),
          context: context,
        );
        if (success) {
          // Navigate to home screen if the registration is successful
          Navigator.of(context).pushReplacementNamed(MainTabView.routName);
          clearForm();
        } else {
          // Handle registration failure
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Registration failed")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Passwords do not match")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please correct the errors in the form")));
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Padding(
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
                        "Inscrivez-vous afin que vous puissiez commencer à explorer l'application ",
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
                        validator: (value) =>
                            MyValidators.emailValidator(value),
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
                          FocusScope.of(context).requestFocus(cinFocusNode);
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                          controller: cinController,
                          focusNode:
                              cinFocusNode, // Initialize this FocusNode as well
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "CIN",
                            prefixIcon: Icon(Icons.credit_card,
                                color: Color.fromARGB(255, 111, 136, 19)),
                          ),
                          validator: (value) =>
                              MyValidators.cinValidator(value),
                          onFieldSubmitted: (value) {
                            FocusScope.of(context).requestFocus(phoneFocusNode);
                          }),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: phonecontroller,
                        focusNode: phoneFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Numéro de téléphone",
                          prefixIcon: Icon(IconlyLight.call,
                              color: Color.fromARGB(255, 111, 136, 19)),
                        ),
                        validator: (value) =>
                            MyValidators.phoneValidator(value),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: dobController,
                        focusNode: dobFocusNode,
                        decoration: InputDecoration(
                          hintText: "Date de naissance",
                          prefixIcon: const Icon(Icons.calendar_today,
                              color: Color.fromARGB(255, 111, 136, 19)),
                          suffixIcon: IconButton(
                            onPressed: () => _selectDate(context),
                            icon: const Icon(Icons.date_range),
                          ),
                        ),
                        readOnly: true,
                        validator: (value) {
                          return null;
                        },
                        onTap: () => _selectDate(context),
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
                                value: value,
                                password: passwordController.text.trim()),
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(sPCFocusNode);
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: sPCController,
                        focusNode: sPCFocusNode,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.visiblePassword,
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
                          return MyValidators.fourDigitValidator(Value);
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
                              "J'accepte les termes et conditions",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Color.fromARGB(255, 81, 145, 197),
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
                          onPressed: registerProvider,
                          icon: const Icon(IconlyLight.arrowRightCircle),
                          label: const Text(
                            "S'inscrire en tant que fournisseur",
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
      ),
    );
  }
}
