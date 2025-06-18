import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  final _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(107, 59, 225, 1),
        title: Text(
          'Inventory Report',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRunningOutProducts(),
            const SizedBox(height: 20),

            // Replace the Row with a horizontally scrollable container
            Container(
              height: 160.0, // Set a fixed height for the row
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      _buildTotalStockCircularIndicator(),
                      const SizedBox(width: 15),
                      _buildTotalProfitCircularIndicator(),
                      const SizedBox(width: 15),
                      _buildTotalCategoryCircularIndicator(),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32.0),
            _buildProductProfitLoss(), 
            const SizedBox(height: 16.0),
            
          ],
        ),
      ),
    );
  }

  Widget _buildRunningOutProducts() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Running Out Products',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              height: 140.0,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(user!.uid)
                    .collection('products')
                    .where('quantity', isLessThan: 10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final runningOutProducts = snapshot.data!.docs;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: runningOutProducts.length,
                      itemBuilder: (context, index) {
                        final product = runningOutProducts[index];
                        final productData =
                            product.data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Container(
                                width: 100.0,
                                height: 100.0,
                                alignment: Alignment.center,
                                child: ClipRRect(
                                  child: Image.network(
                                    productData['imageUrl'] as String,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text('Quantity: ${productData['quantity']}'),
                            ],
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalStockCircularIndicator() {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    return Center(
      child: Container(
        width: 140.0,
        height: 140.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.green, width: 5),
        ),
        child: Center(
          child: StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection('users')
                .doc(user!.uid)
                .collection('products')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                int totalItems = snapshot.data!.docs.length;

                return Column(
                  children: [
                    const SizedBox(height: 45),
                    Text(
                      totalItems.toString(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      "Total Items",
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }

  // Enhance the total profit circular indicator with refresh capability
  Widget _buildTotalProfitCircularIndicator() {
    return Center(
      child: Container(
        width: 140.0,
        height: 140.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.purple, width: 5),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('users')
              .doc(user!.uid)
              .collection('transactions')
              .snapshots(),
          builder: (context, snapshot) {
            // Add debug print to check data
            if (snapshot.hasData) {
              print("Transaction documents: ${snapshot.data!.docs.length}");

              double totalProfit = 0.0;
              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                // Print each transaction's data to debug
                print("Transaction data: $data");

                if (data.containsKey('profit')) {
                  final profit = (data['profit'] as num).toDouble();
                  totalProfit += profit;
                  print("Added profit: $profit, Total now: $totalProfit");
                }
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currencyFormat.format(totalProfit),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Total Profit",
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              print("Error loading profits: ${snapshot.error}");
              return Text('Error: ${snapshot.error}');
            } else {
              return const Center(
                child: CircularProgressIndicator(color: Colors.purple),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildTotalCategoryCircularIndicator() {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    return Center(
      child: Container(
        width: 140.0,
        height: 140.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.blue, width: 5),
        ),
        child: Center(
          child: StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection('users')
                .doc(user!.uid)
                .collection('products')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final items = snapshot.data!.docs;
                final categoryCounts = <String, int>{};

                for (final item in items) {
                  final categoryName = item['category'] as String;
                  categoryCounts[categoryName] =
                      (categoryCounts[categoryName] ?? 0) + 1;
                }

                final totalCategories = categoryCounts.length;

                return Column(
                  children: [
                    const SizedBox(height: 45),
                    Text(
                      totalCategories.toString(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      "Total Categories",
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProductProfitLoss() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Profit/Loss Analysis',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(user!.uid)
                  .collection('transactions')
                  .orderBy('saleDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                Map<String, Map<String, dynamic>> productStats = {};
                
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final String productId = data['productId'] ?? '';
                  final double costPrice = (data['costPrice'] ?? 0.0).toDouble();
                  final double profit = (data['profit'] ?? 0.0).toDouble();
                  final int quantitySold = (data['quantitySold'] ?? 0) as int;
                  final Timestamp saleDate = data['saleDate'] as Timestamp;

                  if (!productStats.containsKey(productId)) {
                    productStats[productId] = {
                      'costPrice': costPrice,
                      'totalProfit': 0.0,
                      'totalQuantitySold': 0,
                      'lastSaleDate': saleDate,
                    };
                  }
                  
                  productStats[productId]!['totalProfit'] = (productStats[productId]!['totalProfit'] as double) + profit;
                  productStats[productId]!['totalQuantitySold'] = (productStats[productId]!['totalQuantitySold'] as int) + quantitySold;
                }

                if (productStats.isEmpty) {
                  return const Center(child: Text('No transaction data available'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: productStats.length,
                  itemBuilder: (context, index) {
                    final productId = productStats.keys.elementAt(index);
                    final stats = productStats[productId]!;
                    final double totalProfit = stats['totalProfit'];
                    final bool isProfit = totalProfit > 0;
                    final DateTime lastSaleDate = (stats['lastSaleDate'] as Timestamp).toDate();

                    return ListTile(
                      title: Text('Product ID: $productId'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cost Price: ${_currencyFormat.format(stats['costPrice'])}'),
                          Text('Total Sold: ${stats['totalQuantitySold']} units'),
                          Text('Last Sale: ${DateFormat('MMM dd, yyyy').format(lastSaleDate)}'),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currencyFormat.format(totalProfit.abs()),
                            style: TextStyle(
                              color: isProfit ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isProfit ? 'Profit' : 'Loss',
                            style: TextStyle(
                              color: isProfit ? Colors.green : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  final String name;
  final int quantity;
  final String imageUrl;

  Product(this.name, this.quantity, this.imageUrl);
}