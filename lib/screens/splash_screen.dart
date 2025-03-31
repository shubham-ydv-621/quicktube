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

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _navigateBasedOnAuth();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Navigate based on authentication state
  void _navigateBasedOnAuth() async {
    await Future.delayed(Duration(seconds: 3)); // Splash delay
    await FirebaseAuth.instance.authStateChanges().first;

    User? user = FirebaseAuth.instance.currentUser;
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
            colors: [Colors.black, Colors.grey.shade800, Colors.grey.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated App Name with modern typography and glow effect
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
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.blueAccent.withOpacity(0.7),
                            offset: Offset(0, 0),
                          ),
                          Shadow(
                            blurRadius: 10,
                            color: Colors.deepPurpleAccent.withOpacity(0.6),
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),

              // Modern tagline with gradient text effect
              FadeIn(
                delay: Duration(milliseconds: 500),
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.blueAccent, Colors.deepPurpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'Count, Curate, Enjoy: The QuickTube Way',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Sleek rotating "Q" with a futuristic style
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _controller.value * 6.28,
                    child: CustomPaint(
                      size: Size(80, 80),
                      painter: RevolvingQPainter(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for drawing a "Q"
class RevolvingQPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint circlePaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final Paint tailPaint = Paint()
      ..color = Colors.deepPurpleAccent
      ..style = PaintingStyle.fill;

    // Draw the circle (main "Q" body)
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2 - 8, circlePaint);

    // Draw the tail (the diagonal line of the "Q")
    final tailPath = Path();
    tailPath.moveTo(size.width * 0.7, size.height * 0.7);
    tailPath.lineTo(size.width * 0.9, size.height * 0.9);
    tailPath.lineTo(size.width * 0.75, size.height * 0.9);
    tailPath.close();
    canvas.drawPath(tailPath, tailPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}