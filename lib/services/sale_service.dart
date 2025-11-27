// lib/services/sale_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/sale.dart';
import '../utils/constants.dart';
import 'database_helper.dart';
import 'product_service.dart';

class SaleService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ProductService _productService = ProductService();

  // Créer une vente et diminuer le stock
  Future<int?> createSale(Sale sale) async {
    // Vérifier si le stock est suffisant
    final canDecrease = await _productService.decreaseStock(
      sale.productId,
      sale.quantity,
    );

    if (!canDecrease) {
      return null; // Stock insuffisant
    }

    final db = await _dbHelper.database;
    return await db.insert(
      AppConstants.tableSales,
      sale.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Récupérer toutes les ventes
  Future<List<Sale>> getAllSales() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableSales,
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Sale.fromMap(maps[i]);
    });
  }

  // Récupérer les ventes du jour
  Future<List<Sale>> getTodaySales() async {
    final db = await _dbHelper.database;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day).toIso8601String();
    
    final maps = await db.query(
      AppConstants.tableSales,
      where: 'date >= ?',
      whereArgs: [todayStart],
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Sale.fromMap(maps[i]);
    });
  }

  // Récupérer les ventes par produit
  Future<List<Sale>> getSalesByProduct(int productId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableSales,
      where: 'productId = ?',
      whereArgs: [productId],
      orderBy: 'date DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Sale.fromMap(maps[i]);
    });
  }

  // Supprimer une vente
  Future<int> deleteSale(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      AppConstants.tableSales,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Calculer le total des ventes du jour
  Future<double> getTodayTotalSales() async {
    final db = await _dbHelper.database;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day).toIso8601String();
    
    final result = await db.rawQuery(
      'SELECT SUM(totalPrice) as total FROM ${AppConstants.tableSales} WHERE date >= ?',
      [todayStart],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Compter les ventes du jour
  Future<int> getTodaySalesCount() async {
    final db = await _dbHelper.database;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day).toIso8601String();
    
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableSales} WHERE date >= ?',
      [todayStart],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Obtenir les statistiques des ventes
  Future<Map<String, dynamic>> getSalesStats() async {
    final todayTotal = await getTodayTotalSales();
    final todayCount = await getTodaySalesCount();
    
    return {
      'todayTotal': todayTotal,
      'todayCount': todayCount,
    };
  }
}