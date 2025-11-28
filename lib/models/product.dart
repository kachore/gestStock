// lib/models/product.dart

class Product {
  final int? id;
  final String name;
  final int categoryId;
  final double price;
  final int quantity;
  final String? imagePath;
  final String? supplier; // Nouveau champ fournisseur
  final String createdAt;

  Product({
    this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.quantity,
    this.imagePath,
    this.supplier, // Nouveau paramètre
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  // Convertir en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'price': price,
      'quantity': quantity,
      'imagePath': imagePath,
      'supplier': supplier,
      'createdAt': createdAt,
    };
  }

  // Créer depuis Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      categoryId: map['categoryId'] as int,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      imagePath: map['imagePath'] as String?,
      supplier: map['supplier'] as String?,
      createdAt: map['createdAt'] as String,
    );
  }

  // Copier avec modifications
  Product copyWith({
    int? id,
    String? name,
    int? categoryId,
    double? price,
    int? quantity,
    String? imagePath,
    String? supplier,
    String? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imagePath: imagePath ?? this.imagePath,
      supplier: supplier ?? this.supplier,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Vérifier si le stock est bas
  bool get isLowStock => quantity <= 2;

  @override
  String toString() {
    return 'Product(id: $id, name: $name, categoryId: $categoryId, price: $price, quantity: $quantity)';
  }

  // Ajoutez ces méthodes pour permettre la comparaison correcte
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

}