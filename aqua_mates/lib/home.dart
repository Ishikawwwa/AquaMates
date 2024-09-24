import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'hydration.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in.")),
      );
    }

    return HydrationPage(userId: user.uid);
  }
}
