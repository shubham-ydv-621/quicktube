import 'package:flutter/material.dart';
import 'home_screen.dart';  // Import your HomeScreen
  // Import Settings screen

class BottomNavBar extends StatelessWidget {
  final int reelsScrolledToday;
  final bool isShortsScreen;
  final VoidCallback? onAutoScroll;

  BottomNavBar({required this.reelsScrolledToday, this.isShortsScreen = false, this.onAutoScroll});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _footerButton(Icons.home, "Home", context, '/home'),
          _footerButton(Icons.trending_up, "Trending", context, '/trending'),
          _counterButton(Icons.visibility, reelsScrolledToday),
          isShortsScreen
              ? _autoScrollButton()
              : _footerButton(Icons.settings, "Settings", context, '/settings'),
        ],
      ),
    );
  }

  Widget _footerButton(IconData icon, String label, BuildContext context, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, route);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _counterButton(IconData icon, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.redAccent, size: 26),
        SizedBox(height: 4),
        Text("$count", style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _autoScrollButton() {
    return GestureDetector(
      onTap: onAutoScroll,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.keyboard_arrow_down, color: Colors.greenAccent, size: 26),
          SizedBox(height: 4),
          Text("Scroll", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
        ],
      ),
    );
  }
}
