class Product {
  final int? id;
  final String name;
  final int usageCount;
  final DateTime lastUsed;

  Product({
    this.id,
    required this.name,
    required this.usageCount,
    required this.lastUsed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'usageCount': usageCount,
      'lastUsed': lastUsed.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      usageCount: map['usageCount'],
      lastUsed: DateTime.parse(map['lastUsed']),
    );
  }
}
