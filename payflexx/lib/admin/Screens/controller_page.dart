import 'package:flutter/material.dart';

import '../Screens/Delete_user.dart';
import '../Screens/addprovider.dart';
import '../Screens/delete_provider.dart';

void main() {
  runApp(const MaterialApp(
    home: ControllerPage(),
  ));
}

class ControllerPage extends StatelessWidget {
  const ControllerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controller Page'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            AnimatedButton(
              icon: Icons.delete_forever,
              label: 'Delete Provider',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => DeleteProviderPage()));
              },
            ),
            const SizedBox(height: 30),
            AnimatedButton(
              icon: Icons.business_center,
              label: 'Add Provider',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddProviderPage()));
              },
            ),
            const SizedBox(height: 30),
            AnimatedButton(
              icon: Icons.delete_forever,
              label: 'Delete User',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => DeleteUserPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const AnimatedButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 30),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
         const   Color.fromARGB(189, 114, 159, 24), // Background color
        disabledBackgroundColor:
            const Color.fromARGB(255, 35, 34, 34), // Text and icon color
        textStyle: const TextStyle(fontSize: 20),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        elevation: 5, // Shadow depth
      ),
    );
  }
}
