import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/quiz_question.dart';

class ApiContent {
  final String imageUrl;
  final String hint;
  ApiContent(this.imageUrl, this.hint);
}

class QuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _apiKey = dotenv.env['NASA_API_KEY'] ?? 'DEMO_KEY';

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

  Future<ApiContent> fetchLiveContent(QuizQuestion question) async {
    try {
      if (question.type == ApiType.apod) {
        return _fetchApodContent(question.apiRef);
      } else {
        // Now using NASA Image Library
        return _fetchLibraryContent(question.apiRef);
      }
    } catch (e) {
      return ApiContent(
        'https://via.placeholder.com/400x300?text=Signal+Lost',
        'Data uplink failed. Check connection.',
      );
    }
  }

  // --- APOD LOGIC (Unchanged) ---
  Future<ApiContent> _fetchApodContent(String date) async {
    final url =
        'https://api.nasa.gov/planetary/apod?api_key=$_apiKey&date=$date';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String fullHint = data['explanation'] ?? 'Cosmic wonder.';
      String shortHint = fullHint.length > 120
          ? "${fullHint.substring(0, 120)}..."
          : fullHint;
      return ApiContent(data['url'], shortHint);
    }
    throw Exception("APOD Failed");
  }

  // --- NEW: NASA IMAGE LIBRARY LOGIC ---
  Future<ApiContent> _fetchLibraryContent(String nasaId) async {
    // 1. Search by specific NASA ID (e.g., PIA24333)
    final url = 'https://images-api.nasa.gov/search?nasa_id=$nasaId';

    print("DEBUG LIB URL: $url");

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['collection']['items'] as List;

      if (items.isNotEmpty) {
        final item = items[0]; // Get the first result

        // 2. Extract Image URL
        // The image link is usually in the 'links' array
        String imageUrl = '';
        if (item['links'] != null) {
          imageUrl = item['links'][0]['href'];
          // Sometimes these are http, force https to avoid iOS errors
          imageUrl = imageUrl.replaceAll('http:', 'https:');
        }

        // 3. Extract Hint from Description
        String description =
            item['data'][0]['description'] ?? 'Classified Mars Data.';
        String shortHint = description.length > 120
            ? "${description.substring(0, 120)}..."
            : description;

        return ApiContent(imageUrl, shortHint);
      }
    }
    throw Exception("Library API Failed");
  }
}
