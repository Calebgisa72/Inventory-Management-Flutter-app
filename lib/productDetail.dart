import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/EditScreen.dart';
import 'package:inventory_management/models/products.dart' as pmodel;

class ProductDetailPage extends StatefulWidget {
  final pmodel.Product cuproduct;

  const ProductDetailPage(this.cuproduct, {super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late pmodel.Product _product = widget.cuproduct;

  void _navigateToEditScreen() async {
    final existingProduct = _product;
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditScreen(existingProduct),
      ),
    );

    if (updatedData != null) {
      setState(() {
        _product = updatedData;
      });
    }
  }

  late List<StockData> data = [
    StockData('Stock In', 123, Colors.green),
    StockData('Stock Out', 567, Colors.red),
    StockData('Running Out', 45678, Colors.yellow),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color.fromRGBO(107, 59, 225, 1),
        title: const Text(
          'Product Detail',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _navigateToEditScreen,
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
            tooltip: "Edit Product",
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Header
              _buildProductImageHeader(),

              // Product Info Cards
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductInfoCard(),
                    const SizedBox(height: 16),
                    _buildStockActivityCard(),
                    const SizedBox(height: 16),
                    _buildInventoryStatusCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImageHeader() {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(107, 59, 225, 0.8),
          ),
          child: ClipRRect(
            child: Image.network(
              _product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.white.withOpacity(0.5),
                  ),
                );
              },
            ),
          ),
        ),
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Text(
            _product.name,
            style: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 2,
                  offset: Offset(1, 1),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(107, 59, 225, 1),
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow('Product ID:', _product.pid),
            _buildInfoRow('Price:', '\$${_product.price.toStringAsFixed(2)}'),
            _buildInfoRow('Supplier:', _product.distributor),
            _buildInfoRow('Category:', _product.category),
            _buildInfoRow(
              'Expiry Date:',
              _product.expiredate,
              valueColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockActivityCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Stock Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(107, 59, 225, 1),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(107, 59, 225, 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Daily',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromRGBO(107, 59, 225, 1),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sections: data
                            .map((e) => PieChartSectionData(
                                  color: e.color,
                                  value: e.value,
                                  title: '',
                                  radius: 50,
                                  titlePositionPercentageOffset: 0.55,
                                  badgeWidget: e.value > 1000
                                      ? _Badge(
                                          Icons.arrow_upward,
                                          size: 18,
                                          borderColor: e.color,
                                        )
                                      : null,
                                ))
                            .toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        centerSpaceColor: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: data
                            .map((e) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: _buildLegendItem(
                                      e.label, e.color, e.value),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryStatusCard() {
    Color statusColor = Colors.green;
    String statusText = "In Stock";
    IconData statusIcon = Icons.check_circle;

    if (_product.quantity <= 5) {
      statusColor = Colors.red;
      statusText = "Low Stock";
      statusIcon = Icons.error;
    } else if (_product.quantity <= 20) {
      statusColor = Colors.orange;
      statusText = "Running Low";
      statusIcon = Icons.warning;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inventory Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(107, 59, 225, 1),
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                      Text(
                        '${_product.quantity} units available',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(107, 59, 225, 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _product.quantity.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _product.quantity / 100,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, double value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 14.0,
          height: 14.0,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value.toInt().toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Badge widget for chart
class _Badge extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color borderColor;

  const _Badge(
    this.icon, {
    required this.size,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: size * 0.6,
          color: borderColor,
        ),
      ),
    );
  }
}

class StockData {
  final String label;
  final double value;
  final Color color;

  StockData(this.label, this.value, this.color);
}
