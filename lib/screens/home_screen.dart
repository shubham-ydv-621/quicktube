import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shorts_screen.dart';
import 'auth_screen.dart';
import 'bottom_nav_bar.dart';

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
    {'name': 'Vlogs', 'image': 'assets/images/vlogs.jpg'},
    {'name': 'Science & Space', 'image': 'assets/images/science_space.jpg'},
    {'name': 'Music & Dance', 'image': 'assets/images/music_dance.jpg'},
    {'name': 'Anime & Manga', 'image': 'assets/images/anime_manga.jpg'},
    {'name': 'Finance & Business', 'image': 'assets/images/finance_business.jpg'},
    {'name': 'Motivation & Self-Help', 'image': 'assets/images/motivation_selfhelp.jpg'},
    {'name': 'Sports & Adventure', 'image': 'assets/images/sports_adventure.jpg'},
    {'name': 'Short Films & Storytelling', 'image': 'assets/images/shortfilms_storytelling.jpg'},
    {'name': 'DIY & Life Hacks', 'image': 'assets/images/diy_lifehacks.jpg'},
    {'name': 'Automobiles & Gadgets', 'image': 'assets/images/automobiles_gadgets.jpg'},
  ];

  String searchQuery = "";
  final PageController _categoryController = PageController(viewportFraction: 0.75);
  int categoryIndex = 0;
  int reelsScrolledToday = 0;

  @override
  void initState() {
    super.initState();
    _loadScrollCount();
    _preloadCategoryImages(); // Preloading images for smoother scrolling
  }

  Future<void> _loadScrollCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toString().split(' ')[0];
    String lastSavedDate = prefs.getString('lastScrollDate') ?? "";

    if (lastSavedDate != today) {
      await prefs.setInt('reelsScrolled', 0);
      await prefs.setString('lastScrollDate', today);
      setState(() {
        reelsScrolledToday = 0;
      });
    } else {
      setState(() {
        reelsScrolledToday = prefs.getInt('reelsScrolled') ?? 0;
      });
    }
  }

  Future<void> _preloadCategoryImages() async {
    // Preload all category images into memory
    for (var category in allCategories) {
      await precacheImage(AssetImage(category['image']!), context);
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()),
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
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionWithSearch("Watch Shorts that Match Your Passion"),
          Expanded(
            child: _fullScreenCarousel(
              _categoryController,
              getFilteredItems(allCategories),
              (index) {
                setState(() => categoryIndex = index);
              },
              categoryIndex,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(reelsScrolledToday: reelsScrolledToday),
    );
  }

  Widget _sectionWithSearch(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 10),
          TextField(
            onChanged: (query) => setState(() => searchQuery = query.toLowerCase()),
            decoration: InputDecoration(
              hintText: "Search Shorts...",
              hintStyle: TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              prefixIcon: Icon(Icons.search, color: Colors.white),
            ),
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _fullScreenCarousel(PageController controller, List<Map<String, String>> items, Function(int) onPageChanged, int currentIndex) {
    return PageView.builder(
      controller: controller,
      itemCount: items.length * 1000,
      onPageChanged: (index) => onPageChanged(index % items.length),
      itemBuilder: (context, index) {
        int actualIndex = index % items.length;
        bool isCentered = actualIndex == currentIndex;
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ShortsScreen(category: items[actualIndex]['name']!),
              ),
            ).then((_) => setState(() {}));
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: isCentered ? 5 : 20),
            height: MediaQuery.of(context).size.height * 0.55,
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
    );
  }
}