import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:inventory_management/models/products.dart";

class DatabaseService {
  final CollectionReference products =
      FirebaseFirestore.instance.collection("products");
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

  Future<void> _CheckUser() async {}

  Future<List<Product>> getProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('products')
          .get();
      List<Product> products = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product(
            name: data['name'],
            quantity: data['quantity'],
            price: data['price'],
            distributor: data['distributor'],
            category: data['category'],
            imageUrl: data['imageUrl'],
            pid: data['pid'],
            expiredate: data['expiredate']);
      }).toList();
      return products;
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  Future<void> updateProduct(
      String pid, Map<String, dynamic> updatedData) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('products')
          .where('pid', isEqualTo: pid)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update(updatedData);
      }
    } catch (error) {
      print("not update");
      rethrow;
    }
  }

  Future<void> deleteProduct(String pid) async {
    try {
      final productsCollection =
          _firestore.collection('users').doc(user!.uid).collection('products');
      final snapshot =
          await productsCollection.where('pid', isEqualTo: pid).get();

      if (snapshot.docs.isNotEmpty) {
        final productDoc = snapshot.docs.first;
        await productDoc.reference.delete();
        print("Product deleted successfully");
      } else {
        print("Product not found");
      }
    } catch (e) {
      print("Error deleting product: $e");
      throw Exception("Error deleting product");
    }
  }

  Future<Product> getProductByPid(String pid) async {
    try {
      print("searching ****************** $pid");
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('products')
          .where('pid', isEqualTo: pid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final documentSnapshot = querySnapshot.docs[0];
        Map<String, dynamic> data = documentSnapshot.data();
        return Product(
          pid: data['pid'] as String,
          name: data['name'] as String,
          quantity: data['quantity'] as int,
          price: data['price'] as double,
          distributor: data['distributor'] as String,
          category: data['category'] as String,
          imageUrl: data['imageUrl'] as String,
          expiredate: data['expiredate'] as String,
        );
      } else {
        throw Exception("Product with PID $pid not found");
      }
    } catch (e) {
      throw Exception("Error fetching product: $e");
    }
  }

  Future<void> registerTransaction(String productId, int quantitySold) async {
    final transactionsRef = _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('transactions');

    await transactionsRef.add({
      'productId': productId,
      'quantitySold': quantitySold,
      'saleDate': FieldValue.serverTimestamp(),
    });

    // Update product status or other necessary actions
  }

  // Update method that uses Firestore document ID
  Future<void> updateProductById(
      String documentId, Map<String, dynamic> data) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('products')
        .doc(documentId)
        .update(data);
  }

  // Delete method that uses Firestore document ID
  Future<void> deleteProductById(String documentId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('products')
        .doc(documentId)
        .delete();
  }

  // Modify getProductsByName to include Firestore document ID
  Future<List<Product>> getProductsByName(String name) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final lowerCaseName = name.toLowerCase();

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('products')
        .where('name', isGreaterThanOrEqualTo: lowerCaseName)
        .where('name', isLessThanOrEqualTo: lowerCaseName + '\uf8ff')
        .get();

    if (snapshot.docs.isEmpty) {
      return [];
    }

    List<Product> products = [];
    for (var doc in snapshot.docs) {
      try {
        final data = doc.data() as Map<String, dynamic>;
        products.add(
          Product(
            firestoreId: doc.id, 
            pid: data['pid'] ?? '',
            name: data['name'] ?? '',
            price: (data['price'] is double)
                ? data['price']
                : (data['price'] as num).toDouble(),
            quantity: data['quantity'] ?? 0,
            distributor: data['distributor'] ?? '',
            category: data['category'] ?? '',
            imageUrl: data['imageUrl'] ?? '',
            expiredate: data['expiredate'] ?? '',
          ),
        );
      } catch (e) {
        print('Error parsing product: $e');
      }
    }

    return products;
  }
}
