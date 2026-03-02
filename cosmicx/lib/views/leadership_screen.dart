import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final user = FirebaseAuth.instance.currentUser;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LEADERBOARD',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top 3 Podium Section
          if (_leaders.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Top Explorers',
                    style: GoogleFonts.orbitron(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 2nd Place
                      if (_leaders.length > 1)
                        _buildPodiumItem(_leaders[1], 2, 70),
                      const SizedBox(width: 12),
                      // 1st Place (Bigger)
                      _buildPodiumItem(_leaders[0], 1, 90),
                      const SizedBox(width: 12),
                      // 3rd Place
                      if (_leaders.length > 2)
                        _buildPodiumItem(_leaders[2], 3, 70),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 10),

          // Remaining Players List
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
              ),
              child: _leaders.length > 3
                  ? ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                      itemCount: _leaders.length - 3,
                      itemBuilder: (context, index) {
                        final actualIndex = index + 3;
                        final player = _leaders[actualIndex];
                        final isMe = player['id'] == _currentUserId;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: isMe
                                ? theme.primaryColor.withOpacity(0.1)
                                : theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isMe
                                  ? theme.primaryColor.withOpacity(0.5)
                                  : theme.primaryColor.withOpacity(0.1),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 45,
                              height: 45,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.primaryColor.withOpacity(0.1),
                              ),
                              child: Text(
                                '${actualIndex + 1}',
                                style: GoogleFonts.orbitron(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            title: Text(
                              player['name'],
                              style: GoogleFonts.inter(
                                fontWeight: isMe
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${player['score']} XP',
                                style: GoogleFonts.orbitron(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'No more players',
                        style: GoogleFonts.inter(color: Colors.grey[600]),
                      ),
                    ),
            ),
          ),
        ],
      ),

      // User's Rank Footer
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.primaryColor.withOpacity(0.8), theme.primaryColor],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user?.displayName ?? 'Cosmic Explorer',
                    style: GoogleFonts.orbitron(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'My Rank',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _myRank > 0 ? '#$_myRank' : 'Unranked',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '$_myScore XP',
                  style: GoogleFonts.orbitron(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
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
    final theme = Theme.of(context);
    Color color = const Color(0xFFFFD700); // Gold
    IconData icon = Icons.emoji_events;

    if (rank == 2) {
      color = const Color(0xFFC0C0C0); // Silver
      icon = Icons.military_tech;
    }
    if (rank == 3) {
      color = const Color(0xFFCD7F32); // Bronze
      icon = Icons.workspace_premium;
    }

    final isMe = player['id'] == _currentUserId;

    return SizedBox(
      width: size + 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Trophy Icon
          Icon(icon, color: color, size: rank == 1 ? 32 : 24),
          const SizedBox(height: 8),

          // Avatar Container
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
              color: theme.primaryColor.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              isMe ? Icons.person : Icons.star,
              color: color,
              size: size * 0.5,
            ),
          ),

          const SizedBox(height: 8),

          // Name
          Text(
            player['name'],
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isMe ? theme.primaryColor : null,
            ),
          ),

          const SizedBox(height: 4),

          // Score Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Text(
              '${player['score']} XP',
              style: GoogleFonts.orbitron(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
