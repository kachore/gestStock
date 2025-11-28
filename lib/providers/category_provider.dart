// lib/providers/category_provider.dart

import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Charger toutes les catégories
  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
     WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _categories = await _categoryService.getAllCategories();
      _error = null;
    } catch (e) {
      _error = 'Erreur de chargement: $e';
    } finally {
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    }
  }

  // Ajouter une catégorie
  Future<bool> addCategory(Category category) async {
    try {
      await _categoryService.createCategory(category);
      await loadCategories(); // Recharger la liste
      return true;
    } catch (e) {
      _error = 'Erreur d\'ajout: $e';
      notifyListeners();
      return false;
    }
  }

  // Modifier une catégorie
  Future<bool> updateCategory(Category category) async {
    try {
      await _categoryService.updateCategory(category);
      await loadCategories();
      return true;
    } catch (e) {
      _error = 'Erreur de modification: $e';
      notifyListeners();
      return false;
    }
  }

  // Supprimer une catégorie
  Future<bool> deleteCategory(int id) async {
    try {
      await _categoryService.deleteCategory(id);
      await loadCategories();
      return true;
    } catch (e) {
      _error = 'Erreur de suppression: $e';
      notifyListeners();
      return false;
    }
  }

  // Récupérer une catégorie par ID
  Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtenir le nombre de produits par catégorie
  Future<int> getProductCount(int categoryId) async {
    try {
      return await _categoryService.getProductCountByCategory(categoryId);
    } catch (e) {
      return 0;
    }
  }
}