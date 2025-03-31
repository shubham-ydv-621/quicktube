import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase Firestore

class LeaderboardScreen extends StatelessWidget {
  // Save or update the authenticated user's details in Firestore
  Future<void> addOrUpdateCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser; // Get the authenticated user
    if (user != null) {
      final usersRef = FirebaseFirestore.instance.collection('users');
      final userDoc = await usersRef.doc(user.uid).get();

      if (!userDoc.exists) {
        // Add a new document if it doesn't exist
        await usersRef.doc(user.uid).set({
          'email': user.email ?? 'No Email', // Save the user's email
          'shortsCount': 0, // Initialize shortsCount to 0
        });
      } else {
        // Merge data to avoid overwriting shortsCount
        await usersRef.doc(user.uid).set({
          'email': user.email ?? 'No Email',
        }, SetOptions(merge: true));
      }
    } else {
      print("No authenticated user!");
    }
  }

  // Increment shortsCount when the user interacts with shorts
  Future<void> incrementShortsCount() async {
    final user = FirebaseAuth.instance.currentUser; // Get the authenticated user
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'shortsCount': FieldValue.increment(1), // Increment shortsCount
      });
    } else {
      print("No authenticated user!");
    }
  }

  // Real-time stream of all users from Firestore
  Stream<List<Map<String, dynamic>>> fetchUsersStream() {
    return FirebaseFirestore.instance
        .collection('users') // Collection containing users
        .orderBy('shortsCount', descending: true) // Sort by shortsCount in descending order
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {
              'email': doc['email'] ?? 'No Email', // Default to 'No Email' if email is missing
              'shortsCount': doc['shortsCount'] ?? 0, // Default to 0 if shortsCount is missing
            };
          }).toList();
        });
  }

  @override
  Widget build(BuildContext context) {
    // Ensure the current user is added to Firestore when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) => addOrUpdateCurrentUser());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Leaderboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fetchUsersStream(), // Real-time updates from Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Show loader while fetching data
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading leaderboard",
                style: TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return Center(
              child: Text(
                "No users found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return Card(
                  color: index == 0 ? Colors.amber : Colors.grey[850], // Highlight top user
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: index == 0 ? Colors.orange : Colors.grey,
                      child: Text(
                        "${index + 1}", // Rank number
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    title: Text(
                      users[index]['email'], // Display user email
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Text(
                      "${users[index]['shortsCount']} Shorts", // Display shorts count
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}