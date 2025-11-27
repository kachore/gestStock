// lib/utils/helpers.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

class Helpers {
  // Formater un prix avec la devise
  static String formatPrice(double price) {
    final formatter = NumberFormat('#,##0', 'fr_FR');
    return '${formatter.format(price)} ${AppConstants.currency}';
  }

  // Formater une date
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'fr_FR').format(date);
  }

  // Formater une date avec l'heure
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(date);
  }

  // Formater une date depuis une chaîne ISO
  static String formatDateFromString(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return formatDate(date);
    } catch (e) {
      return isoDate;
    }
  }

  // Afficher un SnackBar de succès
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Afficher un SnackBar d'erreur
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Afficher un SnackBar d'avertissement
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppConstants.warningColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Dialogue de confirmation
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Vérifier si un texte est vide ou null
  static bool isNullOrEmpty(String? text) {
    return text == null || text.trim().isEmpty;
  }

  // Valider un prix
  static String? validatePrice(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Le prix est requis';
    }
    final price = double.tryParse(value!);
    if (price == null || price <= 0) {
      return 'Prix invalide';
    }
    return null;
  }

  // Valider une quantité
  static String? validateQuantity(String? value) {
    if (isNullOrEmpty(value)) {
      return 'La quantité est requise';
    }
    final quantity = int.tryParse(value!);
    if (quantity == null || quantity < 0) {
      return 'Quantité invalide';
    }
    return null;
  }

  // Valider un nom
  static String? validateName(String? value) {
    if (isNullOrEmpty(value)) {
      return 'Le nom est requis';
    }
    if (value!.length < 3) {
      return 'Le nom doit contenir au moins 3 caractères';
    }
    return null;
  }
}

