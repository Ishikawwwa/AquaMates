import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'locale_provider.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_friend.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

        // Check if it's a new day and reset the cups count if needed
        await _checkAndResetHydration();

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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Check if it's a new day and reset the cups count if needed
  Future<void> _checkAndResetHydration() async {
    if (userData != null && userData!['hydration'] != null) {
      var hydration = userData!['hydration'];
      int cups = hydration['cups'] ?? 0;
      int streak = hydration['streak'] ?? 0;
      Timestamp lastHydration = hydration['lastHydration'] ?? Timestamp.now();
      DateTime lastHydrationDate = lastHydration.toDate();

      DateTime currentDate = DateTime.now();
      String today = currentDate.toString().substring(0, 10);
      String lastHydrationString = lastHydrationDate.toString().substring(0, 10);

      // If it's a new day, reset the cups to 0
      if (today != lastHydrationString) {
        setState(() {
          userData!['hydration']['cups'] = 0;
        });

        // Update Firestore to reset cups to 0 for the new day
        await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
          'hydration.cups': 0,
          'hydration.lastHydration': Timestamp.now(),
        });
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
      userData = null;
      friendsData = [];
    });
    await fetchData();
  }

  // Method to add a cup of water and update Firestore
  Future<void> _addCup() async {
  try {
    final userRef = FirebaseFirestore.instance.collection('users').doc(widget.userId);
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      var hydrationData = userDoc['hydration'];
      int currentCups = hydrationData['cups'] ?? 0;
      int currentStreak = hydrationData['streak'] ?? 0;
      Timestamp lastHydration = hydrationData['lastHydration'];
      Timestamp? lastStreakUpdate = hydrationData['lastStreakUpdate'];

      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime lastStreakUpdateDate = lastStreakUpdate?.toDate() ?? DateTime(1970, 1, 1);
      DateTime lastHydrationDate = lastHydration.toDate();

      // Reset cups if last hydration was on a previous day
      if (lastHydrationDate.isBefore(today)) {
        currentCups = 0;
      }

      currentCups += 1;

      // Prepare data to update in Firestore
      Map<String, dynamic> updatedData = {
        'hydration.cups': currentCups,
        'hydration.lastHydration': Timestamp.now(),
      };

      // If the user drinks 8 or more cups and the streak was not updated today, increase streak
      if (currentCups >= 8 && lastStreakUpdateDate.isBefore(today)) {
        currentStreak += 1;
        updatedData['hydration.streak'] = currentStreak;
        updatedData['hydration.lastStreakUpdate'] = Timestamp.now();
      }

      // Update Firestore with the new data
      await userRef.update(updatedData);

      // Update local state
      setState(() {
        userData!['hydration']['cups'] = currentCups;
        if (updatedData.containsKey('hydration.streak')) {
          userData!['hydration']['streak'] = currentStreak;
        }
      });
    }
  } catch (e) {
    print('Error updating hydration data: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    final localeProvider = LocaleProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.hydrationProgress),
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
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              _changeLanguage(context, localeProvider);
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

  void _changeLanguage(BuildContext context, LocaleProvider? localeProvider) {
    // Toggle between English and Russian
    Locale newLocale = (localeProvider!.locale.languageCode == 'en')
        ? const Locale('ru')
        : const Locale('en');
    localeProvider.setLocale(newLocale);
  }

  Widget _buildUserHydrationSection() {
    if (userData == null) {
      return Text(AppLocalizations.of(context)!.noUserDataAvailable);
    }

    var hydration = userData!['hydration'];
    int cups = hydration['cups'];
    int streak = hydration['streak'];
    Timestamp lastHydration = hydration['lastHydration'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.yourHydrationProgress,
                style: GoogleFonts.raleway(
                    textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ))),
            const SizedBox(height: 10),
            Text("${AppLocalizations.of(context)!.todaysCups}: $cups",
                style: GoogleFonts.raleway(
                    textStyle: const TextStyle(fontSize: 16))),
            Text("${AppLocalizations.of(context)!.currentStreak}: $streak ${AppLocalizations.of(context)!.days}",
                style: GoogleFonts.raleway(
                    textStyle: const TextStyle(fontSize: 16))),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addCup,
              child: Text(AppLocalizations.of(context)!.addACup),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsHydrationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.friendsHydrationProgress,
            style: GoogleFonts.raleway(
                textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ))),
        const SizedBox(height: 10),
        friendsData.isEmpty
            ? Text(AppLocalizations.of(context)!.noFriendsAddedYet)
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
                      subtitle: Text("${AppLocalizations.of(context)!.todaysCups}: $cups\n${AppLocalizations.of(context)!.currentStreak}: $streak ${AppLocalizations.of(context)!.days}"),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
      ],
    );
  }
}
