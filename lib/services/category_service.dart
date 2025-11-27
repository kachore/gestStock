// lib/services/category_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/category.dart';
import '../utils/constants.dart';
import 'database_helper.dart';

class CategoryService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Créer une catégorie
  Future<int> createCategory(Category category) async {
    final db = await _dbHelper.database;
    return await db.insert(
      AppConstants.tableCategories,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Récupérer toutes les catégories
  Future<List<Category>> getAllCategories() async {
    final db = await _dbHelper.database;
    final maps = await db.query(AppConstants.tableCategories);
    
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  // Récupérer une catégorie par ID
  Future<Category?> getCategoryById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      AppConstants.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  // Mettre à jour une catégorie
  Future<int> updateCategory(Category category) async {
    final db = await _dbHelper.database;
    return await db.update(
      AppConstants.tableCategories,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  // Supprimer une catégorie
  Future<int> deleteCategory(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      AppConstants.tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Compter le nombre de produits dans une catégorie
  Future<int> getProductCountByCategory(int categoryId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.tableProducts} WHERE categoryId = ?',
      [categoryId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}