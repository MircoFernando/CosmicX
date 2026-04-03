import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/apod_model.dart';

class NasaRepository {
  final String _apiKey = dotenv.env['NASA_API_KEY'] ?? 'DEMO_KEY';
  final String _baseUrl = 'https://api.nasa.gov/planetary/apod';

  Future<ApodModel> fetchApod() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // fetch from NASA API
      final response = await http.get(Uri.parse('$_baseUrl?api_key=$_apiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final apod = ApodModel.fromJson(data);

        // Save to Local Storage
        await prefs.setString('cached_apod', json.encode(apod.toJson()));

        return apod;
      } else {
        throw Exception('Failed to contact Houston.');
      }
    } catch (e) {
      //Load from Cache
      if (prefs.containsKey('cached_apod')) {
        final cachedData = json.decode(prefs.getString('cached_apod')!);
        return ApodModel.fromJson(cachedData);
      }
      throw Exception('Offline: No cosmic data cached.');
    }
  }

  // Fetch Near Earth Objects (Asteroids)
  Future<List<Map<String, dynamic>>> fetchAsteroids() async {
    final now = DateTime.now();
    final formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final url =
        'https://api.nasa.gov/neo/rest/v1/feed?start_date=$formattedDate&end_date=$formattedDate&api_key=$_apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final Map<String, dynamic> dates = data['near_earth_objects'];

      if (dates.containsKey(formattedDate)) {
        return List<Map<String, dynamic>>.from(dates[formattedDate]);
      }
      return [];
    } else {
      throw Exception('Failed to track asteroids.');
    }
  }

  // Fetch Earth Gallery (NASA Image Library)
  Future<List<Map<String, dynamic>>> fetchEarthGallery() async {
    final url = 'https://images-api.nasa.gov/search?q=earth&media_type=image';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List items = data['collection']['items'];

      return items
          .take(20)
          .map((item) {
            final data = item['data'][0];
            final links = item['links'] as List;

            return {
              'title': data['title'],
              'description': data['description'] ?? 'No description.',
              'image': links.isNotEmpty ? links[0]['href'] : '',
              'date': data['date_created'],
            };
          })
          .toList()
          .cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load Earth Gallery.');
    }
  }
}
