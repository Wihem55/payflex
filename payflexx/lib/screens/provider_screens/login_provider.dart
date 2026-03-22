// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:payflexx/Controllers/providerController.dart';
import 'package:payflexx/screens/provider_screens/footer_provider.dart';
import 'package:payflexx/widgets/text_style/app_name_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../admin/Screens/dashboard.dart';
import '../../validators/My_validators.dart';

class LoginProviderPage extends StatefulWidget {
  static const routName = '/LoginScreen';
  const LoginProviderPage({Key? key}) : super(key: key);

  @override
  State<LoginProviderPage> createState() => _LoginProviderPageState();
}

class _LoginProviderPageState extends State<LoginProviderPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;
  late final GlobalKey<FormState> _formKey;
  bool obscureText = true;
  bool _isLoading = false;

  late final AnimationController _animationController;
  late final Animation<double> _animation;

  final authProviderController authController = authProviderController();

  Future<bool> isAdminLogin(String email) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('admin')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        print('Admin login verified.'); // Debugging line
        return true;
      } else {
        print('Not an admin login.'); // Debugging line
        return false;
      }
    } catch (e) {
      print('Error checking admin login: $e'); // Debugging line
      return false;
    }
  }

  void signUserIn(BuildContext context) async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();

      try {
        setState(() {
          _isLoading = true;
        });

        bool success = await authController.loginUser(
            email: email, password: password, context: context);
        print('Login success: $success'); // Debugging line

        if (success) {
          // Retrieve the user document from Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('providers')
              .where('email', isEqualTo: email)
              .limit(1)
              .get()
              .then((snapshot) => snapshot.docs.first);

          if (userDoc.exists) {
            String userType =
                userDoc['userType']; // assuming 'userType' is the field name

            if (userType == 'admin') {
              print('User is an admin'); // Debugging line
              Navigator.of(context).pushReplacementNamed(DashBoard.routeName);
            } else if (userType == 'provider') {
              print('User is a provider'); // Debugging line
              Navigator.of(context).pushReplacementNamed(MainTabView.routName);
            } else {
              print('User is not a provider or admin'); // Debugging line
              Fluttertoast.showToast(
                msg: "User is not a provider or admin",
                toastLength: Toast.LENGTH_SHORT,
                textColor: Colors.white,
              );
            }
          } else {
            Fluttertoast.showToast(
              msg: "User document does not exist",
              toastLength: Toast.LENGTH_SHORT,
              textColor: Colors.white,
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: "Login Failed",
            toastLength: Toast.LENGTH_SHORT,
            textColor: Colors.white,
          );
        }
      } catch (e) {
        print('Error: $e'); // Debugging line
        Fluttertoast.showToast(
          msg: "Login Failed: $e",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.white,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _formKey = GlobalKey<FormState>();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60.0),
                FadeTransition(
                  opacity: _animation,
                  child: const AppNameTextWidget(
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 50),
                ScaleTransition(
                  scale: _animation,
                  child: Image.asset(
                    "assets/images/clientlogin.png",
                    height: 150,
                  ),
                ),
                const SizedBox(height: 25),
                FadeTransition(
                  opacity: _animation,
                  child: const Text(
                    "Bonjour! Vous avez été manqué! ",
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
                              size: 20,
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
                      const SizedBox(height: 16.0),
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
                              size: 20,
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
                                size: 20,
                              ),
                            ),
                          ),
                          validator: (value) {
                            return MyValidators.passwordValidator(value);
                          },
                          onFieldSubmitted: (value) {
                            signUserIn(context);
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed('/ForgotPasswordProviderPage');
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
                            onPressed: () => signUserIn(context),
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
                                Navigator.of(context)
                                    .pushNamed('/SignUpProviderPage');
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
                      ),
                      const SizedBox(height: 10),
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
