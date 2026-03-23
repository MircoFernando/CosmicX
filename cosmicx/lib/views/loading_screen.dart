import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async'; // Timer
import 'auth_gate.dart';

class LoadingScreen extends StatefulWidget {
  final Function(bool)? onThemeChange;

  const LoadingScreen({super.key, this.onThemeChange});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // 5-second delay (simulating system checks)
    Timer(const Duration(seconds: 10), () {
      if (mounted) {
        // Navigate to the AuthGate
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AuthGate(onThemeChange: widget.onThemeChange),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
              child: ClipOval(
                child: Image.asset(
                  'assets/cosmix-logo.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "COSMICX QUEST",
              style: GoogleFonts.orbitron(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white24,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
