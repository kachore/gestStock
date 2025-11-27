// lib/models/sale.dart

class Sale {
  final int? id;
  final int productId;
  final String productName; // Pour l'affichage
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? customerInfo; // Nouveau champ client
  final String date;

  Sale({
    this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.customerInfo, // Nouveau paramètre
    String? date,
  }) : date = date ?? DateTime.now().toIso8601String();

  // Convertir en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'customerInfo': customerInfo,
      'date': date,
    };
  }

  // Créer depuis Map
  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as int?,
      productId: map['productId'] as int,
      productName: map['productName'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unitPrice'] as num).toDouble(),
      totalPrice: (map['totalPrice'] as num).toDouble(),
      customerInfo: map['customerInfo'] as String?,
      date: map['date'] as String,
    );
  }

  // Copier avec modifications
  Sale copyWith({
    int? id,
    int? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? customerInfo,
    String? date,
  }) {
    return Sale(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      customerInfo: customerInfo ?? this.customerInfo,
      date: date ?? this.date,
    );
  }

  // Formater la date pour affichage
  String get formattedDate {
    final dt = DateTime.parse(date);
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  String toString() {
    return 'Sale(id: $id, productName: $productName, quantity: $quantity, totalPrice: $totalPrice)';
  }
}