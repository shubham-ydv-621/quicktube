import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart'; // Redirects to AuthScreen
import 'home_screen.dart'; // Import the HomeScreen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateBasedOnAuth();
  }

  // This function checks the auth state and navigates accordingly
  void _navigateBasedOnAuth() async {
    // Show the splash screen for a slightly longer delay (3 seconds)
    await Future.delayed(Duration(seconds: 3));

    // Wait for Firebase auth to initialize
    await FirebaseAuth.instance.authStateChanges().first;

    // Check if user is logged in
    User? user = FirebaseAuth.instance.currentUser;

    // Navigate to the appropriate screen based on the user's auth state
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => user == null ? AuthScreen() : HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purpleAccent, Colors.deepPurple, Colors.pink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated QuickTube Text with a cool glowing effect
              Row(
                mainAxisSize: MainAxisSize.min,
                children: "QuickTube".split("").asMap().entries.map((entry) {
                  int idx = entry.key;
                  String letter = entry.value;
                  return BounceInDown(
                    delay: Duration(milliseconds: idx * 100),
                    child: Text(
                      letter,
                      style: GoogleFonts.bebasNeue(
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 15,
                            color: Colors.purpleAccent.withOpacity(0.8),
                            offset: Offset(0, 0),
                          ),
                          Shadow(
                            blurRadius: 15,
                            color: Colors.pink.withOpacity(0.6),
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),

              // Tagline with a smooth fade effect
              FadeIn(
                delay: Duration(milliseconds: 500),
                child: Text(
                  'Count, Curate, Enjoy: The QuickTube Way',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Unique animated loading ring
              Pulse(
                child: CustomLoadingRing(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom animated loading ring with shimmer effect
class CustomLoadingRing extends StatefulWidget {
  @override
  _CustomLoadingRingState createState() => _CustomLoadingRingState();
}

class _CustomLoadingRingState extends State<CustomLoadingRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 6.28,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purpleAccent.withOpacity(0.6),
                  blurRadius: 12,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: Colors.pinkAccent.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
