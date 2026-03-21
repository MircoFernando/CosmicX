import 'package:cosmicx/data/models/apod_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApodModel unit tests', () {
    test('fromJson maps provided values correctly', () {
      final model = ApodModel.fromJson(<String, dynamic>{
        'title': 'Pillars of Creation',
        'url': 'https://example.com/image.jpg',
        'explanation': 'A famous deep-space image.',
        'date': '2026-03-21',
      });

      expect(model.title, equals('Pillars of Creation'));
      expect(model.url, equals('https://example.com/image.jpg'));
      expect(model.explanation, equals('A famous deep-space image.'));
      expect(model.date, equals('2026-03-21'));
    });

    test('fromJson applies fallback defaults when fields are missing', () {
      final model = ApodModel.fromJson(<String, dynamic>{});

      expect(model.title, equals('Cosmic Mystery'));
      expect(model.url, equals(''));
      expect(model.explanation, equals('No data available.'));
      expect(model.date, equals(''));
    });

    test('toJson returns serializable map with model values', () {
      final model = ApodModel(
        title: 'Andromeda',
        url: 'https://example.com/andromeda.jpg',
        explanation: 'Nearest major galaxy to the Milky Way.',
        date: '2026-01-01',
      );

      final json = model.toJson();

      expect(json['title'], equals('Andromeda'));
      expect(json['url'], equals('https://example.com/andromeda.jpg'));
      expect(
        json['explanation'],
        equals('Nearest major galaxy to the Milky Way.'),
      );
      expect(json['date'], equals('2026-01-01'));
    });
  });
}
