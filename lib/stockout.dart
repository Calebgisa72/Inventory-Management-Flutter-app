import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/ItemsCard.dart';
import 'package:inventory_management/Services/database.dart';
import 'package:inventory_management/models/products.dart';

class StockOutPage extends StatefulWidget {
  const StockOutPage({super.key});

  @override
  _StockOutPageState createState() => _StockOutPageState();
}

class _StockOutPageState extends State<StockOutPage> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  String? _selectedOption;
  Product? _selectedProduct;
  List<Product> _searchResults = [];
  late Product pro;
  bool _isSearching = false;

  // Add field to store the Firestore document ID
  String? _firestoreDocId;

  @override
  void dispose() {
    _productNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductsByName(String name) async {
    if (name.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      List<Product> products = await _firestoreService.getProductsByName(name);
      setState(() {
        _searchResults = products;
        _isSearching = false;
      });

      if (products.isEmpty) {
        _showAlertDialog('Not Found', 'No products found with that name.');
      }
    } catch (error) {
      print('Error fetching products: $error');
      _showAlertDialog('Error', 'Failed to fetch products. Please try again.');
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _selectProduct(Product product) {
    setState(() {
      _selectedProduct = product;
      pro = product;
      _searchResults = [];
      _productNameController.text = product.name;

      // Store the Firestore document ID when selecting a product
      _firestoreDocId = product.firestoreId;
    });
  }

  void _handleOptionChange(String? option) {
    setState(() {
      _selectedOption = option;
    });
  }

  Future<void> registerTransaction() async {
    print(" ********** transaction update");
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    final transactionsRef =
        firestore.collection('users').doc(user!.uid).collection('transactions');

    await transactionsRef.add({
      'productId': _selectedProduct!.pid,
      'quantitySold': int.parse(_quantityController.text),
      'saleDate': FieldValue.serverTimestamp(),
    });

    // Update product status or other necessary actions
  }

  Future<void> _updateProductQuantity() async {
    if (_selectedOption == null ||
        _quantityController.text.isEmpty ||
        _selectedProduct == null) {
      _showAlertDialog("Missing Information",
          "Please select an option and enter a quantity.");
      return; // Ensure both option, quantity, and product are selected
    }

    final int quantity;
    try {
      quantity = int.parse(_quantityController.text);
      if (quantity <= 0) {
        _showAlertDialog(
            "Invalid Quantity", "Quantity must be greater than zero.");
        return;
      }
    } catch (e) {
      _showAlertDialog("Invalid Quantity", "Please enter a valid number.");
      return;
    }

    int newQuantity = _selectedProduct!.quantity;

    if (_selectedOption == "Sold Out" || _selectedOption == "Worn Out") {
      if (quantity > newQuantity) {
        _showAlertDialog("Error", "Quantity is greater than available stock.");
        return;
      }
      newQuantity -= quantity;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child:
            CircularProgressIndicator(color: Color.fromRGBO(107, 59, 225, 1)),
      ),
    );

    try {
      if (_selectedOption == "Sold Out") {
        await registerTransaction();
      }

      // Use firestoreDocId for Firestore operations
      if (newQuantity <= 0) {
        // Display confirmation dialog before deletion
        bool confirmDelete = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Confirm Deletion'),
                  content: Text(
                      'This will remove "${_selectedProduct!.name}" completely from inventory. Continue?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                );
              },
            ) ??
            false;

        if (confirmDelete) {
          // Use the Firestore document ID for deletion
          await _firestoreService.deleteProductById(_firestoreDocId!);

          print(
              'Product deleted from Firestore with document ID: $_firestoreDocId');
        } else {
          // If deletion was canceled, update the quantity instead
          await _firestoreService.updateProductById(_firestoreDocId!, {
            'quantity': newQuantity,
          });
        }
      } else {
        // Use the Firestore document ID for updating
        await _firestoreService.updateProductById(_firestoreDocId!, {
          'quantity': newQuantity,
        });

        print(
            'Product updated in Firestore with document ID: $_firestoreDocId');
      }

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success dialog
      if (mounted) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Product $_selectedOption successfully.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Clear the selection after successful update
                    setState(() {
                      _selectedProduct = null;
                      _selectedOption = null;
                      _quantityController.clear();
                      _productNameController.clear();
                      _searchResults = [];
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      _showAlertDialog("Error", "Failed to update product: $error");
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Update the search results to show Firestore IDs
  Widget _buildSearchResultItem(Product product) {
    return InkWell(
      onTap: () {
        _selectProduct(product);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Product ID: ${product.pid}',
              overflow: TextOverflow.ellipsis,
            ),
            // Text(
            //   'Firestore ID: ${product.firestoreId}',
            //   style: const TextStyle(fontSize: 12, color: Colors.grey),
            //   overflow: TextOverflow.ellipsis,
            // ),
            Text(
              'Quantity: ${product.quantity}',
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white, // Change the color of the back button
        ),
        backgroundColor: const Color.fromRGBO(107, 59, 225, 1),
        title: const Text(
          'Stock Out',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search field
              TextFormField(
                cursorColor: const Color.fromRGBO(107, 59, 225, 1),
                controller: _productNameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  labelStyle:
                      const TextStyle(color: Color.fromRGBO(107, 59, 225, 1)),
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromRGBO(107, 59, 225, 1)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromRGBO(107, 59, 225, 1)),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search,
                        color: Color.fromRGBO(107, 59, 225, 1)),
                    onPressed: () {
                      _fetchProductsByName(_productNameController.text);
                    },
                  ),
                ),
                onChanged: (value) {
                  if (value.length > 2) {
                    _fetchProductsByName(value);
                  } else if (value.isEmpty) {
                    setState(() {
                      _searchResults = [];
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Search button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _fetchProductsByName(_productNameController.text);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromRGBO(107, 59, 225, 1)),
                  ),
                  child: const Text(
                    'Search Product',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Loading indicator
              if (_isSearching)
                const Center(
                    child: CircularProgressIndicator(
                        color: Color.fromRGBO(107, 59, 225, 1))),

              // Search results
              if (_searchResults.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search Results (${_searchResults.length})',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Modified container to avoid Row overflow issues
                    SizedBox(
                      width: double.infinity,
                      height: min(
                          4 * 72.0,
                          _searchResults.length *
                              96.0), // Increased height for more content
                      child: Material(
                        borderRadius: BorderRadius.circular(8),
                        elevation: 0,
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color.fromRGBO(107, 59, 225, 1)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  _buildSearchResultItem(_searchResults[index]),
                                  if (index < _searchResults.length - 1)
                                    const Divider(height: 1),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              // Selected product details
              if (_selectedProduct != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'Selected Product',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Product card wrapper to prevent Row overflow
                LayoutBuilder(builder: (context, constraints) {
                  return SizedBox(
                    width: constraints.maxWidth,
                    child: ItmeCard(pro),
                  );
                }),
                const SizedBox(height: 16),
                const Text(
                  'Select Stock Out Option:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                // Wrap radio buttons in a Column for better layout
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: const Text(
                          'Sold Out',
                          overflow: TextOverflow.ellipsis,
                        ),
                        contentPadding: EdgeInsets.zero,
                        leading: Radio<String>(
                          activeColor: const Color.fromRGBO(107, 59, 225, 1),
                          value: 'Sold Out',
                          groupValue: _selectedOption,
                          onChanged: _handleOptionChange,
                        ),
                      ),
                      ListTile(
                        title: const Text(
                          'Worn Out',
                          overflow: TextOverflow.ellipsis,
                        ),
                        contentPadding: EdgeInsets.zero,
                        leading: Radio<String>(
                          activeColor: const Color.fromRGBO(107, 59, 225, 1),
                          value: 'Worn Out',
                          groupValue: _selectedOption,
                          onChanged: _handleOptionChange,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    labelStyle:
                        TextStyle(color: Color.fromRGBO(107, 59, 225, 1)),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromRGBO(107, 59, 225, 1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromRGBO(107, 59, 225, 1)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Make button full width
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updateProductQuantity,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromRGBO(107, 59, 225, 1)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Update Quantity',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
