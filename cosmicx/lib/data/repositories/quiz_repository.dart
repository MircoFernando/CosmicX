import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/quiz_question.dart';

// Helper class to hold what we get from NASA
class ApiContent {
  final String imageUrl;
  final String hint;
  ApiContent(this.imageUrl, this.hint);
}

class QuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _apiKey = dotenv.env['NASA_API_KEY'] ?? 'DEMO_KEY';

  // 1. Fetch the Questions from Firestore
  Future<List<QuizQuestion>> fetchQuestions() async {
    try {
      final snapshot = await _firestore.collection('questions').get();
      return snapshot.docs.map((doc) {
        return QuizQuestion.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw Exception("Failed to load quests: $e");
    }
  }

  // 2. Fetch the Live Image/Hint from NASA
  Future<ApiContent> fetchLiveContent(QuizQuestion question) async {
    try {
      if (question.type == ApiType.apod) {
        return _fetchApodContent(question.apiRef);
      } else {
        return _fetchMarsContent(
          question.apiRef,
          question.roverName ?? 'curiosity',
        );
      }
    } catch (e) {
      return ApiContent(
        'https://via.placeholder.com/400x300?text=Signal+Lost',
        'Data uplink failed. Check connection.',
      );
    }
  }

  // --- PRIVATE HELPERS ---

  Future<ApiContent> _fetchApodContent(String date) async {
    final url =
        'https://api.nasa.gov/planetary/apod?api_key=$_apiKey&date=$date';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String fullHint = data['explanation'] ?? 'Cosmic wonder.';
      // Shorten the hint to 120 chars
      String shortHint = fullHint.length > 120
          ? "${fullHint.substring(0, 120)}..."
          : fullHint;

      return ApiContent(data['url'], shortHint);
    }
    throw Exception("APOD Failed");
  }

  Future<ApiContent> _fetchMarsContent(String sol, String rover) async {
    int solInt = int.tryParse(sol) ?? 1000;
    final url =
        'https://api.nasa.gov/mars-photos/api/v1/rovers/$rover/photos?sol=$solInt&api_key=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List photos = data['photos'];

      if (photos.isNotEmpty) {
        // Pick a random photo to make the quiz replayable
        final randomPhoto = photos[Random().nextInt(photos.length)];
        final cameraName = randomPhoto['camera']['full_name'];
        return ApiContent(
          randomPhoto['img_src'],
          "Captured by $rover using the $cameraName.",
        );
      }
    }
    throw Exception("Mars Failed");
  }
}
