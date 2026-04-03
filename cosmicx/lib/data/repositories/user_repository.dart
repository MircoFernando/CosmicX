import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Get the current total score from Firebase
  Future<int> getUserScore() async {
    final user = _auth.currentUser;
    if (user == null) return 0; // Safety check

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return _asInt(doc.data()!['score']);
      }
      return 0; // Default if new user
    } catch (e) {
      return 0;
    }
  }

  // Add points to Firebase
  Future<int> updateUserScore(int sessionPoints) async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final userRef = _firestore.collection('users').doc(user.uid);

    return await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);

      if (!snapshot.exists) {
        // Create the doc.
        transaction.set(userRef, {
          'score': sessionPoints,
          'email': user.email,
          'last_active': FieldValue.serverTimestamp(),
        });
        return sessionPoints;
      }

      final currentScore = _asInt(snapshot.data()?['score']);
      final newTotal = currentScore + sessionPoints;

      transaction.update(userRef, {
        'score': newTotal,
        'last_active': FieldValue.serverTimestamp(),
      });

      return newTotal;
    });
  }

  Stream<int> watchUserScore() {
    final user = _auth.currentUser;
    if (user == null) return Stream<int>.value(0);

    return _firestore.collection('users').doc(user.uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return 0;
      return _asInt(data['score']);
    });
  }

  Stream<List<Map<String, dynamic>>> watchLeaderboard({int limit = 10}) {
    return _firestore
        .collection('users')
        .orderBy('score', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['name'] ?? 'Cadet ${doc.id.substring(0, 4)}',
              'score': _asInt(data['score']),
              'email': data['email'] ?? '',
            };
          }).toList();
        });
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('score', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Cadet ${doc.id.substring(0, 4)}',
          'score': _asInt(data['score']),
          'email': data['email'] ?? '',
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
