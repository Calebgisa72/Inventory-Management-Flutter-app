import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_management/Services/database.dart';
import 'package:inventory_management/Services/sqlite_database_service.dart';
import 'package:inventory_management/Services/push_notification_service.dart';
import 'package:inventory_management/models/products.dart';
import 'package:http/http.dart' as http;

class AddProductForm extends StatefulWidget {
  const AddProductForm({super.key});

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _distributorController = TextEditingController();
  final _categoryController = TextEditingController();
  final _pidController = TextEditingController();
  final _expiredateController = TextEditingController();

  File? _pickedImage;
  late FirebaseFirestore _firestore;
  User? user = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();

  // Add loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    // Initialize Push Notification Service
    PushNotificationService().initialize();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _pickedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<String> _uploadToCloudinary(File imageFile) async {
    final uploadUrl =
        'https://api.cloudinary.com/v1_1/sergerwanda/image/upload';

    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
      ..fields['upload_preset'] = 'flutter_upload'
      ..files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final respData = json.decode(responseData);

    return respData['secure_url'];
  }

  Future<void> _addProductToFirestore(Product newProduct) async {
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    // Set loading state to true
    setState(() {
      _isLoading = true;
    });

    try {
      final DatabaseServiceSqlite databaseService =
          DatabaseServiceSqlite.instance;

      databaseService.insertProduct({
        'name': newProduct.name,
        'pid': newProduct.pid,
        'quantity': newProduct.quantity,
        'price': newProduct.price,
        'distributor': newProduct.distributor,
        'category': newProduct.category,
        'expiredate': newProduct.expiredate,
      });

      final String imageUrl = await _uploadToCloudinary(_pickedImage!);

      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('products')
          .add({
        'name': newProduct.name,
        'pid': newProduct.pid,
        'quantity': newProduct.quantity,
        'price': newProduct.price,
        'distributor': newProduct.distributor,
        'category': newProduct.category,
        'expiredate': newProduct.expiredate,
        'imageUrl': imageUrl,
      });

      // Enhanced notification system similar to e-shopping reference
      await _sendComprehensiveProductNotification(newProduct);

      // Clear form after successful submission
      _nameController.clear();
      _pidController.clear();
      _expiredateController.clear();
      _quantityController.clear();
      _priceController.clear();
      _distributorController.clear();
      _categoryController.clear();
      setState(() {
        _pickedImage = null;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully')),
      );

      // Add a small delay before popping
      await Future.delayed(const Duration(milliseconds: 300));

      // Navigate back after success if context is still mounted
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error adding product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding product: $e')),
      );
    } finally {
      // Set loading state to false if still mounted
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Comprehensive notification system based on e-shopping reference
  Future<void> _sendComprehensiveProductNotification(Product product) async {
    try {
      final String currentUserId = user!.uid;
      final String notificationTitle = 'Product Added Successfully!';
      final String notificationBody =
          'New product "${product.name}" (ID: ${product.pid}) has been added to your inventory with quantity: ${product.quantity}';

      // 1. Send console notification
      await PushNotificationService()
          .sendProductAddedNotification(product.name);

      // 2. Show actual device notification (this will appear in device notification panel)
      await PushNotificationService().showDeviceNotification(
        title: notificationTitle,
        body: notificationBody,
        productName: product.name,
      );

      // 3. Store notification in Firestore for persistence
      await _storeProductNotification(
        userId: currentUserId,
        title: notificationTitle,
        body: notificationBody,
        productId: product.pid,
        productName: product.name,
        quantity: product.quantity,
      );

      // 4. Show in-app notification (SnackBar)
      PushNotificationService().showInAppNotification(context, product.name);

      print(
          '✅ Comprehensive notification system executed for product: ${product.name}');
    } catch (e) {
      print('❌ Error in comprehensive notification system: $e');
    }
  }

  // Store notification in Firestore (similar to e-shopping reference)
  Future<void> _storeProductNotification({
    required String userId,
    required String title,
    required String body,
    required String productId,
    required String productName,
    required int quantity,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'type': 'product_added',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
        'metadata': {
          'source': 'inventory_management',
          'action': 'product_creation',
          'userRole': 'inventory_manager',
        }
      });

      print('✅ Product notification stored in Firestore');
    } catch (e) {
      print('❌ Error storing product notification: $e');
    }
  }

  // Send FCM notification (similar to e-shopping reference)
  Future<void> _sendFCMProductNotification({
    required String title,
    required String body,
    required String userId,
    required Map<String, dynamic> productData,
  }) async {
    try {
      print('📱 Sending FCM notification for product to user: $userId');
      print('📱 Title: $title');
      print('📱 Body: $body');

      // Get the user's FCM token from Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print('❌ User document not found for ID: $userId');
        return;
      }

      if (!userDoc.data()!.containsKey('fcmToken')) {
        print('⚠️ No FCM token field found in user document: $userId');
        print('💡 Creating FCM message without token for manual processing');

        // Still store the message for potential manual processing
        await _firestore.collection('pendingProductNotifications').add({
          'userId': userId,
          'title': title,
          'body': body,
          'productData': productData,
          'createdAt': FieldValue.serverTimestamp(),
          'processed': false,
          'reason': 'no_fcm_token',
        });
        return;
      }

      final String userFcmToken = userDoc.data()!['fcmToken'];
      print(
          '📱 Retrieved FCM token: ${userFcmToken.substring(0, 10)}... (truncated)');

      if (userFcmToken.isNotEmpty) {
        try {
          // Primary method: Use fcmMessages collection
          print('📤 Writing to fcmMessages collection...');
          DocumentReference messageRef =
              await _firestore.collection('fcmMessages').add({
            'token': userFcmToken,
            'title': title,
            'body': body,
            'data': productData,
            'createdAt': FieldValue.serverTimestamp(),
            'processed': false,
            'type': 'product_notification',
            'priority': 'high',
          });

          print('✅ FCM message queued with ID: ${messageRef.id}');

          // Verify message processing after 5 seconds
          Future.delayed(const Duration(seconds: 5), () async {
            try {
              DocumentSnapshot messageDoc = await messageRef.get();
              if (messageDoc.exists) {
                Map<String, dynamic> messageData =
                    messageDoc.data() as Map<String, dynamic>;
                bool processed = messageData['processed'] ?? false;
                print('📊 FCM message status after 5s - Processed: $processed');

                if (!processed) {
                  print(
                      '⚠️ FCM message not processed yet. Check Cloud Functions.');
                }
              }
            } catch (e) {
              print('❌ Error checking FCM message status: $e');
            }
          });
        } catch (e) {
          print('❌ Error with fcmMessages collection: $e');

          // Fallback method: Use pendingNotifications collection
          try {
            print(
                '🔄 Attempting fallback to pendingNotifications collection...');
            DocumentReference pendingRef =
                await _firestore.collection('pendingNotifications').add({
              'token': userFcmToken,
              'title': title,
              'body': body,
              'data': productData,
              'createdAt': FieldValue.serverTimestamp(),
              'processed': false,
              'userId': userId,
              'type': 'product_notification',
              'fallback': true,
            });

            print('✅ Fallback notification queued with ID: ${pendingRef.id}');
          } catch (fallbackError) {
            print('❌ Error with fallback notification: $fallbackError');
          }
        }
      } else {
        print('❌ Empty FCM token for user: $userId');
      }
    } catch (e) {
      print('❌ Critical error in FCM notification flow: $e');

      // Emergency fallback: Store in emergency notifications collection
      try {
        await _firestore.collection('emergencyNotifications').add({
          'userId': userId,
          'title': title,
          'body': body,
          'productData': productData,
          'error': e.toString(),
          'createdAt': FieldValue.serverTimestamp(),
          'type': 'product_notification_failed',
        });
        print('🚨 Emergency notification stored due to error');
      } catch (emergencyError) {
        print('💥 Failed to store emergency notification: $emergencyError');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromRGBO(107, 59, 225, 1),
        title: const Text(
          "Add Items",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      // Add loading overlay
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      alignment: Alignment.center,
                      height: 150.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromRGBO(107, 59, 225, 1)),
                        borderRadius: BorderRadius.circular(10),
                        image: _pickedImage != null
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(_pickedImage!),
                              )
                            : null,
                      ),
                      child: _pickedImage == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo,
                                    color: Color.fromRGBO(107, 59, 225, 1)),
                                Text("Tap to add image",
                                    style: TextStyle(
                                        color:
                                            Color.fromRGBO(107, 59, 225, 1))),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  SingleChildScrollView(
                      child: Column(children: [
                    TextFormField(
                      controller: _nameController,
                      cursorColor: const Color.fromRGBO(107, 59, 225, 1),
                      decoration: const InputDecoration(
                          labelText: "Name",
                          labelStyle:
                              TextStyle(color: Color.fromRGBO(107, 59, 225, 1)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(107, 59, 225, 1))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(107, 59, 225, 1)))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _pidController,
                      cursorColor: const Color.fromRGBO(107, 59, 225, 1),
                      decoration: const InputDecoration(
                          labelText: "Product Id",
                          labelStyle:
                              TextStyle(color: Color.fromRGBO(107, 59, 225, 1)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(107, 59, 225, 1))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(107, 59, 225, 1)))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product Id';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _expiredateController,
                      cursorColor: const Color.fromRGBO(107, 59, 225, 1),
                      decoration: const InputDecoration(
                          labelText: "Expire Date",
                          labelStyle:
                              TextStyle(color: Color.fromRGBO(107, 59, 225, 1)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(107, 59, 225, 1))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(107, 59, 225, 1)))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter expire date';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _quantityController,
                      cursorColor: const Color.fromRGBO(107, 59, 225, 1),
                      decoration: const InputDecoration(
                          labelText: "Quantity",
                          labelStyle:
                              TextStyle(color: Color.fromRGBO(107, 59, 225, 1)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(107, 59, 225, 1))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(107, 59, 225, 1)))),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _priceController,
                      cursorColor: const Color.fromRGBO(107, 59, 225, 1),
                      decoration: const InputDecoration(
                          labelText: "Price",
                          labelStyle:
                              TextStyle(color: Color.fromRGBO(107, 59, 225, 1)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(107, 59, 225, 1))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(107, 59, 225, 1)))),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _distributorController,
                      cursorColor: const Color.fromRGBO(107, 59, 225, 1),
                      decoration: const InputDecoration(
                          labelText: "Distributer",
                          labelStyle:
                              TextStyle(color: Color.fromRGBO(107, 59, 225, 1)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(107, 59, 225, 1))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(107, 59, 225, 1)))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a distributor';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _categoryController,
                      cursorColor: const Color.fromRGBO(107, 59, 225, 1),
                      decoration: const InputDecoration(
                          labelText: "Category",
                          labelStyle:
                              TextStyle(color: Color.fromRGBO(107, 59, 225, 1)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(107, 59, 225, 1))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(107, 59, 225, 1)))),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a category';
                        }
                        return null;
                      },
                    ),
                  ])),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null // Disable button when loading
                        : () {
                            if (_formKey.currentState!.validate()) {
                              if (_pickedImage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Please select an image first')),
                                );
                                return;
                              }

                              Product newProduct = Product(
                                name: _nameController.text,
                                pid: _pidController.text,
                                quantity: int.parse(_quantityController.text),
                                price: double.parse(_priceController.text),
                                distributor: _distributorController.text,
                                category: _categoryController.text,
                                expiredate: _expiredateController.text,
                                imageUrl: _pickedImage!.path,
                              );

                              _addProductToFirestore(newProduct);
                            }
                          },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          const Color.fromRGBO(107, 59, 225, 1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            )
                          : const Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Full screen loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Color.fromRGBO(107, 59, 225, 1),
                        ),
                        SizedBox(height: 16),
                        Text("Adding product..."),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
