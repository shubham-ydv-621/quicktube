import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Firebase configuration
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/leaderboard_screen.dart'; // Lowercase file naming for consistency
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    print("Firebase Initialization Error: $e"); // Log initialization error
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickTube+',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashWrapper(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/auth': (context) => AuthScreen(),
        '/leaderboard': (context) => LeaderboardScreen(), // Properly routed leaderboard
      },
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
    Future.delayed(Duration(seconds: 3), () {
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(); // Displays the splash screen for 3 seconds
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen(); // While waiting, show the splash screen
        } else if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen(); // Navigate to Home if the user is authenticated
        } else {
          return AuthScreen(); // Navigate to the Authentication screen otherwise
        }
      },
    );
  }
}