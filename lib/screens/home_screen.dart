import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'shorts_screen.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> allCategories = [
    {'name': 'Tech', 'image': 'assets/images/tech.jpg'},
    {'name': 'Gaming', 'image': 'assets/images/gaming.jpg'},
    {'name': 'Education', 'image': 'assets/images/education.jpg'},
    {'name': 'Comedy', 'image': 'assets/images/comedy.jpg'},
    {'name': 'Fitness', 'image': 'assets/images/fitness.jpg'},
    {'name': 'Coding', 'image': 'assets/images/coding.jpg'},
    {'name': 'India', 'image': 'assets/images/india.jpg'},
    {'name': 'Travel', 'image': 'assets/images/travel.jpg'},
    {'name': 'Food', 'image': 'assets/images/food.jpg'},
  ];

  String searchQuery = "";

  final PageController _categoryController = PageController(viewportFraction: 0.75);
  final PageController _globalNewsController = PageController(viewportFraction: 0.75);
  final PageController _indiaTrendingController = PageController(viewportFraction: 0.75);

  int categoryIndex = 0;
  int globalNewsIndex = 0;
  int indiaTrendingIndex = 0;

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()),
    );
  }

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_circle, size: 80, color: Colors.white),
              SizedBox(height: 10),
              Text("User Profile", style: GoogleFonts.poppins(fontSize: 22, color: Colors.white)),
              SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _logout,
                icon: Icon(Icons.logout),
                label: Text("Logout"),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, String>> getFilteredItems(List<Map<String, String>> items) {
    if (searchQuery.isEmpty) return items;
    return items.where((item) => item['name']!.toLowerCase().contains(searchQuery)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("QuickTube", style: GoogleFonts.bebasNeue(fontSize: 28, color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: _showProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionWithSearch("Discover Shorts that Match Your Passion"),
            _fullScreenCarousel(_categoryController, getFilteredItems(allCategories), (index) => setState(() => categoryIndex = index), categoryIndex),
            _sectionWithSearch("Explore What's Happening Around the Globe"),
            _fullScreenCarousel(_globalNewsController, getFilteredItems(List.generate(6, (index) => {'name': 'Global News $index', 'image': 'assets/images/global.jpg'})), (index) => setState(() => globalNewsIndex = index), globalNewsIndex),
            _sectionWithSearch("Trending in India - Stay Updated"),
            _fullScreenCarousel(_indiaTrendingController, getFilteredItems(List.generate(6, (index) => {'name': 'Trending India $index', 'image': 'assets/images/india.jpg'})), (index) => setState(() => indiaTrendingIndex = index), indiaTrendingIndex),
          ],
        ),
      ),
    );
  }

  Widget _sectionWithSearch(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(title, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: TextField(
            onChanged: (query) => setState(() => searchQuery = query.toLowerCase()),
            decoration: InputDecoration(
              hintText: "Search $title...",
              hintStyle: TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              prefixIcon: Icon(Icons.search, color: Colors.white),
            ),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _fullScreenCarousel(PageController controller, List<Map<String, String>> items, Function(int) onPageChanged, int currentIndex) {
    return Container(
      height: 320,
      child: PageView.builder(
        controller: controller,
        itemCount: items.length * 1000,
        onPageChanged: (index) => onPageChanged(index % items.length),
        itemBuilder: (context, index) {
          int actualIndex = index % items.length;
          bool isCentered = actualIndex == currentIndex;
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ShortsScreen(category: items[actualIndex]['name']!)));
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: isCentered ? 5 : 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: isCentered
                    ? [
                        BoxShadow(color: Colors.white.withOpacity(0.7), blurRadius: 12, spreadRadius: 2),
                        BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 20, spreadRadius: 10),
                      ]
                    : [],
                border: isCentered ? Border.all(color: Colors.white, width: 3) : null,
                image: DecorationImage(image: AssetImage(items[actualIndex]['image']!), fit: BoxFit.cover),
              ),
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.all(16),
              child: Text(
                items[actualIndex]['name']!,
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}
