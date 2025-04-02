import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatelessWidget {
  Future<void> addOrUpdateCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final usersRef = FirebaseFirestore.instance.collection('users');
      await usersRef.doc(user.uid).set({
        'email': user.email ?? 'No Email',
        'shortsCount': FieldValue.increment(0),
      }, SetOptions(merge: true));
    }
  }

  Stream<List<Map<String, dynamic>>> fetchUsersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .orderBy('shortsCount', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {
              'email': doc['email'] ?? 'No Email',
              'shortsCount': doc['shortsCount'] ?? 0,
            };
          }).toList();
        });
  }

  final List<String> rewards = [
    "🏆 Gold - \$100 Gift Card",
    "🥈 Silver - \$50 Gift Card",
    "🥉 Bronze - \$25 Gift Card"
  ];

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => addOrUpdateCurrentUser());

    return Scaffold(
      appBar: AppBar(
        title: Text("Leaderboard", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.deepOrangeAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "🔥 This Week's Top Uploaders",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Top 3 earn exciting rewards!",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.emoji_events, color: Colors.white, size: 36),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: fetchUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
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
                    child: Text("No users found", style: TextStyle(color: Colors.white)),
                  );
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    String reward = index < rewards.length ? rewards[index] : "✨ Keep Uploading!";
                    return Card(
                      color: index == 0 ? Colors.amber : Colors.grey[850],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: index == 0 ? Colors.orange : Colors.grey,
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        title: Text(
                          users[index]['email'],
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          reward,
                          style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.w600),
                        ),
                        trailing: Text(
                          "${users[index]['shortsCount']} Shorts",
                          style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}