import 'package:flutter/material.dart'; // Importing Flutter's material design package for UI components.
import 'package:firebase_core/firebase_core.dart'; // Firebase package for initialization.
import 'firebase_options.dart'; // Firebase configuration file containing platform-specific settings.
import 'screens/splash_screen.dart'; // Splash screen to welcome users while loading resources.
import 'screens/home_screen.dart'; // Home screen shown after successful authentication.
import 'screens/auth_screen.dart'; // Screen for login or sign-up functionality.
import 'screens/leaderboard_screen.dart'; // Leaderboard screen to display user rankings.
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication package.
import 'screens/QuickCampusScreen.dart'; 
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures proper binding for async tasks during initialization.
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Initializes Firebase with platform-specific options.
  } catch (e) {
    print("Firebase Initialization Error: $e"); // Logs any errors during Firebase initialization.
  }
  runApp(MyApp()); // Runs the main application.
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickTube+', // Sets the app's title.
      theme: ThemeData(
        primarySwatch: Colors.red, // Applies a red color scheme to the app.
        useMaterial3: true, // Enables Material Design 3 for modern UI aesthetics.
      ),
      debugShowCheckedModeBanner: false, // Disables the debug banner.
      home: SplashWrapper(), // Starts the app with the splash wrapper.
      routes: {
        '/home': (context) => HomeScreen(), // Route to HomeScreen.
        '/auth': (context) => AuthScreen(), // Route to AuthScreen.
        '/leaderboard': (context) => LeaderboardScreen(), // Route to LeaderboardScreen.
          '/quickcampus': (context) => QuickCampusScreen(),
      },
    );
  }
}

class SplashWrapper extends StatefulWidget {
  @override
  _SplashWrapperState createState() => _SplashWrapperState(); // Creates the state for SplashWrapper.
}

class _SplashWrapperState extends State<SplashWrapper> {
  @override
  void initState() {
    super.initState(); // Ensures proper initialization.
    Future.delayed(Duration(seconds: 3), () { // Waits for 3 seconds before navigating to the next screen.
      _navigateToNextScreen(); // Calls the navigation method.
    });
  }

  void _navigateToNextScreen() {
    Navigator.pushReplacement( // Replaces the current screen with the next one.
      context,
      MaterialPageRoute(builder: (context) => AuthWrapper()), // Navigates to AuthWrapper.
    );
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(); // Displays the splash screen.
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Listens for authentication state changes.
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) { // While waiting for auth state updates:
          return SplashScreen(); // Show the splash screen.
        } else if (snapshot.hasData && snapshot.data != null) { // If a user is authenticated:
          return HomeScreen(); // Navigate to HomeScreen.
        } else { // If no user is authenticated:
          return AuthScreen(); // Navigate to AuthScreen.
        }
      },
    );
  }
}