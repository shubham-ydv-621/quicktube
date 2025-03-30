import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Firebase configuration for initialization
import 'screens/splash_screen.dart'; // SplashScreen when initializing or checking auth status
import 'screens/home_screen.dart'; // HomeScreen after login
import 'screens/auth_screen.dart'; // AuthScreen for login/signup
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth for user state

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickTube+',
      theme: ThemeData(
        primarySwatch: Colors.red, // Set the primary color to red for your app
        useMaterial3: true, // Enabling Material 3 for the latest design system
      ),
      home: SplashWrapper(), // Start with the SplashScreen
      debugShowCheckedModeBanner: false, // Removes the debug banner for cleaner UI
    );
  }
}

class SplashWrapper extends StatefulWidget {
  @override
  _SplashWrapperState createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  @override
  void initState() {
    super.initState();
    // Simulate a splash screen delay
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthWrapper()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(); // Display Splash Screen
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Stream listens to authentication state
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen(); // Show splash screen while checking auth state
        } else if (snapshot.hasData) {
          return HomeScreen(); // If user is logged in, navigate to HomeScreen
        } else {
          return AuthScreen(); // If no user is logged in, show AuthScreen for login/signup
        }
      },
    );
  }
}
