import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  static const String _keyScore = 'user_xp_score';

  // 1. Get current total score
  Future<int> getScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyScore) ?? 0; // Default to 0 if new user
  }

  // 2. Add points to the total
  Future<void> addPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    final currentScore = prefs.getInt(_keyScore) ?? 0;
    await prefs.setInt(_keyScore, currentScore + points);
  }
}
