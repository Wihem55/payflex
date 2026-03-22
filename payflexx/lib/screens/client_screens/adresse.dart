// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class AddressPage extends StatefulWidget {
  static const String routeName = '/adresse';

  const AddressPage({super.key});
  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController!);
    _animationController?.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smarteco Locations'),
        elevation: 4.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              FadeTransition(
                opacity: _opacityAnimation!,
                child: locationCard(
                  'SMARTECO TUNISIA',
                  '41 Panorama Building, North Urban Center, 1082, Tunis, Tunisia',
                  '+216 22 667 156',
                  'manager@smarteco-universe.com',
                ),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _opacityAnimation!,
                child: locationCard(
                  'SMARTECO FRANCE',
                  '8 bis Abel street, 75012 Paris, France',
                  '+33 7 80 94 15 30',
                  'france@smarteco-universe.com',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
//custom card widget
  Widget locationCard(String companyName, String address, String phone, String email) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(companyName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(address),
            const SizedBox(height: 5),
            Text(phone),
            const SizedBox(height: 5),
            Text(email),
          ],
        ),
      ),
    );
  }
}
