// ignore_for_file: file_names, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DisplayQRCodePage extends StatelessWidget {
  final String userInfo;

  const DisplayQRCodePage({Key? key, required this.userInfo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text("Votre code QR"),
      ),
      body: Center(
        child: QrImageView(
          data: userInfo,
          version: QrVersions.auto,
          size: 320,
          gapless: false,
        ),
      ),
    );
  }
}
