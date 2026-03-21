# Cosmic Quest - Full Application Documentation

## 1. Document Purpose
This document provides an end-to-end technical and product overview of the Cosmic Quest Flutter application. It is intended for assessors, developers, testers, and maintainers.

It covers:
- Product overview and goals
- Architecture and module structure
- Setup and environment configuration
- Features and user flows
- API and backend integration
- Data persistence and offline behavior
- Error handling strategy
- Testing strategy and current coverage
- UX and design decisions
- Security and privacy considerations
- Known limitations and roadmap

---

## 2. Application Overview
Cosmic Quest is a space-themed mobile application built with Flutter. The app combines NASA public data feeds with gamified quiz interactions and user profile progression.

Primary value delivered:
- Space content discovery (APOD, Earth gallery, asteroid feed)
- Interactive quiz gameplay with score progression
- User authentication and cloud-backed profile/score persistence
- Personalization via persistent theme mode

Target platforms:
- Android
- iOS
- Desktop/web structure exists in project, mobile is the primary target

---

## 3. Technology Stack
### 3.1 Frontend
- Flutter
- Dart
- Material and Cupertino components
- Google Fonts

### 3.2 Backend and Services
- Firebase Authentication
- Cloud Firestore
- NASA public APIs

### 3.3 Local Storage
- SharedPreferences

### 3.4 Supporting Libraries
- flutter_dotenv for runtime config
- flutter_tts for quiz voice support

---

## 4. High-Level Architecture
The application uses a layered structure:

- Presentation layer: Screens and UI widgets
- Domain/data access layer: Repositories
- Model layer: Data models for API and Firestore transformation
- Service layer: Theme service and utility behavior

### 4.1 Core Entry Flow
1. App initializes Flutter bindings.
2. Environment variables are loaded from .env.
3. Firebase is initialized.
4. Theme preference is loaded from SharedPreferences.
5. AuthGate decides whether to show sign-in flow or main app hub.

### 4.2 Main Navigation Architecture
- Root navigation: AuthGate
- Authenticated shell: MainHubScreen with IndexedStack tabs
- Tabs:
  - Home
  - Explore
  - Leaderboard
  - Profile

IndexedStack is used to preserve per-tab state while switching views.

---

## 5. Project Structure
Top-level app code is organized as follows:

- lib/main.dart: App bootstrap, theme state, Firebase and dotenv initialization
- lib/views: All primary screens and user-facing flows
- lib/data/models: Data model definitions
- lib/data/repositories: Network and backend repository logic
- lib/services: App-level support services (theme persistence)
- lib/theme: Light/dark theme configuration
- test: Unit and widget test suites
- documentation: Engineering and QA documentation artifacts

---

## 6. Environment and Configuration
### 6.1 Required Environment Variables
The app expects an .env file with at least:
- NASA_API_KEY

If NASA_API_KEY is absent in some repository paths, DEMO_KEY fallback is used where coded.

### 6.2 Firebase Configuration
Firebase options are loaded using generated firebase_options.dart and initialized at startup.

Required Firebase products:
- Authentication
- Cloud Firestore

### 6.3 Local Setup Steps
1. Install Flutter SDK and platform tooling.
2. Install dependencies:
   flutter pub get
3. Add .env with NASA API key.
4. Ensure Firebase config files are present (android and ios setup).
5. Run:
   flutter run

---

## 7. Feature Documentation (End to End)

## 7.1 Authentication and Access Control
Implemented in AuthGate.

Behavior:
- Listens to Firebase auth state stream.
- If user exists: navigates to MainHubScreen.
- If user does not exist: shows Firebase UI sign-in screen with EmailAuthProvider.

User-facing outcomes:
- Seamless login and registration
- No manual route management needed for auth transitions

---

## 7.2 Home Screen
Primary responsibilities:
- Show greeting and quick launch actions
- Fetch and render NASA APOD content
- Show current user XP from backend

Key behavior:
- APOD data loaded through NasaRepository
- XP loaded through UserRepository
- Graceful loading and error UI states
- APOD explanation preview is truncated for clean card layout

Local persistence linkage:
- APOD cache fallback through SharedPreferences in repository

---

## 7.3 Explore Screen
Explore contains two tabs:

### A. Asteroids tab
- Fetches near-earth object feed from NASA NEO endpoint
- Renders list entries with hazard indicators
- On tap, opens a modal bottom sheet with extended details:
  - Name
  - Hazard status
  - Estimated diameter
  - Relative velocity
  - Miss distance
  - Close approach date
  - Absolute magnitude
  - NASA JPL reference URL

### B. Gallery tab
- Fetches Earth images from NASA image library endpoint
- Displays media in paged view
- Shows title/date/description preview in overlay
- On tap, opens modal with full description and larger visual context

Error and empty handling:
- Loading spinner while fetching
- Friendly empty state for no records
- Friendly error state for network/server failures

---

## 7.4 Quiz Screen
Primary responsibilities:
- Load quiz questions from Firestore
- Resolve related live NASA content hints per question
- Manage answer selection, scoring, and progression
- Persist earned score to user profile

Flow summary:
1. Initialize TTS and fetch questions.
2. If no questions: show empty-state guidance.
3. Load per-question NASA-based visual/hint content.
4. User selects answer.
5. UI reflects correct or incorrect state.
6. Progress until final question.
7. Persist session XP to backend and show mission summary.

Additional interaction:
- Text-to-speech can read question and options.

Testability note:
- Constructor dependency injection is enabled for repository, user repository, and TTS, supporting isolated widget tests.

---

## 7.5 Leaderboard Screen
Primary responsibilities:
- Load top users by score from Firestore
- Render podium-style top ranks and extended list
- Show current user summary in fixed footer panel

Behavior:
- Fetch leaderboard and user score asynchronously
- Compute and display user rank when present
- Fall back to safe labels for missing profile data

---

## 7.6 Profile and Settings
Profile view:
- Displays user avatar, identity fields, and current points
- Includes navigation to settings

Settings view:
- Update display name in Firebase Auth and Firestore
- Toggle dark mode preference
- Sign out flow
- Delete account flow (with confirmation)

Personalization:
- Theme preference persisted to SharedPreferences
- App-level ThemeMode updated through callback to root app state

---

## 8. Backend and Data Design

## 8.1 Firestore Collections
### users collection
Typical fields:
- name
- email
- score
- last_active

### questions collection
Expected fields:
- question
- options (array of strings)
- answer
- type (apod or mars)
- apiRef
- roverName (optional)

---

## 8.2 Repository Responsibilities
### NasaRepository
- fetchApod
- fetchAsteroids
- fetchEarthGallery
- APOD cache read/write for offline fallback

### QuizRepository
- fetchQuestions from Firestore
- fetchLiveContent from NASA APIs
- Hint/image fallback on API failures

### UserRepository
- getUserScore
- updateUserScore (transaction-safe)
- getLeaderboard

---

## 9. Network API Integration
External API usage includes:
- NASA APOD endpoint
- NASA NEO feed endpoint
- NASA image library endpoint

General strategy:
- Async request/response handling
- Defensive parsing
- Friendly fallback states and placeholders in UI

---

## 10. Local Storage and Persistence
Current local persistence:
- Theme mode boolean in SharedPreferences
- APOD JSON cache in SharedPreferences

Benefits:
- Theme preference survives app restarts
- APOD can render from cache during no-network scenarios

---

## 11. Offline and Error Handling Strategy
Implemented patterns:
- Loading indicators for long-running operations
- Error-state containers with explicit messaging
- Safe parsing and default field values
- APOD offline fallback via cached data
- Fallback placeholders for image failures
- Graceful backend error handling in repositories

Current scope note:
- APOD has explicit cached offline fallback.
- Asteroids and gallery currently rely on runtime fetch and UI fallback states.

---

## 12. Theming and UX System
The app ships with dedicated light and dark theme definitions.

Design components include:
- Space-themed palette and accent colors
- Orbitron for headings and Inter for body text
- High-contrast accents and structured card layouts
- Platform-appropriate navigation (Material and Cupertino variants)

UX strengths:
- Clear visual hierarchy
- Strong feedback for loading, error, and completion states
- Readability improvements via modal detail views for dense content

---

## 13. Testing Documentation
Current tests include unit and widget coverage.

### 13.1 Unit tests
- ThemeService behavior
- ApodModel mapping and serialization

### 13.2 Widget tests
- QuizScreen loading state
- Data render state
- Correct and incorrect answer interactions
- Empty and failure fallback states

Test execution example:
flutter test test/unit/theme_service_test.dart test/unit/apod_model_test.dart test/views/quiz_screen_test.dart test/widget_test.dart

Observed recent status:
- Targeted unit and widget suite passing

---

## 14. Build and Run Instructions
### Development run
flutter run

### Run tests
flutter test

### Analyze
flutter analyze

### Build Android debug
flutter build apk --debug

---

## 15. Version Control and Workflow
Recommended repository workflow:
- Use feature branches for major changes
- Commit in small, meaningful increments
- Keep test and docs updates in same change where possible

Current project already includes branch-based working pattern and can be extended with PR review workflow for stronger traceability.

---

## 16. Security and Privacy Considerations
Current considerations:
- Authentication handled through Firebase Auth
- Sensitive API key placed in .env (not hardcoded in UI)
- Account deletion and sign-out flows available

Recommended improvements:
- Use stronger production rules in Firestore security policies
- Add input constraints for profile update fields
- Consider key rotation and environment separation by build flavor

---

## 17. Known Limitations
- README remains template-level and can be aligned with production documentation
- Offline caching is strongest for APOD; other feeds can be extended similarly
- In-app help/onboarding content can be expanded
- Some advanced sorting/filtering controls are not yet exposed in Explore and Leaderboard

---

## 18. Future Roadmap
Priority enhancements:
1. Add cache fallback for asteroid and gallery feeds
2. Add retry actions for all error states
3. Add integration tests for end-to-end auth to gameplay flow
4. Add in-app help/tutorial overlay
5. Add deep-link support for content sharing
6. Improve analytics and telemetry for engagement and reliability insights

---

## 19. Acceptance Checklist
- Multiple views implemented and integrated
- Navigation architecture complete
- Firebase backend integrated
- NASA API integration complete
- Local persistence implemented
- Personalization implemented
- Unit and widget tests included
- Documentation suite available

---

## 20. Screenshot and Evidence Placeholders
Use this section to attach submission evidence.

- [PLACEHOLDER] Login flow screen
- [PLACEHOLDER] Main tab navigation with all sections
- [PLACEHOLDER] Home APOD success state
- [PLACEHOLDER] Home APOD offline/cache fallback
- [PLACEHOLDER] Explore asteroid list
- [PLACEHOLDER] Asteroid detail modal
- [PLACEHOLDER] Explore gallery card and full-detail modal
- [PLACEHOLDER] Quiz question interaction states
- [PLACEHOLDER] Quiz mission completion dialog
- [PLACEHOLDER] Leaderboard podium and list
- [PLACEHOLDER] Profile and settings with theme toggle
- [PLACEHOLDER] Unit test pass output
- [PLACEHOLDER] Widget test pass output

---

## 21. Quick Reference to Supporting Documentation
- documentation/QUIZ_WIDGET_TESTING_PROCESS.md
- documentation/DEVELOPMENT_LOG_JAN_MAR_2026.md
- documentation/DARK_MODE_IMPLEMENTATION.md

End of document.
