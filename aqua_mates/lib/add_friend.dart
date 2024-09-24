import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final TextEditingController _emailController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  bool isLoading = false;

  Future<void> _addFriend() async {
    String friendEmail = _emailController.text.trim();
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    if (friendEmail.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter an email address.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var friendDoc = await _dbService.getUserByEmail(friendEmail);

      if (friendDoc == null) {
        Fluttertoast.showToast(
          msg: "No user found with that email.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return;
      }

      String friendId = friendDoc.id;

      if (friendId == currentUserId) {
        Fluttertoast.showToast(
          msg: "You cannot add yourself as a friend.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return;
      }

      DocumentSnapshot currentUserDoc =
          await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
      List<dynamic> currentFriends = currentUserDoc['friends'] ?? [];

      if (currentFriends.contains(friendId)) {
        Fluttertoast.showToast(
          msg: "You are already friends with this user.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.orangeAccent,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return;
      }

      await _dbService.addFriend(currentUserId, friendId);

      Fluttertoast.showToast(
        msg: "Friend added successfully!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14.0,
      );

      _emailController.clear();

      Navigator.pop(context);
    } catch (e) {
      print("Error adding friend: $e");
      Fluttertoast.showToast(
        msg: "An error occurred while adding friend.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Friend"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Add a Friend by Email",
              style: GoogleFonts.raleway(
                textStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: "Enter friend's email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff0D6EFD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      minimumSize: const Size(double.infinity, 60),
                      elevation: 0,
                    ),
                    onPressed: _addFriend,
                    child: const Text("Add Friend"),
                  ),
          ],
        ),
      ),
    );
  }
}
