import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart'; // Required for ProfileScreen
import 'home_screen.dart'; // Placeholder for Explore tab

class MainHubScreen extends StatefulWidget {
  const MainHubScreen({super.key});

  @override
  State<MainHubScreen> createState() => _MainHubScreenState();
}

class _MainHubScreenState extends State<MainHubScreen> {
  int _selectedIndex = 0;

  // List of screens for each tab
  // We use a getter (get _screens) because ProfileScreen needs 'context' in some setups,
  // but mostly to keep the list dynamic and clean.
  List<Widget> get _screens => [
    // Tab 0: Home (Placeholder for now)
    const HomeScreen(),

    // Tab 1:
    const Center(child: Text('Explore Screen: Mission list')),

    // Tab 2: Leaderboard (Placeholder)
    const Center(child: Text('Leaderboard: High scores')),

    // Tab 3: Profile (REAL Implementation)
    ProfileScreen(
      providers: [
        EmailAuthProvider(), // Tells Firebase we used Email/Password
      ],
      actions: [
        SignedOutAction((context) {
          // This is empty because the AuthGate in main.dart
          // automatically detects the logout and switches to Login screen.
        }),
      ],
      // Customizing the Profile Page Avatar
      avatarPlaceholderColor: Theme.of(context).primaryColor,
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
      // We use IndexedStack so the state of each tab is preserved
      // (e.g. if you scroll down in Explore, it stays scrolled when you come back)
      body: IndexedStack(index: _selectedIndex, children: _screens),

      bottomNavigationBar: BottomNavigationBar(
        // Force fixed type so all 4 icons show up properly
        type: BottomNavigationBarType.fixed,

        // Use the colors from your 'app_theme.dart'
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Theme.of(context).primaryColor, // Neon Blue
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
}
