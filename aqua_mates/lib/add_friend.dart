import 'package:aqua_mates/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        msg: AppLocalizations.of(context)!.pleaseEnterAnEmailAddress,
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
          msg: AppLocalizations.of(context)!.noUserFoundWithThatEmail,
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
          msg: AppLocalizations.of(context)!.youAreAlreadyFriendsWithThisUser,
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
        msg: AppLocalizations.of(context)!.friendAddedSuccessfully,
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
        msg: AppLocalizations.of(context)!.anErrorOccurredWhileAddingFriend,
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

  void _changeLanguage(BuildContext context, LocaleProvider? localeProvider) {
    // Toggle between English and Russian
    Locale newLocale = (localeProvider!.locale.languageCode == 'en')
        ? const Locale('ru')
        : const Locale('en');
    localeProvider.setLocale(newLocale);
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = LocaleProvider.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(AppLocalizations.of(context)!.addFriend),
        actions: [
          IconButton(
            padding: const EdgeInsets.all(16),
            icon: const Icon(Icons.language),
            onPressed: () {
              _changeLanguage(context, localeProvider);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.addAFriendByEmail,
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
                filled: true,
                hintText: AppLocalizations.of(context)!.enterFriendsEmail,
                hintStyle: const TextStyle(
                  color: Color(0xff6A6A6A),
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                fillColor: const Color(0xffF7F7F9),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 50),
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
                    child: Text(
                      AppLocalizations.of(context)!.addFriend,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white
                      )
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
