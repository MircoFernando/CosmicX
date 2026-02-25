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
  int _myRank = 0; // 0 means unranked/loading

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Fetch Top 10
    final leaders = await _userRepo.getLeaderboard();

    // 2. Fetch My Score (for the bottom bar)
    final myScore = await _userRepo.getUserScore();

    // 3. Determine My Rank (Simple local check)
    int myRank = 0;
    for (int i = 0; i < leaders.length; i++) {
      if (leaders[i]['id'] == _currentUserId) {
        myRank = i + 1;
        break;
      }
    }
    // If not in top 10, we don't know exact rank without expensive query,
    // so we just show "10+" or similar logic.

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

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: Text("HALL OF FAME", style: theme.textTheme.headlineSmall),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. THE PODIUM (Top 3)
          if (_leaders.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end, // Align bottom
                children: [
                  // 2nd Place
                  if (_leaders.length > 1) _buildPodiumItem(_leaders[1], 2, 80),
                  // 1st Place (Center, Big)
                  _buildPodiumItem(_leaders[0], 1, 110),
                  // 3rd Place
                  if (_leaders.length > 2) _buildPodiumItem(_leaders[2], 3, 80),
                ],
              ),
            ),

          // 2. THE LIST (Ranks 4+)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _leaders.length > 3 ? _leaders.length - 3 : 0,
                separatorBuilder: (ctx, i) =>
                    const Divider(color: Colors.white10),
                itemBuilder: (context, index) {
                  final actualIndex = index + 3; // Offset by top 3
                  final player = _leaders[actualIndex];
                  final isMe = player['id'] == _currentUserId;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[800],
                      child: Text(
                        "#${actualIndex + 1}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      player['name'],
                      style: TextStyle(
                        fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                        color: isMe ? theme.primaryColor : Colors.white,
                      ),
                    ),
                    trailing: Text(
                      "${player['score']} XP",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. MY RANK (Sticky Footer)
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.primaryColor,
                  child: const Icon(Icons.person, color: Colors.black),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "MY RANK",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      "CURRENT CADET",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _myRank > 0 ? "#$_myRank" : "Unranked",
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$_myScore XP",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> player, int rank, double size) {
    Color color = Colors.amber; // Gold
    if (rank == 2) color = Colors.grey.shade400; // Silver
    if (rank == 3) color = const Color(0xFFCD7F32); // Bronze

    final isMe = player['id'] == _currentUserId;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Crown Icon for #1
          if (rank == 1)
            const Icon(Icons.emoji_events, color: Colors.amber, size: 30),

          const SizedBox(height: 8),

          // Avatar Circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 4),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
              color: Colors.black,
            ),
            alignment: Alignment.center,
            child: Text(
              "#$rank",
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Name
          Text(
            player['name'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isMe ? Colors.blueAccent : Colors.white,
            ),
          ),

          // Score
          Text(
            "${player['score']} XP",
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
