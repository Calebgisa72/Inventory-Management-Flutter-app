import 'package:flutter/material.dart';
import "package:inventory_management/ItemsCard.dart";
import 'package:inventory_management/Services/database.dart';
import 'package:inventory_management/models/products.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: ItemsList(),
      ),
    );
  }
}

class ItemsList extends StatefulWidget {
  const ItemsList({super.key});

  @override
  State<ItemsList> createState() => ItemsListState();
}

class ItemsListState extends State<ItemsList> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    String searchTerm = _searchController.text.toLowerCase();
    setState(() {
      if (searchTerm.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products
            .where((product) =>
                product.name.toLowerCase().contains(searchTerm) ||
                product.category.toLowerCase().contains(searchTerm))
            .toList();
      }
    });
  }

  Future<void> _fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Product> products = await _firestoreService.getProducts();
      setState(() {
        _products = products;
        _filteredProducts = products;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching products: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(107, 59, 225, 1),
        title: const Text(
          "All Items",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProducts,
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products by name...',
                prefixIcon: const Icon(Icons.search,
                    color: Color.fromRGBO(107, 59, 225, 1)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color.fromRGBO(107, 59, 225, 1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Color.fromRGBO(107, 59, 225, 1), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Found ${_filteredProducts.length} items',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  TextButton.icon(
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    onPressed: () {
                      _searchController.clear();
                      _filterProducts();
                    },
                  ),
              ],
            ),
          ),

          // Product list
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromRGBO(107, 59, 225, 1),
                    ),
                  )
                : _filteredProducts.isEmpty
                    ? const Center(
                        child: Text("No products found",
                            style: TextStyle(fontSize: 16)),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _filteredProducts.length,
                          itemBuilder: (ctx, index) {
                            Product singleProduct = _filteredProducts[index];
                            return ItmeCard(singleProduct);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
