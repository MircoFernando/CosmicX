import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart'; // The magic package
import 'main_hub_screen.dart'; // Your Home Screen

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. If user is logged in, show the App
        if (snapshot.hasData) {
          return const MainHubScreen();
        }

        // 2. If user is NOT logged in, show the Pre-built Login Screen
        return SignInScreen(
          providers: [
            EmailAuthProvider(), // Enable Email/Password
          ],
          headerBuilder: (context, constraints, shrinkOffset) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: AspectRatio(
                aspectRatio: 1,
                child: Icon(
                  Icons.rocket_launch,
                  size: 100,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            );
          },
          subtitleBuilder: (context, action) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: action == AuthAction.signIn
                  ? const Text('Welcome back, Commander. Please sign in.')
                  : const Text('New recruit? Register below.'),
            );
          },
          footerBuilder: (context, action) {
            return const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'By signing in, you agree to our interstellar terms and conditions.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          },
        );
      },
    );
  }
}
