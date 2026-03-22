// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class RecognizationPage extends StatefulWidget {
   final String path;
  final String expectedSalary;  // Assurez-vous que cette ligne est ajoutée
   // Et cette ligne aussi

  const RecognizationPage({
    Key? key,
    required this.path,
    required this.expectedSalary,  // et initialisé dans le constructeur
 // de même ici
  }) : super(key: key);
  @override
  RecognizationPageState createState() => RecognizationPageState();
}

class RecognizationPageState extends State<RecognizationPage> {
  String? verificationResult; // Résultat de la vérification du salaire
String? bankNameVerificationResult; // Résultat de la vérification du nom de la banque
  @override
  void initState() {
    super.initState();
    performTextRecognition(widget.path);
  }

  Future<void> performTextRecognition(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer();
    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      // Vérification si le salaire attendu est présent dans le texte extrait
      if (recognizedText.text.contains(widget.expectedSalary)) {
        verificationResult = "Salaire vérifié avec succès.";
        Navigator.pop(context, verificationResult);
      } else {
        verificationResult =
            "Le salaire indiqué ne correspond pas à celui de la fiche de paie.";
      }
     
    } catch (e) {
      print("Erreur lors de la reconnaissance de texte : $e");
      verificationResult = "Erreur lors de la reconnaissance de texte.";
    } finally {
      textRecognizer.close();
// Mise à jour de l'interface utilisateur avec le résultat
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification du Salaire'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (verificationResult != null)
              Text(
                verificationResult!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}
