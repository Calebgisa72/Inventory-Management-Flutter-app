import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import "package:inventory_management/forgetpassword.dart";
import 'package:inventory_management/showDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register.dart';

// import 'Forget_Password_Page.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
   bool isLoading = false;
  void initstate() {
    _email = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 70,
          ),
          const Row(
            children: [
              SizedBox(
                width: 20,
              ),
              Text('Sign in to Bikaneza',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.deepOrangeAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Image.asset(
            "assets/images/login.png",
            height: MediaQuery.of(context).size.height * .200,
          ),
          const SizedBox(
            height: 40,
          ),
          Container(
            height: MediaQuery.of(context).size.height * .5,
            decoration: const BoxDecoration(
                color: Color.fromRGBO(107, 59, 225, .85),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18))),
            child: Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 40,
                ),
                TextField(
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: const Color.fromRGBO(107, 10, 225, 1),
                  decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.black,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      hintText: 'Enter your Email Here',
                      hintStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white))),
                ),
                const SizedBox(
                  height: 12,
                ),
                TextField(
                  cursorColor: const Color.fromRGBO(107, 10, 225, 1),
                  controller: _password,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                   
                    suffixIcon: Icon(
                      Icons.disabled_visible,
                      color: Colors.black,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    hintText: 'Enter your Password Here',
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    hintStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const ForgetPasswordPage();
                          }));
                        },
                        child: const Text('Forgot password?',
                            style: TextStyle(
                              color: Colors.black,
                            )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextButton(
                    style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        backgroundColor: WidgetStateProperty.all(
                            const Color.fromRGBO(107, 59, 225, 1)),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        )),
                    onPressed: () async {
  final email = _email.text;
  final password = _password.text;
  try {
    // Show loading indicator
    setState(() => isLoading = true);
    
    final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email, 
      password: password
    );
    
    final user = userCredential.user;
    
    if (user?.emailVerified ?? false) {
      // Save UID to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', user!.uid);
      
      // Navigate to home
      if (!mounted) return;
      GoRouter.of(context).go('/home');
    } else {
      if (!mounted) return;
      await showErrorDialog(context, 'Please verify your email first');
    }
  } on FirebaseAuthException catch (e) {
    if (!mounted) return;
    if (e.code == 'user-not-found') {
      await showErrorDialog(context, 'User Not Found');
    } else if (e.code == 'wrong-password') {
      await showErrorDialog(context, 'Wrong password Entered');
    }
  } finally {
    if (mounted) {
      setState(() => isLoading = false);
    }
  }
},
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 19,
                ),
                Row(
                  children: [
                    const Text(
                      "Don't Have an Account?",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(
                      width: 60,
                    ),
                    TextButton(
                      style: ButtonStyle(
                          foregroundColor:
                              WidgetStateProperty.all(Colors.white),
                          backgroundColor: WidgetStateProperty.all(
                              const Color.fromRGBO(107, 59, 225, 1)),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ))),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterView()));
                      },
                      child: const Text(
                        'Sign Up!!',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    ));
  }
}