import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Get the current total score from Firebase
  Future<int> getUserScore() async {
    final user = _auth.currentUser;
    if (user == null) return 0; // Safety check

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['score'] as int? ?? 0;
      }
      return 0; // Default if new user
    } catch (e) {
      print("Error fetching score: $e");
      return 0;
    }
  }

  // 2. Add points to Firebase (Transaction ensures accuracy)
  Future<int> updateUserScore(int sessionPoints) async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final userRef = _firestore.collection('users').doc(user.uid);

    // Run a transaction to safely update the score
    return await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);

      if (!snapshot.exists) {
        // First time user? Create the doc.
        transaction.set(userRef, {
          'score': sessionPoints,
          'email': user.email, // Useful for leaderboard later
          'last_active': FieldValue.serverTimestamp(),
        });
        return sessionPoints;
      }

      final currentScore = snapshot.data()?['score'] as int? ?? 0;
      final newTotal = currentScore + sessionPoints;

      transaction.update(userRef, {
        'score': newTotal,
        'last_active': FieldValue.serverTimestamp(),
      });

      return newTotal; // Return the new total to show in UI
    });
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('score', descending: true) // Highest score first
          .limit(10) // Only get top 10
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          // If name is missing, use "Cadet" + first 4 chars of ID
          'name': data['name'] ?? 'Cadet ${doc.id.substring(0, 4)}',
          'score': data['score'] ?? 0,
          'email': data['email'] ?? '',
        };
      }).toList();
    } catch (e) {
      print("Leaderboard Error: $e");
      return [];
    }
  }
}
