import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/repositories/user_repository.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final UserRepository _userRepo = UserRepository();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  List<Map<String, dynamic>> _leaders = [];
  bool _isLoading = true;
  int _myScore = 0;
  int _myRank = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final leaders = await _userRepo.getLeaderboard();
    final myScore = await _userRepo.getUserScore();

    int myRank = 0;
    for (int i = 0; i < leaders.length; i++) {
      if (leaders[i]['id'] == _currentUserId) {
        myRank = i + 1;
        break;
      }
    }

    if (mounted) {
      setState(() {
        _leaders = leaders;
        _myScore = myScore;
        _myRank = myRank;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0D17),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true, // Allows gradient to go behind AppBar
      appBar: AppBar(
        title: const Text(
          "HALL OF FAME",
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        // 1. COSMIC BACKGROUND GRADIENT
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B0D17), // Deep Space Black
              Color(0xFF1A237E), // Nebula Blue
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 50),

            // 2. THE PODIUM (Top 3)
            if (_leaders.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 220, // Fixed height for podium area
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 2nd Place
                    if (_leaders.length > 1)
                      _buildPodiumItem(_leaders[1], 2, 90),
                    // 1st Place (Bigger & Higher)
                    _buildPodiumItem(_leaders[0], 1, 120),
                    // 3rd Place
                    if (_leaders.length > 2)
                      _buildPodiumItem(_leaders[2], 3, 90),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // 3. THE RANK LIST
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    100,
                  ), // Extra padding at bottom for sticky footer
                  itemCount: _leaders.length > 3 ? _leaders.length - 3 : 0,
                  itemBuilder: (context, index) {
                    final actualIndex = index + 3;
                    final player = _leaders[actualIndex];
                    // FIX: Compare IDs, not names, to find "Me"
                    final isMe = player['id'] == _currentUserId;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isMe
                            ? theme.primaryColor.withOpacity(0.2)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: isMe
                            ? Border.all(
                                color: theme.primaryColor.withOpacity(0.5),
                              )
                            : null,
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: Text(
                            "${actualIndex + 1}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          player['name'], // Displays the name from Firestore
                          style: TextStyle(
                            fontWeight: isMe
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isMe ? theme.primaryColor : Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${player['score']} XP",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amberAccent,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // 4. STICKY FOOTER (My Rank)
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF0B0D17),
          border: Border(
            top: BorderSide(color: theme.primaryColor.withOpacity(0.3)),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            // User Avatar Icon
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.primaryColor, width: 2),
              ),
              child: const CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 18,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
            const SizedBox(width: 15),

            // Text Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "MY RANK",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    letterSpacing: 1,
                  ),
                ),
                const Text(
                  "CURRENT CADET", // You can replace this with user.displayName if available locally
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Rank & Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _myRank > 0 ? "#$_myRank" : "Unranked",
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  "$_myScore XP",
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> player, int rank, double size) {
    Color color = const Color(0xFFFFD700); // Gold
    Color shadowColor = Colors.amber;
    IconData icon = Icons.emoji_events;

    if (rank == 2) {
      color = const Color(0xFFC0C0C0); // Silver
      shadowColor = Colors.grey;
      icon = Icons.stars;
    }
    if (rank == 3) {
      color = const Color(0xFFCD7F32); // Bronze
      shadowColor = Colors.brown;
      icon = Icons.star_half;
    }

    // FIX: Correct logic to highlight "Me" on podium
    final isMe = player['id'] == _currentUserId;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Crown/Icon
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),

          // Glowing Avatar Container
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withOpacity(0.5),
                  blurRadius: 25,
                  spreadRadius: 1,
                ),
              ],
              color: Colors.black,
              image: const DecorationImage(
                image: AssetImage(
                  'assets/images/astronaut_avatar.png',
                ), // Optional: Add a placeholder asset
                fit: BoxFit.cover,
                opacity:
                    0.5, // Dim background image if you don't have real avatars
              ),
            ),
            alignment: Alignment.center,
            child: isMe
                ? const Icon(Icons.person, color: Colors.white, size: 40)
                : Text(
                    "#$rank",
                    style: TextStyle(
                      fontSize: size * 0.35,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),

          const SizedBox(height: 12),

          // Name
          Text(
            player['name'],
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isMe ? Colors.blueAccent : Colors.white,
            ),
          ),

          // Score Badge
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.5), width: 0.5),
            ),
            child: Text(
              "${player['score']} XP",
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
