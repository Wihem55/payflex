// ignore_for_file: depend_on_referenced_packages, file_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

String extractUsername(String qrContent) {
  // Split the content by comma to get the individual entries
  List<String> entries = qrContent.split(', ');

  // Find the entry that starts with "UserName: "
  String userNameEntry = entries.firstWhere(
      (entry) => entry.startsWith('UserName: '),
      orElse: () => 'UserName: Not Found');

  // Extract the username value after the "UserName: " part
  String userNameValue = userNameEntry.split(': ').last.trim();
  return userNameValue;
}

//extract salary value
String extractSalary(String qrContent) {
  // Split the content by comma to get the individual entries
  List<String> entries = qrContent.split(', ');

  // Find the entry that starts with "Salary: "
  String salaryEntry = entries.firstWhere(
      (entry) => entry.startsWith('Salary: '),
      orElse: () => 'Salary: Not Found');

  // Extract the salary value after the "Salary: " part
  String salaryValue = salaryEntry.split(': ').last.trim();
  return salaryValue;
}

//extract the user's id
String extractUserID(String qrContent) {
  // Split the content by comma to get the individual entries
  List<String> entries = qrContent.split(', ');

  // Find the entry that starts with "UserID: "
  String userIDEntry = entries.firstWhere(
      (entry) => entry.startsWith('UserID: '),
      orElse: () => 'UserID: Not Found');

  // Extract the user ID value after the "UserID: " part
  String userIDValue = userIDEntry.split(': ').last.trim();
  return userIDValue;
}

void openQRScannerClient(
    BuildContext context,
    TextEditingController itemSalaryController,
    TextEditingController userIDController,
    TextEditingController userNameController) {
  showDialog(
    context: context,
    barrierDismissible:
        false, // Prevent dismissing the dialog by tapping outside
    builder: (context) => AlertDialog(
      // Use AlertDialog for a more prominent dialog appearance
      content: QRScannerScreen(onCodeRead: (String code) {
        // Extract the salary, user ID, and username using your functions
        String salaryValue = extractSalary(code);
        String userIDValue = extractUserID(code);
        String userNameValue = extractUsername(code);

        // Set the extracted values to their respective controllers
        if (salaryValue != 'Not Found') {
          itemSalaryController.text = salaryValue;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Salary not found in QR code")),
          );
        }

        if (userIDValue != 'Not Found') {
          userIDController.text = userIDValue;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User ID not found in QR code")),
          );
        }

        if (userNameValue != 'Not Found') {
          userNameController.text = userNameValue;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Username not found in QR code")),
          );
        }

        // Dismiss the dialog after scanning
        Navigator.pop(context);
      }),
    ),
  );
}

void openQRScanner(
  BuildContext context,
  TextEditingController itemCodeController,
) {
  showDialog(
    context: context,
    barrierDismissible:
        false, // Prevent dismissing the dialog by tapping outside
    builder: (context) => AlertDialog(
      // Use AlertDialog for a more prominent dialog appearance
      content: QRScannerScreen(
        onCodeRead: (String code) {
          // Set the scanned code to the text field
          itemCodeController.text = code;

          // Dismiss the dialog after scanning
          Navigator.pop(context);
        },
      ),
    ),
  );
}

class QRScannerScreen extends StatefulWidget {
  final Function(String) onCodeRead;

  QRScannerScreen({Key? key, required this.onCodeRead}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((Barcode scanData) {
      widget.onCodeRead(scanData.code!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 300,
        ),
      ),
    );
  }
}
