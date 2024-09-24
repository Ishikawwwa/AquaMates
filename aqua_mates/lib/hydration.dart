import 'package:flutter/material.dart';

import 'add_friend.dart';

class HydrationPage extends StatelessWidget {
  final String userEmail;

  const HydrationPage({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hydration Progress"),
      ),
      body: Column(
        children: [
          _buildHydrationSection("Your Hydration Progress", userEmail),

          const SizedBox(height: 20),

          Expanded(
            child: _buildFriendsSection(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFriendPage(),
            ),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildHydrationSection(String title, String email) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("User: $email"),
            Text("Today's Progress: 5 cups of water"),
            Text("Current Streak: 3 days"),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsSection() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildHydrationSection("Friend $index", "friend$index@example.com");
      },
    );
  }
}
