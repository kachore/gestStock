// lib/utils/constants.dart

import 'package:flutter/material.dart';

class AppConstants {
  // Nom de l'application
  static const String appName = 'KORA STOCK MANAGER';
  
  // Nom de la base de données
  static const String dbName = 'kora_stock.db';
  static const int dbVersion = 1;
  
  // Noms des tables
  static const String tableCategories = 'categories';
  static const String tableProducts = 'products';
  static const String tableSales = 'sales';
  
  // Couleurs
  static const Color primaryColor = Color(0xFF4F46E5); // Indigo
  static const Color accentColor = Color(0xFF0EA5E9); // Cyan
  static const Color backgroundColor = Color(0xFFF3F4F6); // Gris clair
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF1F2937); // Gris foncé
  static const Color warningColor = Color(0xFFF59E0B); // Orange
  static const Color errorColor = Color(0xFFEF4444); // Rouge
  static const Color successColor = Color(0xFF10B981); // Vert
  
  // Seuil d'alerte stock bas
  static const int lowStockThreshold = 5;
  
  // Format de devise
  static const String currency = 'FCFA';
  
  // Messages
  static const String msgProductAdded = 'Produit ajouté avec succès';
  static const String msgProductUpdated = 'Produit modifié avec succès';
  static const String msgProductDeleted = 'Produit supprimé';
  static const String msgCategoryAdded = 'Catégorie ajoutée';
  static const String msgSaleCompleted = 'Vente enregistrée';
  static const String msgInsufficientStock = 'Stock insuffisant';
  static const String msgError = 'Une erreur s\'est produite';
}