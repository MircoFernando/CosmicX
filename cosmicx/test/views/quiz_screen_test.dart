import 'dart:async';

import 'package:cosmicx/data/models/quiz_question.dart';
import 'package:cosmicx/data/repositories/quiz_repository.dart';
import 'package:cosmicx/data/repositories/user_repository.dart';
import 'package:cosmicx/views/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  group('QuizScreen simple widget tests', () {
    testWidgets('TC-WID-01 shows loading state first', (
      WidgetTester tester,
    ) async {
      // Arrange
      final questionsCompleter = Completer<List<QuizQuestion>>();
      final fakeQuizRepository = FakeQuizRepository(
        questionsCompleter: questionsCompleter,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: QuizScreen(
            repository: fakeQuizRepository,
            userRepository: FakeUserRepository(),
            flutterTts: FakeFlutterTts(),
          ),
        ),
      );

      // Act
      // No user action needed.

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      questionsCompleter.complete(FakeQuizRepository.dummyQuestions);
      await tester.pumpAndSettle();
    });

    testWidgets('TC-WID-02 renders dummy data after load', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: QuizScreen(
            repository: FakeQuizRepository(),
            userRepository: FakeUserRepository(),
            flutterTts: FakeFlutterTts(),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('What is the largest planet in our solar system?'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Mercury', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.textContaining('Earth', skipOffstage: false), findsOneWidget);
      expect(
        find.textContaining('Jupiter', skipOffstage: false),
        findsOneWidget,
      );
      expect(find.textContaining('Mars', skipOffstage: false), findsOneWidget);
    });

    testWidgets('TC-WID-03 tapping an option updates local UI state', (
      WidgetTester tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1200, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: QuizScreen(
            repository: FakeQuizRepository(),
            userRepository: FakeUserRepository(),
            flutterTts: FakeFlutterTts(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.textContaining('Jupiter', skipOffstage: false));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('CORRECT! +20 XP'), findsOneWidget);
      expect(find.text('FINISH QUEST'), findsOneWidget);
    });

    testWidgets('TC-WID-04 tapping wrong option shows incorrect state', (
      WidgetTester tester,
    ) async {
      // Arrange
      tester.view.physicalSize = const Size(1200, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: QuizScreen(
            repository: FakeQuizRepository(),
            userRepository: FakeUserRepository(),
            flutterTts: FakeFlutterTts(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.textContaining('Mercury', skipOffstage: false));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('INCORRECT'), findsOneWidget);
      expect(find.text('FINISH QUEST'), findsOneWidget);
    });

    testWidgets('TC-WID-05 shows empty-state when no questions exist', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: QuizScreen(
            repository: FakeQuizRepository(questions: <QuizQuestion>[]),
            userRepository: FakeUserRepository(),
            flutterTts: FakeFlutterTts(),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No quests available.'), findsOneWidget);
    });

    testWidgets('TC-WID-06 falls back to empty-state when load fails', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: QuizScreen(
            repository: FakeQuizRepository(throwOnFetchQuestions: true),
            userRepository: FakeUserRepository(),
            flutterTts: FakeFlutterTts(),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No quests available.'), findsOneWidget);
    });
  });
}

class FakeQuizRepository extends QuizRepository {
  FakeQuizRepository({
    this.questionsCompleter,
    this.questions,
    this.throwOnFetchQuestions = false,
  });

  final Completer<List<QuizQuestion>>? questionsCompleter;
  final List<QuizQuestion>? questions;
  final bool throwOnFetchQuestions;

  static final List<QuizQuestion> dummyQuestions = <QuizQuestion>[
    QuizQuestion(
      id: 'q1',
      question: 'What is the largest planet in our solar system?',
      options: <String>['Mercury', 'Earth', 'Jupiter', 'Mars'],
      answer: 'Jupiter',
      type: ApiType.apod,
      apiRef: '2025-01-01',
    ),
  ];

  @override
  Future<List<QuizQuestion>> fetchQuestions() async {
    if (throwOnFetchQuestions) {
      throw Exception('fake question fetch failure');
    }

    if (questionsCompleter != null) {
      return questionsCompleter!.future;
    }

    return questions ?? dummyQuestions;
  }

  @override
  Future<ApiContent> fetchLiveContent(QuizQuestion question) async {
    return ApiContent(
      'https://example.com/fake.jpg',
      'Jupiter is a gas giant and the largest planet.',
    );
  }
}

class FakeUserRepository extends UserRepository {
  @override
  Future<int> getUserScore() async => 100;

  @override
  Future<int> updateUserScore(int sessionPoints) async => 100 + sessionPoints;

  @override
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    return <Map<String, dynamic>>[
      <String, dynamic>{'id': 'u1', 'name': 'Test Cadet', 'score': 100},
    ];
  }
}

class FakeFlutterTts extends FlutterTts {
  @override
  Future<dynamic> setLanguage(String language) async => 1;

  @override
  Future<dynamic> setPitch(double pitch) async => 1;

  @override
  Future<dynamic> setSpeechRate(double rate) async => 1;

  @override
  Future<dynamic> stop() async => 1;

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async => 1;

  @override
  void setStartHandler(VoidCallback callback) {}

  @override
  void setCompletionHandler(VoidCallback callback) {}

  @override
  void setCancelHandler(VoidCallback callback) {}

  @override
  void setErrorHandler(ErrorHandler callback) {}
}
