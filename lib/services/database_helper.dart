// lib/services/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Table categories
    await db.execute('''
      CREATE TABLE ${AppConstants.tableCategories} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT
      )
    ''');

    // Table products
    await db.execute('''
      CREATE TABLE ${AppConstants.tableProducts} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        imagePath TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES ${AppConstants.tableCategories} (id)
          ON DELETE CASCADE
      )
    ''');

    // Table sales
    await db.execute('''
      CREATE TABLE ${AppConstants.tableSales} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        productName TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unitPrice REAL NOT NULL,
        totalPrice REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (productId) REFERENCES ${AppConstants.tableProducts} (id)
          ON DELETE CASCADE
      )
    ''');

    // Insérer des catégories par défaut
    await db.insert(AppConstants.tableCategories, {
      'name': 'Aliment',
      'description': 'Produits alimentaires'
    });
    await db.insert(AppConstants.tableCategories, {
      'name': 'Cosmétique',
      'description': 'Produits de beauté et d\'hygiène'
    });
    await db.insert(AppConstants.tableCategories, {
      'name': 'Boisson',
      'description': 'Boissons diverses'
    });
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  // Réinitialiser la base de données (pour tests)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}