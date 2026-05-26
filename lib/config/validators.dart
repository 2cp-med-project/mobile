// config/validators.dart
// All form validation logic — use these in every screen, never write validation inline

class Validators {

  // ── Nom / Prénom 
  // must be more than 2 characters, letters only
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ce champ est requis';
    if (value.trim().length < 3) return 'Minimum 3 caractères';
    if (!RegExp(r"^[a-zA-ZÀ-ÿ\s\-']+$").hasMatch(value.trim())) {
      return 'Lettres uniquement';
    }
    return null;
  }

  // ── Phone 
  // must be 9-10 digits, numbers only
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ce champ est requis';
    if (!RegExp(r'^\d{9,10}$').hasMatch(value.trim())) {
      return 'Numéro invalide (9-10 chiffres)';
    }
    return null;
  }

  // ── Email 
  // must contain @ and a valid domain
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ce champ est requis';
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(value.trim())) {
      return 'Email invalide (ex: nom@gmail.com)';
    }
    return null;
  }

  // ── Password 
  // min 8 chars, at least 1 uppercase, 1 number, 1 special character
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Ce champ est requis';
    if (value.length < 8) return 'Minimum 8 caractères';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Au moins 1 majuscule';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Au moins 1 chiffre';
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Au moins 1 caractère spécial (!@#\$...)';
    }
    return null;
  }

  // ── Confirm password 
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Ce champ est requis';
    if (value != original) return 'Les mots de passe ne correspondent pas';
    return null;
  }

  // ── Required (generic) 
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ce champ est requis';
    return null;
  }

  // ── Date parts 
  static String? day(String? value) {
    if (value == null || value.trim().isEmpty) return 'Requis';
    final d = int.tryParse(value);
    if (d == null || d < 1 || d > 31) return 'Jour invalide';
    return null;
  }

  static String? month(String? value) {
    if (value == null || value.trim().isEmpty) return 'Requis';
    final m = int.tryParse(value);
    if (m == null || m < 1 || m > 12) return 'Mois invalide';
    return null;
  }

  static String? year(String? value) {
    if (value == null || value.trim().isEmpty) return 'Requis';
    final y = int.tryParse(value);
    if (y == null || y < 1900 || y > DateTime.now().year) return 'Année invalide';
    return null;
  }
}