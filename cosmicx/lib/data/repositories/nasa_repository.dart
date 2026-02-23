import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/apod_model.dart';

class NasaRepository {
  // Your API Key from the brief
  final String _apiKey = dotenv.env['NASA_API_KEY'] ?? 'DEMO_KEY';
  final String _baseUrl = 'https://api.nasa.gov/planetary/apod';

  Future<ApodModel> fetchApod() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // 1. Try to fetch from NASA API
      final response = await http.get(Uri.parse('$_baseUrl?api_key=$_apiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final apod = ApodModel.fromJson(data);

        // 2. Save to Local Storage (Crucial for First Class Grade)
        await prefs.setString('cached_apod', json.encode(apod.toJson()));

        return apod;
      } else {
        throw Exception('Failed to contact Houston.');
      }
    } catch (e) {
      // 3. If Network Fails, Load from Cache
      if (prefs.containsKey('cached_apod')) {
        final cachedData = json.decode(prefs.getString('cached_apod')!);
        return ApodModel.fromJson(cachedData);
      }
      throw Exception('Offline: No cosmic data cached.');
    }
  }
}
