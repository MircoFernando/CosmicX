import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'leadership_screen.dart'; // Make sure this matches your file name

class MainHubScreen extends StatefulWidget {
  const MainHubScreen({super.key});

  @override
  State<MainHubScreen> createState() => _MainHubScreenState();
}

class _MainHubScreenState extends State<MainHubScreen> {
  int _selectedIndex = 0;

  List<Widget> get _screens => [
    const HomeScreen(),
    const ExploreScreen(),
    const LeaderboardScreen(),
    ProfileScreen(
      providers: [EmailAuthProvider()],
      avatarPlaceholderColor: Theme.of(context).primaryColor,
      actions: [
        SignedOutAction((context) {
          // Handled by AuthGate in main.dart
        }),
      ],
      children: [
        const Divider(),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Public Profile Settings",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        _buildNameUpdater(context),
      ],
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.rocket_launch),
            label: 'Explore',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Rank'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNameUpdater(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final TextEditingController controller = TextEditingController(
      text: user?.displayName,
    );
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Display Name (Leaderboard)",
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.blueAccent),
            onPressed: () async {
              if (user != null && controller.text.isNotEmpty) {
                final newName = controller.text.trim();

                // 1. Update Auth (The Login System)
                await user.updateDisplayName(newName);

                // 2. Update Firestore (The Leaderboard)
                await firestore.collection('users').doc(user.uid).set({
                  'name': newName,
                }, SetOptions(merge: true));

                // 3. Feedback
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Profile Updated on Leaderboard!"),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
