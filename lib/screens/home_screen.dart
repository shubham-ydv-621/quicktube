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
    {'name': 'Coding', 'image': 'assets/images/coding.jpg'},
    {'name': 'Fitness', 'image': 'assets/images/fitness.jpg'},
    {'name': 'Travel', 'image': 'assets/images/travel.jpg'},
    {'name': 'Food', 'image': 'assets/images/food.jpg'},
    {'name': 'India', 'image': 'assets/images/india.jpg'},
    {'name': 'Science & Space', 'image': 'assets/images/science_space.jpg'},
    {'name': 'Tech', 'image': 'assets/images/tech.jpg'},
    {'name': 'Gaming', 'image': 'assets/images/gaming.jpg'},
    {'name': 'Education', 'image': 'assets/images/education.jpg'},
    {'name': 'Comedy', 'image': 'assets/images/comedy.jpg'},
    {'name': 'Vlogs', 'image': 'assets/images/vlogs.jpg'},
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
    _preloadCategoryImages();
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
    for (var category in allCategories) {
      await precacheImage(AssetImage(category['image']!), context);
    }
  }
void _showProfilePopup() async {
  User? user = FirebaseAuth.instance.currentUser;
  await user?.reload(); // Refresh to get the latest data

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Profile Info",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              user?.displayName ?? "Name not set",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              user?.email ?? "Email not available",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: _logout,
              child: Text(
                "Logout",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _showDeveloperInfo,
              child: Text(
                "About Developers",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _showDeveloperInfo() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Developers",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _developerEmail("Shubham Yadav", "Shubham22csu444@ncuindia.edu"),
            _developerEmail("Tanishq", "Tanishq22csu451@ncuindia.edu"),
            _developerEmail("Deepanshu yadav", "Deepanshu22csu476@ncuindia.edu"),
          ],
        ),
      );
    },
  );
}

Widget _developerEmail(String name, String email) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Column(
      children: [
        Text(
          name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          email,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),
      ],
    ),
  );
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
        titleSpacing: 0,
          title: Padding(
        padding: EdgeInsets.only(left: 0),
        child: Text(
        "QuickTube",
        style: GoogleFonts.bebasNeue(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(blurRadius: 8, color: Colors.pinkAccent.withOpacity(0.8), offset: Offset(0, 2)),
            Shadow(blurRadius: 4, color: Colors.black.withOpacity(0.5), offset: Offset(0, 3)),
          ],
        ),
      ),
          ),
      backgroundColor: Colors.black,
      elevation: 3, // Adding a subtle elevation for a modern layered effect
      actions: [
        IconButton(
          icon: Icon(
            Icons.account_circle,
            color: Colors.pinkAccent, // Highlighted with pinkish-red for better contrast
            size: 30,
          ),
          onPressed: _showProfilePopup,
          tooltip: "Profile",
        ),
      ],
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionWithSearch("Explore, Count and Earn."), // Updated, modern tagline
        Expanded(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: _fullScreenCarousel(
              _categoryController,
              getFilteredItems(allCategories),
              (index) {
                setState(() => categoryIndex = index);
              },
              categoryIndex,
            ),
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
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
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

  Widget _fullScreenCarousel(
    PageController controller,
    List<Map<String, String>> items,
    Function(int) onPageChanged,
    int currentIndex,
  ) {
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
                      BoxShadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 12, spreadRadius: 2),
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, spreadRadius: 10),
                    ]
                  : [],
              border: isCentered ? Border.all(color: Colors.white, width: 3) : null,
              image: DecorationImage(image: AssetImage(items[actualIndex]['image']!), fit: BoxFit.cover),
            ),
            alignment: Alignment.bottomLeft,
            padding: EdgeInsets.all(16),
                       child: Text(
              items[actualIndex]['name']!,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}