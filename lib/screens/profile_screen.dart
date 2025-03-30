import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // User Information
  String name = 'John Doe';
  String email = 'johndoe@example.com';
  String? profileImage;

  final ImagePicker _picker = ImagePicker();

  void _editName(BuildContext context) {
    TextEditingController nameController = TextEditingController(text: name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Name'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: 'Enter your name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  name = nameController.text;
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editEmail(BuildContext context) {
    TextEditingController emailController = TextEditingController(text: email);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Email'),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(hintText: 'Enter your email'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  email = emailController.text;
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = pickedFile.path;
      });
    }
  }

  void _logout() {
    // Placeholder for logout logic
    print('User logged out');
    Navigator.pop(context); // Close the profile screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.bebasNeue(
            fontSize: 28,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Profile Picture with Image Picker
          SizedBox(height: 40),
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 70,
              backgroundImage: profileImage != null
                  ? FileImage(File(profileImage!))
                  : AssetImage('assets/images/user_profile.jpg') as ImageProvider,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          SizedBox(height: 20),

          // Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => _editName(context),
                icon: Icon(Icons.edit, color: Colors.black),
              ),
            ],
          ),

          // Email
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                email,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
              IconButton(
                onPressed: () => _editEmail(context),
                icon: Icon(Icons.edit, color: Colors.black),
              ),
            ],
          ),

          // Divider
          SizedBox(height: 30),
          Divider(color: Colors.black12, thickness: 0.5),

          // About Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About Me',
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Flutter Developer and tech enthusiast with a passion for creating engaging user experiences!',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ],
            ),
          ),

          Spacer(),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text('Log Out'),
              ),
            ],
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}