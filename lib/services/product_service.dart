// lib/services/product_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/product.dart';
import '../utils/constants.dart';
import 'database_helper.dart';

class ProductService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Créer un produit
  Future<int> createProduct(Product product) async {
    final db = await _dbHelper.database;
    return await db.insert(
      AppConstants.tableProducts,
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Récupérer tous les produits
  Future<List<Product>> getAllProducts() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableProducts,
      orderBy: 'createdAt DESC',
    );
    
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  // Récupérer un produit par ID
  Future<Product?> getProductById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableProducts,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  // Récupérer les produits par catégorie
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableProducts,
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'name ASC',
    );
    
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  // Récupérer les produits avec stock bas
  Future<List<Product>> getLowStockProducts() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableProducts,
      where: 'quantity <= ?',
      whereArgs: [AppConstants.lowStockThreshold],
      orderBy: 'quantity ASC',
    );
    
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  // Rechercher des produits
  Future<List<Product>> searchProducts(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableProducts,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  // Mettre à jour un produit
  Future<int> updateProduct(Product product) async {
    final db = await _dbHelper.database;
    return await db.update(
      AppConstants.tableProducts,
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Supprimer un produit
  Future<int> deleteProduct(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      AppConstants.tableProducts,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Diminuer le stock après une vente
  Future<bool> decreaseStock(int productId, int quantity) async {
    final product = await getProductById(productId);
    if (product == null || product.quantity < quantity) {
      return false;
    }

    final updatedProduct = product.copyWith(
      quantity: product.quantity - quantity,
    );
    
    await updateProduct(updatedProduct);
    return true;
  }

  // Calculer la valeur totale du stock
  Future<double> getTotalStockValue() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(price * quantity) as total FROM ${AppConstants.tableProducts}',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Compter le nombre total de produits
  Future<int> getTotalProductCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableProducts}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}