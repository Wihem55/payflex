// ignore_for_file: prefer_const_constructors, camel_case_types, unused_import, unused_local_variable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Controllers/providers/providerinfo_provider.dart';
import '../../Controllers/providers/userinfo_provider.dart';

class SecurePinDialog extends StatelessWidget {
  final TextEditingController pinController = TextEditingController();
  final Function()? onEnterPressed;

  SecurePinDialog({Key? key, this.onEnterPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userModel =
        Provider.of<UserProvider>(context, listen: false).getUserModel;
    final providerModel =
        Provider.of<ProviderInfo>(context, listen: false).getproviderModel;

    return AlertDialog(
      title: Text('Saisir le mot de passe de sécurité'),
      content: TextField(
        controller: pinController,
        obscureText: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Code de sécurité à 4 chiffres',
        ),
        onSubmitted: (_) => _handleEnterPressed(context),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Text('Annuler'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text('Entrer'),
          onPressed: () => _handleEnterPressed(context),
        ),
      ],
    );
  }

  void _handleEnterPressed(BuildContext context) {
    final userModel =
        Provider.of<UserProvider>(context, listen: false).getUserModel;
    final providerModel =
        Provider.of<ProviderInfo>(context, listen: false).getproviderModel;
    if (userModel != null && pinController.text == userModel.securityPinCode) {
      Navigator.of(context).pop();
      if (onEnterPressed != null) {
        onEnterPressed!();
      }
    } else if (providerModel != null &&
        pinController.text == providerModel.securityPinCode) {
      Navigator.of(context).pop();
      if (onEnterPressed != null) {
        onEnterPressed!();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Code de sécurité incorrect')),
      );
    }
  }

  static void show(BuildContext context, Function()? onEnterPressed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SecurePinDialog(onEnterPressed: onEnterPressed);
      },
    );
  }
}
