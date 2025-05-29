import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_management/BottomNavigationBar.dart';
import 'package:inventory_management/LoginScreen.dart';
import 'package:inventory_management/register.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Required for Firebase.initializeApp()

  await Firebase.initializeApp();

   await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug, // Use AndroidProvider.playIntegrity in production
  );
  runApp(MyApp()); // Replace MyApp with your app's widget
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Inventory',
      routerConfig: _router,
    );
  }

  final _router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const BottomNavigationScreen(),
      ),
    ],
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add a delay and navigate to the register page
    Future.delayed(const Duration(seconds: 10), () {
      GoRouter.of(context).go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome to Bikaneza ",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,color: Colors.deepOrangeAccent)),
            Stack(
              children: [
                Image.asset("assets/images/splesh.png"),
                Positioned(
                  top: MediaQuery.of(context).size.height * .2,
                  left: MediaQuery.of(context).size.width * .45,
                  child: const Center(child: CircularProgressIndicator()),
                )
              ],
            ),
            
          ],
        ), 
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  // Implement the registration UI here
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            GoRouter.of(context).go('/login');
          },
          child: const Text("login"),
        ),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            GoRouter.of(context).go('/home');
          },
          child: const Text("home"),
        ),
      ),
    );
  }
}
