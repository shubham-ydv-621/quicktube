import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

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

  void _navigateBasedOnAuth() async {
    await Future.delayed(Duration(seconds: 3));
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
            colors: [Colors.black, Colors.grey.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: "QuickTube".split(" ").map((word) {
                  return BounceInDown(
                    child: Text(
                      word,
                      style: GoogleFonts.pacifico(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 15,
                            color: Colors.redAccent.withOpacity(0.8),
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              FadeIn(
                delay: Duration(milliseconds: 500),
                child: Text(
                  'Watch, Discover, Enjoy',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.pinkAccent,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              SizedBox(height: 30),
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

class RevolvingQPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final Paint tailPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2 - 8, circlePaint);

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
