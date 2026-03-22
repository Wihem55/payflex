// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class RecognizationPageCheque extends StatefulWidget {
  final String path;
  final String expectedBankName;

  const RecognizationPageCheque({
    Key? key,
    required this.path,
    required this.expectedBankName,
  }) : super(key: key);

  @override
  _RecognizationPageChequeState createState() =>
      _RecognizationPageChequeState();
}

class _RecognizationPageChequeState extends State<RecognizationPageCheque> {
  String? recognizedText;
  String? verificationResult;

  @override
  void initState() {
    super.initState();
    performTextRecognition();
  }

  Future<void> performTextRecognition() async {
    final inputImage = InputImage.fromFilePath(widget.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    // Exemple de logique de vérification du nom de la banque
    if (recognizedText.text.contains(widget.expectedBankName)) {
      setState(() {
        verificationResult =
            "Nom de la banque reconnu : ${widget.expectedBankName}";
        Navigator.pop(context, verificationResult);
      });
    } else {
      setState(() {
        verificationResult = "Nom de la banque non trouvé.";
        Navigator.pop(context, verificationResult);
      });
    }

    textRecognizer.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification du Chèque'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: recognizedText != null
              ? Text(recognizedText!)
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
