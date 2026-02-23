import 'package:flutter/material.dart';
import 'dart:async'; // For the Timer
import 'auth_gate.dart'; // <--- CHANGED: Import the Gate, not the Login Screen

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

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
        // The Gate will decide whether to show 'Login' or 'Home'
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This part stays exactly the same!
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.rocket_launch,
              size: 100,
              color: Color(0xFF00D4FF),
            ),
            const SizedBox(height: 20),
            Text(
              "COSMIC QUEST",
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white24,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Initializing systems...",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
