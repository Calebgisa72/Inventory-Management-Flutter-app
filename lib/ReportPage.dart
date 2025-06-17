import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;

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
            Row(
              children: [
                const SizedBox(width: 30),
                _buildTotalStockCircularIndicator(),
                const SizedBox(width: 10),
                _buildTotalCategoryCircularIndicator(),
              ],
            ),
            const SizedBox(height: 32.0),
            _buildTopSellingProducts(),
            const SizedBox(height: 16.0),
            _buildStockTrendsChart(),
            const SizedBox(height: 16.0),
            _buildCategoryDistributionChart(),
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

  Widget _buildTopSellingProducts() {
    return Card(
      child: SizedBox(
        width: 400.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Selling Products',
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
                      .orderBy('sold', descending: true)
                      .limit(5)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final topSellingProducts = snapshot.data!.docs;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: topSellingProducts.length,
                        itemBuilder: (context, index) {
                          final product = topSellingProducts[index];
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
                                Text('Sold: ${productData['sold']}'),
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
      ),
    );
  }

  Widget _buildStockTrendsChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stock Trends',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            AspectRatio(
              aspectRatio: 1.5,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(user!.uid)
                    .collection('transactions')
                    .orderBy('date')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final stockTrendDocs = snapshot.data!.docs;
                    List<FlSpot> spots = [];
                    for (int i = 0; i < stockTrendDocs.length; i++) {
                      final data =
                          stockTrendDocs[i].data() as Map<String, dynamic>;
                      final double yValue = (data['value'] as num).toDouble();
                      spots.add(FlSpot(i.toDouble(), yValue));
                    }
                    return LineChart(
                      LineChartData(
                        titlesData: const FlTitlesData(show: true),
                        borderData: FlBorderData(show: true),
                        gridData: const FlGridData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            color: Colors.blue,
                            isCurved: true,
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                      ),
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

  Widget _buildCategoryDistributionChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Distribution',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            AspectRatio(
              aspectRatio: 1.5,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
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

                    final barGroups = <BarChartGroupData>[];
                    int x = 0;
                    categoryCounts.forEach((category, count) {
                      barGroups.add(
                        BarChartGroupData(
                          x: x,
                          barRods: [
                            BarChartRodData(
                              toY: count.toDouble(),
                              color: Colors.green,
                            ),
                          ],
                          showingTooltipIndicators: [0],
                        ),
                      );
                      x++;
                    });

                    return BarChart(
                      BarChartData(
                        titlesData: const FlTitlesData(show: true),
                        borderData: FlBorderData(show: true),
                        gridData: const FlGridData(show: true),
                        barGroups: barGroups,
                      ),
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
}

class Product {
  final String name;
  final int quantity;
  final String imageUrl;

  Product(this.name, this.quantity, this.imageUrl);
}

class Category {
  final String name;
  final int percentage;

  Category(this.name, this.percentage);
}
