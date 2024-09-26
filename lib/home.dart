import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'hydration.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            AppLocalizations.of(context)!.noUserLoggedIn,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      );
    }

    return HydrationPage(userId: user.uid);
  }
}