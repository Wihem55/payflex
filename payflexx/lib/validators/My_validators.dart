// ignore_for_file: file_names, body_might_complete_normally_nullable
class MyValidators {
  static String? displayNamevalidator(String? displayName) {
    if (displayName == null || displayName.isEmpty) {
      return 'Le nom d\'affichage ne peut pas être vide';
    }
    if (displayName.length < 3 || displayName.length > 20) {
      return 'Le nom d\'affichage doit comporter entre 3 et 30 caractères';
    }
    return null; //Return null if display name is valid
  }

  static String? emailValidator(String? value) {
    if (value!.isEmpty) {
      return 'veuillez saisir un Email';
    }
    if (!RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
        .hasMatch(value)) {
      return 'veuillez entrer un email valide';
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value!.isEmpty) {
      return 'veuillez saisir un mot de passe';
    }
    if (value.length < 6) {
      return 'le mot de passe doit comporter au moins 6 caractères';
    }
    return null;
  }

  static String? repeatPasswordValidator({String? value, String? password}) {
    if (value != password) {
      return 'Les mots de passe ne correspondent pas !';
    }
    return null;
  }

  static String? phoneValidator(String? value) {
    if (value!.isEmpty) {
      return 'Veuillez saisir un numéro de téléphone';
    }
    if (value.length != 8) {
      return 'Le numéro de téléphone doit comporter exactement 8 chiffres';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Le numéro de téléphone ne doit contenir que des chiffres';
    }
    return null;
  }

  static String? cinValidator(String? value) {
    if (value!.isEmpty) {
      return 'Veuillez saisir un CIN';
    }
    if (value.length != 8) {
      return 'Le CIN doit comporter exactement 8 caractères';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'La CIN ne doit contenir que des chiffres';
    }
    return null;
  }

  static String? accountNumberValidator(String? value) {
    if (value!.isEmpty) {
      return 'Veuillez saisir un numéro de compte';
    }
    if (value.length != 11) {
      return 'Le numéro de compte doit comporter exactement 11 caractères';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Le numéro de compte ne doit contenir que des chiffres';
    }
    return null;
  }

  static String? ribKeyValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir une clé RIB';
    }
    if (value.length != 2) {
      return 'La clé RIB doit comporter exactement 2 chiffres';
    }
    if (!RegExp(r'^\d{2}$').hasMatch(value)) {
      return 'La clé RIB ne doit contenir que des chiffres';
    }
    return null;
  }

//security pin validator
  static String? fourDigitValidator(String? value) {
    // Use a regular expression to check if the string has exactly 4 digits
    final RegExp fourDigitRegExp = RegExp(r'^\d{4}$');
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir votre code à 4 chiffres';
    } else if (!fourDigitRegExp.hasMatch(value)) {
      return 'Le code doit comporter exactement 4 chiffres';
    }
    return null; // null means the input is valid
  }

  //checks verfie
  static String? checkValidator(String? value) {
    const int maxChecks = 24;
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer le nombre de chèques';
    }
    int? checks = int.tryParse(value);
    if (checks == null || checks <= 0) {
      return 'Le nombre de chèques doit être positif';
    }
    if (checks > maxChecks) {
      return 'Le nombre de chèques ne doit pas dépasser $maxChecks';
    }
    return null;
  }
}
