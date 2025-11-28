// lib/providers/product_provider.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;
  int? _selectedCategoryId;

  List<Product> get products => _filteredProducts.isEmpty && _selectedCategoryId == null
      ? _products
      : _filteredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get selectedCategoryId => _selectedCategoryId;

  // Méthode pour notifier de manière sécurisée
  void _safeNotifyListeners() {
    if (!_isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Charger tous les produits
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      _products = await _productService.getAllProducts();
      _filteredProducts = [];
      _selectedCategoryId = null;
      _error = null;
    } catch (e) {
      _error = 'Erreur de chargement: $e';
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // Ajouter un produit
  Future<bool> addProduct(Product product) async {
    try {
      await _productService.createProduct(product);
      await loadProducts(); // loadProducts gère déjà les notifications
      return true;
    } catch (e) {
      _error = 'Erreur d\'ajout: $e';
      _safeNotifyListeners();
      return false;
    }
  }

  // Modifier un produit
  Future<bool> updateProduct(Product product) async {
    try {
      await _productService.updateProduct(product);
      await loadProducts(); // loadProducts gère déjà les notifications
      return true;
    } catch (e) {
      _error = 'Erreur de modification: $e';
      _safeNotifyListeners();
      return false;
    }
  }

  // Supprimer un produit
  Future<bool> deleteProduct(int id) async {
    try {
      await _productService.deleteProduct(id);
      await loadProducts(); // loadProducts gère déjà les notifications
      return true;
    } catch (e) {
      _error = 'Erreur de suppression: $e';
      _safeNotifyListeners();
      return false;
    }
  }

  // Filtrer par catégorie
  Future<void> filterByCategory(int? categoryId) async {
    _selectedCategoryId = categoryId;
    
    if (categoryId == null) {
      _filteredProducts = [];
    } else {
      _filteredProducts = await _productService.getProductsByCategory(categoryId);
    }
    _safeNotifyListeners();
  }

  // Rechercher des produits
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      _filteredProducts = [];
      _selectedCategoryId = null;
    } else {
      _filteredProducts = await _productService.searchProducts(query);
    }
    _safeNotifyListeners();
  }

  // Obtenir les produits en stock bas
  Future<List<Product>> getLowStockProducts() async {
    return await _productService.getLowStockProducts();
  }

  // Obtenir la valeur totale du stock
  Future<double> getTotalStockValue() async {
    return await _productService.getTotalStockValue();
  }

  // Obtenir le nombre total de produits
  Future<int> getTotalProductCount() async {
    return await _productService.getTotalProductCount();
  }

  // Récupérer un produit par ID
  Future<Product?> getProductById(int id) async {
    return await _productService.getProductById(id);
  }
}