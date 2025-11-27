// lib/providers/sale_provider.dart

import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../services/sale_service.dart';

class SaleProvider with ChangeNotifier {
  final SaleService _saleService = SaleService();
  
  List<Sale> _sales = [];
  bool _isLoading = false;
  String? _error;

  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Charger toutes les ventes
  Future<void> loadSales() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sales = await _saleService.getAllSales();
      _error = null;
    } catch (e) {
      _error = 'Erreur de chargement: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les ventes du jour
  Future<void> loadTodaySales() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sales = await _saleService.getTodaySales();
      _error = null;
    } catch (e) {
      _error = 'Erreur de chargement: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Créer une vente
  Future<bool> createSale(Sale sale) async {
    try {
      final result = await _saleService.createSale(sale);
      if (result == null) {
        _error = 'Stock insuffisant';
        notifyListeners();
        return false;
      }
      await loadSales();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la vente: $e';
      notifyListeners();
      return false;
    }
  }

  // Supprimer une vente
  Future<bool> deleteSale(int id) async {
    try {
      await _saleService.deleteSale(id);
      await loadSales();
      return true;
    } catch (e) {
      _error = 'Erreur de suppression: $e';
      notifyListeners();
      return false;
    }
  }

  // Obtenir les statistiques du jour
  Future<Map<String, dynamic>> getTodayStats() async {
    return await _saleService.getSalesStats();
  }

  // Obtenir les ventes par produit
  Future<List<Sale>> getSalesByProduct(int productId) async {
    return await _saleService.getSalesByProduct(productId);
  }

  // Obtenir le total des ventes du jour
  Future<double> getTodayTotal() async {
    return await _saleService.getTodayTotalSales();
  }

  // Obtenir le nombre de ventes du jour
  Future<int> getTodayCount() async {
    return await _saleService.getTodaySalesCount();
  }
}