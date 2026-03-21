import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart'; // The magic package
import 'package:google_fonts/google_fonts.dart';
import 'main_hub_screen.dart'; // Your Home Screen

class AuthGate extends StatelessWidget {
  final Function(bool)? onThemeChange;

  const AuthGate({super.key, this.onThemeChange});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. If user is logged in, show the App
        if (snapshot.hasData) {
          return MainHubScreen(onThemeChange: onThemeChange);
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
                child: Image.asset(
                  'assets/cosmix-logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
          subtitleBuilder: (context, action) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: action == AuthAction.signIn
                  ? Text(
                      'Welcome back, Commander. Please sign in.',
                      style: GoogleFonts.inter(),
                    )
                  : Text(
                      'New recruit? Register below.',
                      style: GoogleFonts.inter(),
                    ),
            );
          },
          footerBuilder: (context, action) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'By signing in, you agree to our interstellar terms and conditions.',
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            );
          },
        );
      },
    );
  }
}
