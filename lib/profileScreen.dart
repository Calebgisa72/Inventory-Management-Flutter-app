import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_management/models/usermodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileEditPage extends StatelessWidget {
  final myUser user;
  const ProfileEditPage(this.user, {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(107, 59, 225, 1),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ProfileEditForm(user: user),
    );
  }
}

class ProfileEditForm extends StatefulWidget {
  final myUser user;

  const ProfileEditForm({super.key, required this.user});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileEditFormState createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  late FirebaseFirestore _firestore;

  late File _pickedImage; // Use File for selected image

  late ImagePicker _imagePicker;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
    _pickedImage = File('');
    _initializeControllers();
    _firestore = FirebaseFirestore.instance;
  }

  void _initializeControllers() {
    _fullNameController.text = widget.user.name;
    _phoneController.text = widget.user.phone;
    _usernameController.text = widget.user.username;
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: _pickImage,
            child: Container(
              alignment: Alignment.center,
              height: 150.0,
              width: 150,
              decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.deepOrange),
                borderRadius: BorderRadius.circular(100),
              ),
              child: _pickedImage.path.isEmpty
                  ? const Icon(Icons.camera_alt,
                      size: 60.0, color: Colors.black)
                  : Image.file(
                      _pickedImage, // Use the File object here
                      fit: BoxFit.fill,
                    ),
            ),
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _fullNameController,
            cursorColor: const Color.fromRGBO(107, 59, 225, 1),
            decoration: const InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: Color.fromRGBO(107, 59, 225, 1)),
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromRGBO(107, 59, 225, 1))),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromRGBO(107, 59, 225, 1)))),
          ),
          const SizedBox(height: 8.0),
          const SizedBox(height: 8.0),
          TextFormField(
            controller: _phoneController,
            cursorColor: const Color.fromRGBO(107, 59, 225, 1),
            decoration: const InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(color: Color.fromRGBO(107, 59, 225, 1)),
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromRGBO(107, 59, 225, 1))),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromRGBO(107, 59, 225, 1)))),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            controller: _usernameController,
            cursorColor: const Color.fromRGBO(107, 59, 225, 1),
            decoration: const InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Color.fromRGBO(107, 59, 225, 1)),
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromRGBO(107, 59, 225, 1))),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromRGBO(107, 59, 225, 1)))),
          ),
          const SizedBox(height: 8.0),
          const SizedBox(height: 16.0),
          ElevatedButton(
              style: const ButtonStyle(
                alignment: Alignment(23, 34),
                  padding: WidgetStatePropertyAll(
                    
                      EdgeInsets.symmetric(horizontal: 25, vertical: 23)),
                  backgroundColor:
                      WidgetStatePropertyAll(Color.fromRGBO(107, 59, 225, 1)),
                      shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10))))),
              onPressed: () async {
                Map<String, dynamic> updateUserInfo = {};
                if (_fullNameController != widget.user.name) {
                  updateUserInfo['name'] = _fullNameController.text;
                }
                if (_phoneController.text != widget.user.phone.toString()) {
                  updateUserInfo['phone'] = _phoneController.text;
                }

                if (_usernameController.text != widget.user.username) {
                  updateUserInfo['username'] = _usernameController.text;
                }

                // Upload the new image if selected
                if (_pickedImage.existsSync() &&
                    _pickedImage.path != widget.user.imageUrl) {
                  final String fileName =
                      DateTime.now().millisecondsSinceEpoch.toString();
                  final Reference storageReference = FirebaseStorage.instance
                      .ref()
                      .child('Users_images/$fileName.jpg');
                  final UploadTask uploadTask =
                      storageReference.putFile(_pickedImage);

                  TaskSnapshot taskSnapshot = await uploadTask;
                  String imageUrl = await taskSnapshot.ref.getDownloadURL();
                  updateUserInfo['imageUrl'] = imageUrl; // Update the image URL
                }

                try {
                  await _firestore
                      .collection('users')
                      .doc(widget.user.uid)
                      .update(updateUserInfo);
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile  updated successfully'),
                    ),
                  );
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context, true);
                } catch (error) {
                  // ignore: avoid_print
                  print('Error updating User Info: $error');
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error updating product'),
                    ),
                  );
                }
                setState(() {
                  _pickedImage = File(''); // Clear the picked image
                });
              },
              child: const Text(
                'Save Changes',
                style: TextStyle(color: Colors.white),
              )),
        ],
      )),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  myUser? _user;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    User? firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            "No user is signed in. Please sign in to view your profile.";
      });
      return;
    }

    try {
      // First check if the user document exists
      DocumentSnapshot userDocSnapshot =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDocSnapshot.exists) {
        // If user document doesn't exist, create one with default values
        await _createDefaultUserProfile(firebaseUser);
        // Fetch again after creating
        userDocSnapshot =
            await _firestore.collection('users').doc(firebaseUser.uid).get();
      }

      // Now we should have a user document
      Map<String, dynamic> userData =
          userDocSnapshot.data() as Map<String, dynamic>;

      setState(() {
        _user = myUser(
          uid: firebaseUser.uid,
          name: userData['name'] ?? firebaseUser.displayName ?? 'User',
          username: userData['username'] ??
              firebaseUser.email?.split('@')[0] ??
              'Username',
          phone: userData['phone'] ?? '',
          imageUrl: userData['imageUrl'] ??
              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userData['name'] ?? firebaseUser.displayName ?? 'User')}&background=6B3BE1&color=fff',
        );
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load profile data. Please try again.";
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    if (context.mounted) GoRouter.of(context).go('/login');
  }

  // Create default user profile if none exists
  Future<void> _createDefaultUserProfile(User firebaseUser) async {
    try {
      String defaultName = firebaseUser.displayName ?? 'User';
      String defaultUsername = firebaseUser.email?.split('@')[0] ?? 'user';

      await _firestore.collection('users').doc(firebaseUser.uid).set({
        'name': defaultName,
        'username': defaultUsername,
        'phone': '',
        'email': firebaseUser.email ?? '',
        'imageUrl': firebaseUser.photoURL ??
            'https://ui-avatars.com/api/?name=${Uri.encodeComponent(defaultName)}&background=6B3BE1&color=fff',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("Created default profile for user: ${firebaseUser.uid}");
    } catch (e) {
      print("Error creating default profile: $e");
    }
  }

  Future<void> _loadUserProfile() async {
    // Load user profile data and update _userProfile
    // Use your data fetching mechanism, such as Firestore

    setState(() {
      _fetchUserData();
    });
  }

  void _navigateToProfileEdit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditPage(_user!),
      ),
    );
    _loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(107, 59, 225, 1),
        title: const Text(
          'Profile Page',
          style: TextStyle(
            color: Colors.yellow,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                            Colors.black,
                        ),
                        onPressed: _fetchUserData,
                        child: const Text(
                          'Try Again',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      CircleAvatar(
                        backgroundColor:Colors.white,
                        radius: 80,
                        backgroundImage: NetworkImage(
                          _user?.imageUrl ??
                              'https://ui-avatars.com/api/?name=User&background=6B3BE1&color=fff',
                        ),
                        onBackgroundImageError: (_, __) {
                          // Handle image loading error
                        },
                        child: _user?.imageUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.black12,
                              )
                            : null,
                      ),
                      const SizedBox(height: 20),
                      _buildProfileCard(
                        title: 'Full Name',
                        value: _user?.name ?? 'Not provided',
                        icon: Icons.person,
                      ),
                      _buildProfileCard(
                        title: 'Username',
                        value: _user?.username ?? 'Not provided',
                        icon: Icons.alternate_email,
                      ),
                      _buildProfileCard(
                        title: 'Phone',
                        value: _user?.phone?.isEmpty == true
                            ? 'Not provided'
                            : _user?.phone ?? 'Not provided',
                        icon: Icons.phone,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed:
                            _user != null ? _navigateToProfileEdit : null,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                            const Color.fromRGBO(107, 59, 225, 1),
                          ),
                          padding: WidgetStateProperty.all<EdgeInsets>(
                            const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                        ),
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color.fromRGBO(107, 59, 225, 0.2),
          child: Icon(icon, color: const Color.fromRGBO(107, 59, 225, 1)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ProfilePage(),
    );
  }
}
