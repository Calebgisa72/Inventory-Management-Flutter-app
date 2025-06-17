class Product {
  final String pid;
  final String name;
  final double price;
  final int quantity;
  final String distributor;
  final String category;
  final String imageUrl;
  final String expiredate;
  final String firestoreId; 

  Product({
    required this.pid,
    required this.name,
    required this.price,
    required this.quantity,
    required this.distributor,
    required this.category,
    required this.imageUrl,
    required this.expiredate,
    this.firestoreId = '', 
  });

  
  factory Product.fromMap(Map<String, dynamic> data) {
    return Product(
      pid: data['pid'] ?? '',
      name: data['name'] ?? '',
      quantity: (data['quantity'] is int)
          ? data['quantity']
          : (data['quantity'] as num).toInt(),
      price: (data['price'] is double)
          ? data['price']
          : (data['price'] as num).toDouble(),
      distributor: data['distributor'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'],
      expiredate: data['expiredate'] ?? '',
      firestoreId:
          data['firestoreId'] ?? '', 
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'pid': pid,
      'name': name,
      'quantity': quantity,
      'price': price,
      'category': category,
      'distributor': distributor,
      'imageUrl': imageUrl,
      'expiredate': expiredate,
      'firestoreId': firestoreId, 
    };
  }
}
