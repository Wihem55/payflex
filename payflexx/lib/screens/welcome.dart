import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:payflexx/screens/client_screens/loginClient.dart';
import 'package:payflexx/services/Managers/assets_manager.dart';
import 'package:provider/provider.dart';

import '../Controllers/providers/theme_provider.dart';

class Welcome extends StatelessWidget {
  static const routName = '/welcome'; // Route name for navigation
  final Duration duration = const Duration(milliseconds: 800); // Animation duration

  const Welcome({Key? key}) : super(key: key); // Constructor with key

  @override
  Widget build(BuildContext context) {
    // Get the appropriate image path based on the theme
    String smartecoImagePath = Provider.of<ThemeProvider>(context).getIsDarkTheme
        ? AssetsManager.smarteco_light
        : AssetsManager.smarteco;
        
    final size = MediaQuery.of(context).size; // Get the screen size
    return Scaffold(
      resizeToAvoidBottomInset: true, // Prevent bottom overflow when the keyboard is shown
      // backgroundColor: const Color.fromARGB(138, 98, 126, 146), // Background color
      body: Container(
        margin: const EdgeInsets.all(8), // Outer margin
        width: size.width,
        height: size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end, // Align children to the bottom
          children: [
            /// Animated welcome animation
            FadeInUp(
              duration: duration,
              delay: const Duration(milliseconds: 2000),
              child: Container(
                margin: const EdgeInsets.only(
                  top: 50,
                  left: 5,
                  right: 5,
                ),
                width: size.width,
                height: size.height / 2,
                child: Lottie.asset("assets/images/welcome.zip", animate: true), // Lottie animation
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            /// Title
            FadeInUp(
              duration: duration,
              delay: const Duration(milliseconds: 1600),
              child: const Text(
                "Bienvenue sur PayFlex",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 30,
                    fontWeight: FontWeight.bold), // Text style
              ),
            ),

            /// SmartEco image
            FadeInUp(
              duration: duration,
              delay: const Duration(milliseconds: 1600),
              child: Center(
                child: SizedBox(
                  height: 100,
                  child: Image.asset(
                    smartecoImagePath,
                    height: size.height * 0.1,
                    width: size.width * 0.9,
                  ),
                ),
              ),
            ),

            Expanded(child: Container()), // Spacer

            /// Provider login button
            FadeInUp(
              duration: duration,
              delay: const Duration(milliseconds: 600),
              child: InkWell(
                // Use InkWell for tap handling
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/LoginProviderPage', // Navigate to login provider page
                  );
                },
                child: SButton(
                  size: size,
                  borderColor: Colors.grey,
                  color: Colors.white,
                  img: 'assets/images/fournisseur.png',
                  text: "Se connecter en tant que fournisseur",
                  textStyle: const TextStyle(color: Colors.black45),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            /// Client login button
            FadeInUp(
              duration: duration,
              delay: const Duration(milliseconds: 200),
              child: InkWell(
                // Use InkWell for tap handling
                onTap: () {
                  Navigator.of(context).pushNamed(LoginScreen.routName); // Navigate to login screen
                },
                child: SButton(
                  size: size,
                  borderColor: Colors.white,
                  color: const Color.fromARGB(255, 6, 6, 6),
                  img: 'assets/images/client.png',
                  text: "Se connecter en tant que client",
                  textStyle: const TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(
              height: 40,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class SButton extends StatelessWidget {
  const SButton({
    Key? key,
    required this.size,
    required this.color,
    required this.borderColor,
    required this.img,
    required this.text,
    required this.textStyle,
  }) : super(key: key);

  final Size size; // Button size
  final Color color; // Button background color
  final Color borderColor; // Button border color
  final String img; // Button image path
  final String text; // Button text
  final TextStyle? textStyle; // Button text style

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: size.width / 1.2,
        height: size.height / 15,
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10), // Rounded corners
            border: Border.all(color: borderColor, width: 1)), // Border
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center content
          children: [
            Image.asset(
              img,
              height: 40,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              text,
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }
}
