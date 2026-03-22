// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../../validators/My_validators.dart';

class ForgotPasswordPage extends StatefulWidget {
  static const routName = '/ForgotPasswordPage';
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late TextEditingController _emailController;
  late FocusNode _emailFocusNode;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _emailFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

//method to send reset email if userEmail exists
  Future<void> _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      try {
        final users = await FirebaseFirestore.instance
            .collection('users')
            .where('userEmail', isEqualTo: email)
            .get();

        if (users.docs.isNotEmpty) {
          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lien de réinitialisation envoyé!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("L'adresse e-mail n'existe pas.")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Une erreur est survenue: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(137, 16, 4, 28),
        title: const Text(
          "Mot de passe oublié",
          style: TextStyle(color: Colors.grey),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // logo forget
            Image.asset(
              "assets/images/forget_pass.png",
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 40),
            const Text(
              "Réinitialiser votre mot de passe",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Entrez votre adresse e-mail ci-dessous pour recevoir les instructions de réinitialisation de votre mot de passe",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            //Email adress form
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Adresse e-mail",
                  prefixIcon: const Icon(IconlyLight.message,
                      color: Color.fromARGB(255, 198, 148, 244)),
                  fillColor: Colors.grey[900],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => MyValidators.emailValidator(value),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                    255, 198, 148, 244), 
                foregroundColor: Colors
                    .grey[900], 
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(IconlyLight.send),
              label: const Text(
                "Envoyer le lien de réinitialisation",
                style: TextStyle(fontSize: 18),
              ),
              onPressed: _sendResetEmail,
            ),
          ],
        ),
      ),
    );
  }
}
