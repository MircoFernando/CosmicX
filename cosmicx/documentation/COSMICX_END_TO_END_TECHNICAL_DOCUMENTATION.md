# CosmicX End-to-End Technical Documentation

## 1. Purpose of this document

This document explains the CosmicX application from end to end for a developer who has general programming knowledge but is new to Flutter.

It covers:
- How the app starts and initializes
- How navigation works between screens
- How data moves through the app
- How Firebase Auth and Firestore are used
- How NASA APIs are integrated
- How dark mode is implemented and persisted
- How to reason about the current architecture and extend it safely

---

## 2. High-level app summary

CosmicX is a Flutter mobile app with a space-learning theme. Users can:
- Sign in with email/password (Firebase Auth)
- View NASA astronomy content (APOD, Near Earth Objects, image gallery)
- Complete quiz missions backed by Firestore + NASA API content
- Earn XP and track leaderboard rank
- Edit profile settings and toggle dark mode

The app uses a relatively simple layered design:
- View layer: Flutter screens/widgets under `lib/views`
- Data layer: Models and repositories under `lib/data`
- Service layer: Shared utility services under `lib/services`
- Theme layer: App-wide light/dark themes under `lib/theme`

---

## 3. Tech stack and dependencies

Main dependencies from `pubspec.yaml`:
- `flutter` and `material` UI framework
- `firebase_core` for Firebase initialization
- `firebase_auth` for authentication
- `firebase_ui_auth` for ready-made auth screens
- `cloud_firestore` for user and quiz data
- `http` for NASA API calls
- `shared_preferences` for local persistence (theme + APOD cache)
- `flutter_dotenv` for loading `.env` (NASA API key)
- `flutter_tts` for text-to-speech in quiz
- `google_fonts` for Orbitron and Inter typography

---

## 4. Project structure overview

Core folders:
- `lib/main.dart`: App entry point, Firebase init, theme mode bootstrapping
- `lib/firebase_options.dart`: Generated Firebase options per platform
- `lib/views/*`: Screens and navigation
- `lib/data/models/*`: Data model classes
- `lib/data/repositories/*`: Data access logic (Firebase + NASA APIs)
- `lib/services/theme_service.dart`: Theme persistence using SharedPreferences
- `lib/theme/app_theme.dart`: Light and dark theme definitions

---

## 5. Startup and app lifecycle

### 5.1 Entry point (`main.dart`)

Startup flow:
1. `WidgetsFlutterBinding.ensureInitialized()` prepares Flutter engine bindings.
2. `.env` is loaded using `dotenv.load(fileName: ".env")`.
3. Firebase is initialized with `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
4. App launches with `runApp(const CosmicQuestApp())`.

`CosmicQuestApp` is `StatefulWidget` because theme mode is mutable at runtime.

### 5.2 Theme bootstrapping

Inside `_CosmicQuestAppState`:
- `_loadThemePreference()` calls `ThemeService.isDarkMode()`.
- While reading local preference, a temporary loading scaffold is displayed.
- Once loaded, app builds `MaterialApp` with:
  - `theme: AppTheme.lightTheme`
  - `darkTheme: AppTheme.darkTheme`
  - `themeMode: _themeMode`

`updateTheme(bool isDark)` is passed down to screens that can toggle appearance.

### 5.3 First user-visible screen

`MaterialApp.home` is `LoadingScreen(onThemeChange: updateTheme)`.

`LoadingScreen` waits 10 seconds using a `Timer`, then calls:
- `Navigator.pushReplacement(...)` to move to `AuthGate`

This means loading screen is removed from the back stack.

---

## 6. Authentication flow

### 6.1 Auth gate (`views/auth_gate.dart`)

`AuthGate` uses `StreamBuilder<User?>` on:
- `FirebaseAuth.instance.authStateChanges()`

Behavior:
- If stream has user data: render `MainHubScreen`
- If no user: render `SignInScreen` from `firebase_ui_auth`

`SignInScreen` currently enables:
- `EmailAuthProvider()` only

Custom header/subtitle/footer builders style the prebuilt auth UI.

### 6.2 Sign out behavior

From settings screen, `FirebaseAuth.instance.signOut()` is called.
Because `AuthGate` listens to auth state stream, UI automatically returns to sign-in view.
No manual root navigation reset is required.

### 6.3 Delete account behavior

Settings screen action:
1. Deletes Firestore user document (`users/{uid}`)
2. Calls `user.delete()` for Firebase Auth account

If re-authentication is required by Firebase, deletion can fail and is shown in SnackBar.

---

## 7. Navigation architecture

Navigation uses classic Flutter imperative API (`Navigator`) and bottom-tab state.

### 7.1 Primary app shell

`MainHubScreen` hosts the main 4-tab experience.
- Tab index state stored in `_selectedIndex`
- Content rendered with `IndexedStack`

Tabs:
1. Home (`HomeScreen`)
2. Explore (`ExploreScreen`)
3. Leaderboard (`LeaderboardScreen`)
4. Profile (`ProfileScreen`)

`IndexedStack` keeps inactive tab states alive (no rebuild reset when switching tabs).

### 7.2 Bottom nav by platform

`MainHubScreen` chooses nav style based on `Platform`:
- iOS: `CupertinoTabBar`
- Android/other: `BottomNavigationBar`

### 7.3 Secondary navigation (push flows)

Inside tabs, flows use `Navigator.push`:
- Home -> QuizScreen
- Home -> ExploreScreen (standalone push)
- Profile -> ProfileSettingsScreen

Modal interactions:
- Explore detail sheets use `showModalBottomSheet`
- Quiz final summary uses `showDialog`
- Settings confirmation actions use `showDialog`

---

## 8. Screen-by-screen behavior

## 8.1 Loading screen (`loading_screen.dart`)

Responsibilities:
- Show branded splash-like loading UI
- Delay for simulated startup checks
- Transition to auth gate with push replacement

Data interactions: none.

## 8.2 Main hub (`main_hub_screen.dart`)

Responsibilities:
- Keep global tab navigation state
- Render tab stack
- Propagate `onThemeChange` callback to profile branch

Data interactions: none directly.

## 8.3 Home (`home_screen.dart`)

Responsibilities:
- Fetch and display APOD (Astronomy Picture of the Day)
- Display current user XP in app bar
- Entry points to quiz and explore

Data dependencies:
- `NasaRepository.fetchApod()` for APOD
- `UserRepository.getUserScore()` for XP

Notable behavior:
- Uses `FutureBuilder<ApodModel>` for APOD
- APOD network failure shows graceful connection card
- After quiz returns, `_loadXp()` is called to refresh XP

## 8.4 Explore (`explore_screen.dart`)

Responsibilities:
- Two-tab exploration section:
  - Asteroids (NASA Neo feed)
  - Earth Gallery (NASA image library)

Data dependencies:
- `NasaRepository.fetchAsteroids()`
- `NasaRepository.fetchEarthGallery()`

UI behavior:
- Uses `TabController` + `TabBarView`
- Asteroid cards show hazard and metrics
- Tapping item opens modal details
- Gallery uses `PageView` with overlay metadata

## 8.5 Quiz (`quiz_screen.dart`)

Responsibilities:
- Load quiz questions from Firestore
- Fetch per-question live NASA content
- Allow answer selection and scoring
- Persist earned XP to Firestore
- Optional text-to-speech reading

Data dependencies:
- `QuizRepository.fetchQuestions()`
- `QuizRepository.fetchLiveContent(...)`
- `UserRepository.updateUserScore(sessionPoints)`

Flow details:
1. Initialize repository + user repo + TTS engine
2. Load all questions from Firestore collection `questions`
3. For current question, fetch dynamic content based on question type
4. On answer, lock state and grant +20 XP if correct
5. On finish, update cumulative score in Firestore transaction
6. Show final mission summary dialog and return

## 8.6 Leaderboard (`leadership_screen.dart`)

Responsibilities:
- Display top users by score
- Highlight current user rank and score

Data dependencies:
- `UserRepository.getLeaderboard()` for top 10
- `UserRepository.getUserScore()` for current user

Behavior:
- Top 3 rendered as podium cards
- Remaining entries listed below
- Footer always shows current user rank and XP

## 8.7 Profile (`profile_screen.dart`)

Responsibilities:
- Display user identity and total XP
- Link to settings

Data dependencies:
- Firebase Auth current user fields
- `UserRepository.getUserScore()`

## 8.8 Profile settings (`profile_settings_screen.dart`)

Responsibilities:
- Edit display name
- Toggle dark mode
- Show account metadata
- Sign out or delete account

Data dependencies:
- Firebase Auth (`updateDisplayName`, `signOut`, `delete`)
- Firestore `users/{uid}` merge updates for `name`
- `ThemeService` for dark mode persistence

---

## 9. Data layer and model design

## 9.1 Models

### `ApodModel`
Fields:
- `title`, `url`, `explanation`, `date`

Functions:
- `ApodModel.fromJson(...)` with safe defaults
- `toJson()` for local cache serialization

### `QuizQuestion`
Fields:
- `id`, `question`, `options`, `answer`, `type`, `apiRef`, `roverName?`

`type` uses enum:
- `ApiType.apod`
- `ApiType.mars`

Constructor helper:
- `QuizQuestion.fromFirestore(Map data, String id)`

## 9.2 Repository responsibilities

### `NasaRepository`
- `fetchApod()`
  - API: `https://api.nasa.gov/planetary/apod`
  - Caches successful payload in SharedPreferences (`cached_apod`)
  - Falls back to cache on network failure
- `fetchAsteroids()`
  - API: Neo feed for current day
- `fetchEarthGallery()`
  - API: NASA image library search (`earth`, image media)

### `QuizRepository`
- `fetchQuestions()` from Firestore `questions`
- `fetchLiveContent(question)` chooses source by `question.type`
  - APOD branch via date + APOD endpoint
  - Library branch via NASA image search by `nasa_id`
- Returns `ApiContent(imageUrl, hint)` for rendering in quiz UI
- On failure, returns placeholder content and fallback hint

### `UserRepository`
- `getUserScore()` reads `users/{uid}.score`
- `updateUserScore(sessionPoints)` uses Firestore transaction:
  - creates user doc if missing
  - otherwise increments score and updates `last_active`
- `getLeaderboard()` queries top 10 users by score descending

---

## 10. End-to-end data flow examples

## 10.1 APOD card on Home

Flow:
1. Home screen initializes `_apodFuture = _nasaRepository.fetchApod()`
2. Repository requests APOD endpoint using `NASA_API_KEY`
3. If success:
  - parse JSON to `ApodModel`
  - cache serialized APOD locally
  - return model to UI
4. If failure:
  - if cache exists, return cached APOD
  - otherwise throw exception
5. `FutureBuilder` updates card UI or error UI

## 10.2 Quiz question with live image

Flow:
1. `QuizRepository.fetchQuestions()` loads static question docs from Firestore
2. Current question chosen by index
3. `fetchLiveContent(question)` calls NASA API based on question type
4. UI displays image and hint from returned `ApiContent`
5. User answers, local session score is updated
6. At end, `UserRepository.updateUserScore(sessionScore)` persists total XP

## 10.3 Leaderboard

Flow:
1. Screen loads top 10 scores from Firestore
2. Also loads current user score separately
3. Client computes user rank by scanning top 10 list
4. UI renders podium + list + footer rank widget

---

## 11. Firebase integration details

## 11.1 Initialization

Firebase is initialized once in `main.dart` using generated options from `firebase_options.dart`.

Current generated options include Android and iOS. Other platforms in `firebase_options.dart` throw `UnsupportedError` unless configured.

## 11.2 Firebase Auth usage

Used in:
- `AuthGate` for auth state stream
- Settings for sign-out/delete account
- Profile views for `currentUser` metadata

Current provider enabled in app UI:
- Email/password via Firebase UI Auth

## 11.3 Cloud Firestore usage

Collections used:
- `questions` for quiz definitions
- `users` for profile/score data

Expected shape for `questions` documents:
- `question`: string
- `options`: array of strings
- `answer`: string
- `type`: `apod` or `mars`
- `apiRef`: date (for APOD) or NASA ID (for library search)
- `roverName`: optional

Expected shape for `users/{uid}`:
- `score`: integer
- `email`: string
- `name`: string (optional)
- `last_active`: server timestamp

---

## 12. Dark mode implementation

Dark mode is implemented with coordinated local persistence + app-level state update.

Components:
- `AppTheme` defines `lightTheme` and `darkTheme`
- `ThemeService` stores and retrieves `isDarkMode` in SharedPreferences
- `CosmicQuestApp` holds current `ThemeMode` state
- `ProfileSettingsScreen` toggle updates preference and triggers callback

Exact flow when user toggles theme:
1. Settings switch calls `_toggleDarkMode(value)`
2. State updates local `_isDarkMode` immediately for switch UI
3. `ThemeService.setDarkMode(value)` persists bool locally
4. `widget.onThemeChange?.call(value)` notifies root app widget
5. `CosmicQuestApp.updateTheme` updates `themeMode`
6. `MaterialApp` rebuilds using light/dark theme globally

This means theme preference survives app restart and updates live without relaunch.

---

## 13. State management approach

Current app uses StatefulWidget-based local state and asynchronous builders.

Patterns used:
- `StatefulWidget` for mutable view state
- `setState` for local updates
- `FutureBuilder` for one-shot async fetches
- `StreamBuilder` for auth state stream

No global state library (Provider, Riverpod, Bloc) is used currently.

This keeps architecture simple but requires manual callback passing for cross-screen actions such as theme updates.

---

## 14. Error handling and resilience

Implemented resilience features:
- APOD offline fallback from local SharedPreferences cache
- Repository try/catch wrappers for API and Firestore calls
- UI loading, error, and empty states in major screens
- Mounted checks before post-await UI updates in many async methods

User-facing failures are surfaced via:
- Error cards/text in screens
- SnackBars in settings operations
- Placeholder image/hint fallback in quiz live content

---

## 15. Platform-specific behavior

- Navigation bar adapts by platform in `MainHubScreen`:
  - iOS: CupertinoTabBar
  - Android/others: Material BottomNavigationBar
- App currently has Firebase options configured for Android and iOS only in generated options file

---

## 16. Environment and runtime configuration

Required local setup:
- `.env` file with `NASA_API_KEY=<your_key>`
- Firebase project configured for target platforms
- Firestore collections (`questions`, `users`) populated and rules configured

If `.env` key is missing, repositories fall back to `DEMO_KEY`, which can be rate-limited.

---

## 17. Practical architecture map

Runtime sequence (simplified):

1. App boot:
- Main initializes dotenv + Firebase
- Theme preference loaded
- LoadingScreen shown

2. Authentication:
- AuthGate listens to Firebase auth stream
- SignInScreen shown if signed out
- MainHubScreen shown if signed in

3. Main app usage:
- User switches tabs in IndexedStack
- Each screen performs its own async data fetches through repositories

4. Data persistence:
- Theme bool in SharedPreferences
- APOD cache in SharedPreferences
- Quiz definitions + scores in Firestore

5. Session completion:
- Quiz updates cumulative XP transactionally in Firestore
- Home/Profile/Leaderboard reflect updated values on next load/refresh

---

## 18. How to extend safely

Recommended extension points:
- Add new NASA content cards in `NasaRepository` and corresponding views
- Add quiz categories by extending `ApiType` and `QuizRepository.fetchLiveContent`
- Add richer profile metrics in `users` documents and profile UI
- Introduce central state management if cross-screen state grows

Good next technical improvements:
- Move constants/endpoints to dedicated config files
- Add typed DTOs for asteroid/gallery payloads (currently map-based)
- Add robust retry/backoff for network calls
- Add unit and widget tests for repositories/screens
- Consider reducing loading delay in `LoadingScreen` for production UX

---

## 19. Quick glossary for non-Flutter developers

- Widget: Flutter UI building block (similar to composable view component)
- StatefulWidget: Widget with mutable state and lifecycle hooks
- Build method: Renders UI from current state
- Navigator: Stack-based screen transition system
- FutureBuilder: UI helper that reacts to async Future completion
- StreamBuilder: UI helper that reacts to stream updates over time
- ThemeData: Application-wide visual design tokens and component defaults

---

## 20. File map reference

Core app wiring:
- `lib/main.dart`
- `lib/firebase_options.dart`

Theme system:
- `lib/theme/app_theme.dart`
- `lib/services/theme_service.dart`

Data layer:
- `lib/data/models/apod_model.dart`
- `lib/data/models/quiz_question.dart`
- `lib/data/repositories/nasa_repository.dart`
- `lib/data/repositories/quiz_repository.dart`
- `lib/data/repositories/user_repository.dart`

View layer:
- `lib/views/loading_screen.dart`
- `lib/views/auth_gate.dart`
- `lib/views/main_hub_screen.dart`
- `lib/views/home_screen.dart`
- `lib/views/explore_screen.dart`
- `lib/views/quiz_screen.dart`
- `lib/views/leadership_screen.dart`
- `lib/views/profile_screen.dart`
- `lib/views/profile_settings_screen.dart`

---

## 21. Final summary

CosmicX is a Firebase-authenticated Flutter learning app with a tabbed architecture, repository-based data access, NASA API integrations, Firestore-driven quiz/score systems, and persistent dark mode.

The current codebase is straightforward to follow for newcomers because:
- Startup and routing are centralized
- Data responsibilities are separated into repositories
- UI state is mostly local and explicit
- Critical user features (auth, score persistence, theme persistence) are already integrated end to end
