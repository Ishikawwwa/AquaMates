import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_friend.dart';
import 'package:google_fonts/google_fonts.dart';

class HydrationPage extends StatefulWidget {
  final String userId;

  const HydrationPage({super.key, required this.userId});

  @override
  _HydrationPageState createState() => _HydrationPageState();
}

class _HydrationPageState extends State<HydrationPage> {
  final DatabaseService _dbService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? userData;
  List<DocumentSnapshot> friendsData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fetch user and friends data
  Future<void> fetchData() async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>?;
        });

        List<dynamic> friendsIds = userData?['friends'] ?? [];

        if (friendsIds.isNotEmpty) {
          List<DocumentSnapshot> friendsDocs =
              await _dbService.getFriendsData(friendsIds);
          setState(() {
            friendsData = friendsDocs;
          });
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
      // Optionally, show an error message to the user
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Refresh data when returning to this page
  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      userData = null;
      friendsData = [];
    });
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hydration Progress"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signout(context: context);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserHydrationSection(),
                    const SizedBox(height: 20),
                    _buildFriendsHydrationSection(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to AddFriendPage and refresh data after returning
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFriendPage(),
            ),
          );
          _refreshData();
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildUserHydrationSection() {
    if (userData == null) {
      return const Text("No user data available.");
    }

    var hydration = userData!['hydration'];
    int cups = hydration['cups'];
    int streak = hydration['streak'];
    Timestamp lastHydration = hydration['lastHydration'];
    DateTime lastHydrationDate = lastHydration.toDate();

    // Optionally, add logic to update streak based on lastHydrationDate

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your Hydration Progress",
                style: GoogleFonts.raleway(
                    textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ))),
            const SizedBox(height: 10),
            Text("Today's Cups: $cups",
                style: GoogleFonts.raleway(
                    textStyle: const TextStyle(fontSize: 16))),
            Text("Current Streak: $streak days",
                style: GoogleFonts.raleway(
                    textStyle: const TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsHydrationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Friends' Hydration Progress",
            style: GoogleFonts.raleway(
                textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ))),
        const SizedBox(height: 10),
        friendsData.isEmpty
            ? const Text("No friends added yet.")
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: friendsData.length,
                itemBuilder: (context, index) {
                  var friend = friendsData[index].data() as Map<String, dynamic>;
                  String nickname = friend['nickname'] ?? 'No Name';
                  var hydration = friend['hydration'];
                  int cups = hydration['cups'];
                  int streak = hydration['streak'];

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(nickname),
                      subtitle: Text("Today's Cups: $cups\nStreak: $streak days"),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
      ],
    );
  }
}
