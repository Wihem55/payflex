// ignore_for_file: unused_field, file_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:payflexx/screens/client_screens/ForgotPasswordPage.dart';
import 'package:payflexx/screens/client_screens/signupclient.dart';
import 'package:payflexx/screens/welcome.dart';
import 'package:payflexx/validators/My_validators.dart';

import '../../widgets/text_style/app_name_text.dart';

import '../../root_screen.dart';
import '../../widgets/image_picker/camera_dialog.dart';
import '../provider_screens/footer_provider.dart';

class LoginScreen extends StatefulWidget {
  static const routName = '/LoginScreen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;
  late final _formKey = GlobalKey<FormState>();
  bool obscureText = true;
  bool _isLoading = false;
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  final auth = FirebaseAuth.instance;
  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    // Focus Nodes
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    // Focus Nodes
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loginFct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();

      try {
        setState(() {
          _isLoading = true;
        });

        // Sign in the user
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Get the user ID
        String userId = userCredential.user!.uid;

        // Retrieve the user document from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        // Check if the user is a client
        if (userDoc.exists) {
          bool isClient = userDoc['userType'] ==
              'Client'; // assuming 'userType' is the field name in the document

          if (isClient) {
            Fluttertoast.showToast(
              msg: "Ouverture de session réussie",
              toastLength: Toast.LENGTH_SHORT,
              textColor: Colors.white,
            );

            if (!mounted) return;

            Navigator.pushReplacementNamed(context, RootScreen.routName);
          } else {
            Fluttertoast.showToast(
              msg: "L'utilisateur n'est pas un client",
              toastLength: Toast.LENGTH_SHORT,
              textColor: Colors.white,
            );

            // Optionally, you can navigate to a different screen or show an error dialog
          }
        } else {
          await MyAppMethods.showErrorORWarningDialog(
            context: context,
            subtitle: "User document does not exist",
            fct: () {},
          );
        }
      } on FirebaseAuthException catch (error) {
        await MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "An error has been occurred ${error.message}",
          fct: () {},
        );
      } catch (error) {
        await MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "An error has been occurred $error",
          fct: () {},
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _animationController.forward();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 60.0,
                ),
                FadeTransition(
                  opacity: _animation,
                  child: const AppNameTextWidget(
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 30),
                ScaleTransition(
                  scale: _animation,
                  child: Image.asset(
                    "assets/images/clientlogin.png",
                    height: 200,
                  ),
                ),
                const SizedBox(height: 25),
                FadeTransition(
                  opacity: _animation,
                  child: const Text(
                    "Bonjour!Vous avez été manqué!",
                    style: TextStyle(
                      color: Color.fromARGB(255, 198, 148, 244),
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      FadeTransition(
                        opacity: _animation,
                        child: TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: "Adresse e-mail",
                            prefixIcon: Icon(
                              Icons.email,
                            ),
                          ),
                          validator: (value) {
                            return MyValidators.emailValidator(value);
                          },
                          onFieldSubmitted: (value) {
                            FocusScope.of(context)
                                .requestFocus(_passwordFocusNode);
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      FadeTransition(
                        opacity: _animation,
                        child: TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: obscureText,
                          decoration: InputDecoration(
                            hintText: "*********",
                            prefixIcon: const Icon(
                              Icons.lock,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscureText = !obscureText;
                                });
                              },
                              icon: Icon(
                                obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          validator: (value) {
                            return MyValidators.passwordValidator(value);
                          },
                          onFieldSubmitted: (value) {
                            _loginFct();
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(ForgotPasswordPage.routName);
                              },
                              child: const Text(
                                'Mot de passe oublié',
                                style: TextStyle(
                                  color: Color.fromARGB(173, 202, 42, 42),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      ScaleTransition(
                        scale: _animation,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () async {
                              _loginFct();
                            }, // call sign in method
                            icon: const Icon(Icons.login),
                            label: const Text(
                              "Se connecter",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FadeTransition(
                        opacity: _animation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  thickness: 0.5,
                                  color: Color.fromARGB(255, 198, 148, 244),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: Text(
                                  'Ou continuer avec',
                                  style: TextStyle(
                                      color:
                                          Color.fromARGB(255, 198, 148, 244)),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 0.5,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FadeTransition(
                        opacity: _animation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Pas encore membre?',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 198, 148, 244)),
                            ),
                            const SizedBox(width: 2),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, SignUpClient.routName);
                              },
                              child: const Text(
                                'S\'inscrire maintenant',
                                style: TextStyle(
                                  color: Color.fromARGB(186, 33, 149, 243),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
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
