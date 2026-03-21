# Cosmic Quest - Quiz Widget Testing Process

## Purpose
This document explains how simple widget tests were implemented for QuizScreen in isolation.

## Scope
- Widget under test: QuizScreen
- Test file: test/views/quiz_screen_test.dart
- Test type: Simple widget tests only
- Not included: integration tests, full app navigation, routing tests

## Isolation Strategy
Each test pumps only the target widget using:

MaterialApp(home: QuizScreen(...))

No real Firebase, HTTP, or external services are used during tests.

## Dependency Injection Used
QuizScreen is tested with injected fake dependencies:
- FakeQuizRepository extends QuizRepository
- FakeUserRepository extends UserRepository
- FakeFlutterTts extends FlutterTts

This ensures deterministic test results without network/database side effects.

## 3 A's Test Structure
Each test follows Arrange, Act, Assert:
- Arrange: Build fake state and pump widget
- Act: Trigger optional interaction (tap, settle)
- Assert: Verify expected UI with find/expect

## Test Data and Behavior Setup
FakeQuizRepository supports multiple scenarios:
- Loading simulation via Completer<List<QuizQuestion>>
- Default successful question payload
- Empty list payload
- Exception throw path (fetch failure)

FakeUserRepository returns fixed score values.
FakeFlutterTts no-ops all calls required by QuizScreen lifecycle.

## Command Used to Run Tests
Run only the QuizScreen suite:

flutter test test/views/quiz_screen_test.dart

## Current Test Coverage Summary
| Test ID | Component | Test Description | Expected Outcome |
| :--- | :--- | :--- | :--- |
| TC-WID-01 | QuizScreen | Loading state appears before questions resolve | CircularProgressIndicator is found |
| TC-WID-02 | QuizScreen | Dummy question and options render after loading | Question text and all 4 options are found |
| TC-WID-03 | QuizScreen | Tapping correct option updates local state | "CORRECT! +20 XP" and "FINISH QUEST" are found |
| TC-WID-04 | QuizScreen | Tapping wrong option shows incorrect feedback | "INCORRECT" and "FINISH QUEST" are found |
| TC-WID-05 | QuizScreen | Empty data state handling | "No quests available." is found |
| TC-WID-06 | QuizScreen | Fetch failure fallback handling | "No quests available." is found |

## Notes
- Some interaction tests set a larger test viewport to ensure tappable widgets are within bounds.
- The suite is intentionally focused on UI state rendering and basic local interaction.
