// lib/models/category.dart

class Category {
  final int? id;
  final String name;
  final String? description;

  Category({
    this.id,
    required this.name,
    this.description,
  });

  // Convertir un objet Category en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  // Créer un objet Category depuis un Map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
    );
  }

  // Copier avec modifications
  Category copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, description: $description)';
  }
}
