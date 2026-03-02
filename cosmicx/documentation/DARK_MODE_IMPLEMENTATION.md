# Dark Mode Implementation Guide

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture & Design](#architecture--design)
3. [Component Breakdown](#component-breakdown)
4. [Data Flow & State Management](#data-flow--state-management)
5. [Theme Service](#theme-service)
6. [Main App Configuration](#main-app-configuration)
7. [Theme System](#theme-system)
8. [User Interface Implementation](#user-interface-implementation)
9. [How to Use](#how-to-use)
10. [Best Practices](#best-practices)
11. [Troubleshooting](#troubleshooting)

---

## Overview

The CosmicX application implements a **dynamic, persistent dark mode system** that allows users to seamlessly switch between light and dark themes. The implementation uses:

- **SharedPreferences** for persistent storage of user preference
- **Callback-based state management** to propagate theme changes through the widget tree
- **Dual theme definitions** (Light & Dark) with consistent styling using Google Fonts
- **Real-time UI updates** without app restart

### Key Features

✅ **Instant switching** - No app restart needed  
✅ **Persistent preference** - Setting saved across sessions  
✅ **Consistent theming** - All screens automatically adapt  
✅ **Modern UI** - Clean toggle switch in settings  
✅ **Accessible** - Proper icons and labels for all theme states  

---

## Architecture & Design

### System Diagram

```
┌─────────────────────────────────────────────────────────┐
│                  CosmicQuestApp (Main)                  │
│  - Manages theme state                                  │
│  - Loads theme preference on startup                    │
│  - Provides theme change callback                       │
└──────────────────────┬──────────────────────────────────┘
                       │ MaterialApp with theme
                       │ and onThemeChange callback
                       ▼
┌─────────────────────────────────────────────────────────┐
│                    AuthGate                             │
│  - Checks user authentication state                     │
│  - Routes to MainHubScreen if logged in                 │
│  - Passes onThemeChange callback down                   │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│                  MainHubScreen                          │
│  - Bottom navigation container                          │
│  - Contains all main app screens                        │
│  - Passes onThemeChange to ProfileScreen               │
└──────────────────────┬──────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
    Profile      Explore        Leadership
    │
    └──> ProfileScreen
         │
         └──> ProfileSettingsScreen
              │
              ├─ ThemeService (Persistent Storage)
              └─ onThemeChange Callback (State Update)
```

### Component Hierarchy

```
theme_service.dart
├─ isDarkMode()         - Check current theme
├─ setDarkMode(bool)    - Save theme preference
└─ getThemeMode(bool)   - Convert bool to ThemeMode

app_theme.dart
├─ darkTheme            - Complete dark theme definition
└─ lightTheme           - Complete light theme definition

main.dart
├─ CosmicQuestApp (StatefulWidget)
│  ├─ _themeMode        - Current active theme
│  ├─ _initialized      - Load completion flag
│  ├─ _loadThemePreference()  - Initial load
│  └─ updateTheme(bool)       - Update callback
└─ MaterialApp
   ├─ theme: lightTheme
   ├─ darkTheme: darkTheme
   ├─ themeMode: _themeMode
   └─ home: AuthGate(onThemeChange: updateTheme)

auth_gate.dart
├─ onThemeChange callback
└─ MainHubScreen(onThemeChange)

main_hub_screen.dart
├─ onThemeChange callback
└─ ProfileScreen(onThemeChange)

profile_screen.dart
├─ onThemeChange callback
└─ ProfileSettingsScreen(onThemeChange)

profile_settings_screen.dart
├─ onThemeChange callback
├─ _isDarkMode state
├─ _loadThemePreference()
├─ _toggleDarkMode(bool)
│  ├─ Update local state
│  ├─ Save to SharedPreferences
│  └─ Trigger onThemeChange callback
└─ Dark Mode Toggle UI
   ├─ Switch widget
   ├─ Sun/Moon icon
   └─ Status label
```

---

## Component Breakdown

### 1. **ThemeService** (`lib/services/theme_service.dart`)

The `ThemeService` class handles all theme preference operations using SharedPreferences.

```dart
class ThemeService {
  static const String _themeKey = 'isDarkMode';

  // Retrieve stored theme preference
  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false; // Default: Light mode
  }

  // Save theme preference to device storage
  static Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  // Convert boolean to ThemeMode enum
  static ThemeMode getThemeMode(bool isDark) {
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }
}
```

**Key Details:**
- `_themeKey` constant ensures consistency across app
- `isDarkMode()` returns `false` by default (light mode default)
- `setDarkMode()` uses async SharedPreferences to persist to device
- `getThemeMode()` helper converts boolean to Flutter's ThemeMode enum

### 2. **AppTheme** (`lib/theme/app_theme.dart`)

Defines complete theme styling for both light and dark modes using Material 3 design.

#### Dark Theme Configuration

```dart
static ThemeData get darkTheme {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: spaceBlack,      // #0B0D17
    primaryColor: neonBlue,                   // #00D4FF
    
    // Text styling with Google Fonts
    textTheme: TextTheme(
      displayLarge: GoogleFonts.orbitron(     // Headers
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: starlightWhite,
      ),
      headlineSmall: GoogleFonts.orbitron(    // Subheaders
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: neonBlue,
      ),
      bodyLarge: GoogleFonts.inter(           // Body text
        fontSize: 16,
        color: starlightWhite,
      ),
    ),
    
    // Form input styling
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: voidGrey,                    // #1F2937
      labelStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: neonBlue),
      ),
    ),
    
    // Button styling
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: neonBlue,
        foregroundColor: spaceBlack,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.orbitron(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    
    // Bottom navigation styling
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: spaceBlack,
      selectedItemColor: neonBlue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
```

**Color Palette (Dark Mode):**
- **spaceBlack** (`#0B0D17`) - Deep background, NASA-inspired
- **neonBlue** (`#00D4FF`) - Primary accent, futuristic
- **starlightWhite** (`#F9FAFB`) - Main text color
- **voidGrey** (`#1F2937`) - Card backgrounds
- **marsRed** (`#FF5E5B`) - Error states

#### Light Theme Configuration

```dart
static ThemeData get lightTheme {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: skyWhite,        // #FFFFFF
    primaryColor: deepNavy,                   // #0B3D91
    
    textTheme: TextTheme(
      displayLarge: GoogleFonts.orbitron(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: deepNavy,
      ),
      headlineSmall: GoogleFonts.orbitron(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: deepNavy,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: textBlack,                     // #111827
      ),
    ),
    
    // Form input styling for light mode
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFE8E8F0),     // Light grey fill
      labelStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: deepNavy),
      ),
    ),
    
    // Button styling for light mode
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: deepNavy,
        foregroundColor: skyWhite,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.orbitron(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    
    // Bottom navigation for light mode
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: skyWhite,
      selectedItemColor: deepNavy,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
```

**Color Palette (Light Mode):**
- **skyWhite** (`#FFFFFF`) - Clean background
- **deepNavy** (`#0B3D91`) - Professional primary color
- **textBlack** (`#111827`) - Dark text for readability

### 3. **Main Application** (`lib/main.dart`)

The root of the app where theme state is managed.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const CosmicQuestApp());
}

class CosmicQuestApp extends StatefulWidget {
  const CosmicQuestApp({super.key});

  @override
  State<CosmicQuestApp> createState() => _CosmicQuestAppState();
}

class _CosmicQuestAppState extends State<CosmicQuestApp> {
  late ThemeMode _themeMode;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  // Load theme preference from SharedPreferences on app start
  Future<void> _loadThemePreference() async {
    final isDark = await ThemeService.isDarkMode();
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _initialized = true;
    });
  }

  // Update theme when user toggles in settings
  void updateTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while initializing theme
    if (!_initialized) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: AppTheme.spaceBlack,
          body: Center(
            child: CircularProgressIndicator(
              color: AppTheme.neonBlue,
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Cosmic Quest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,  // This controls which theme is active
      home: AuthGate(onThemeChange: updateTheme),
    );
  }
}
```

**Key Points:**
- `StatefulWidget` is required to manage theme state
- `_initialized` flag ensures theme loads before rendering UI
- `_loadThemePreference()` runs in `initState()` to load saved preference
- `updateTheme()` callback is passed down the widget tree
- `themeMode` property controls active theme (light/dark/system)

### 4. **Authentication Gate** (`lib/views/auth_gate.dart`)

Routes users and passes theme callback.

```dart
class AuthGate extends StatelessWidget {
  final Function(bool)? onThemeChange;

  const AuthGate({super.key, this.onThemeChange});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // User logged in - show main app
          return MainHubScreen(onThemeChange: onThemeChange);
        }

        // User not logged in - show login screen
        return SignInScreen(
          providers: [EmailAuthProvider()],
          headerBuilder: (context, constraints, shrinkOffset) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: AspectRatio(
                aspectRatio: 1,
                child: Icon(
                  Icons.rocket_launch_rounded,
                  size: 100,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            );
          },
          subtitleBuilder: (context, action) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: action == AuthAction.signIn
                  ? Text(
                      'Welcome back, Commander. Please sign in.',
                      style: GoogleFonts.inter(),
                    )
                  : Text(
                      'New recruit? Register below.',
                      style: GoogleFonts.inter(),
                    ),
            );
          },
          footerBuilder: (context, action) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'By signing in, you agree to our interstellar terms.',
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            );
          },
        );
      },
    );
  }
}
```

### 5. **Main Hub Screen** (`lib/views/main_hub_screen.dart`)

Container for all main app screens.

```dart
class MainHubScreen extends StatefulWidget {
  final Function(bool)? onThemeChange;

  const MainHubScreen({super.key, this.onThemeChange});

  @override
  State<MainHubScreen> createState() => _MainHubScreenState();
}

class _MainHubScreenState extends State<MainHubScreen> {
  int _selectedIndex = 0;

  List<Widget> get _screens => [
    const HomeScreen(),
    const ExploreScreen(),
    const LeaderboardScreen(),
    ProfileScreen(onThemeChange: widget.onThemeChange),  // Pass callback
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        // Theme automatically applied from AppTheme
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          // ... other items
        ],
      ),
    );
  }
}
```

### 6. **Profile Screen** (`lib/views/profile_screen.dart`)

Displays user profile and provides access to settings.

```dart
class ProfileScreen extends StatefulWidget {
  final Function(bool)? onThemeChange;

  const ProfileScreen({super.key, this.onThemeChange});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ...

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);  // Get current theme

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PROFILE',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withOpacity(0.3),
                  theme.primaryColor.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.settings_rounded, color: theme.primaryColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileSettingsScreen(
                      onThemeChange: widget.onThemeChange,  // Pass callback
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // ... rest of UI
    );
  }
}
```

### 7. **Profile Settings Screen** (`lib/views/profile_settings_screen.dart`)

Where the dark mode toggle lives!

```dart
class ProfileSettingsScreen extends StatefulWidget {
  final Function(bool)? onThemeChange;

  const ProfileSettingsScreen({super.key, this.onThemeChange});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  // Load current theme preference
  Future<void> _loadThemePreference() async {
    final isDark = await ThemeService.isDarkMode();
    setState(() {
      _isDarkMode = isDark;
    });
  }

  // Handle theme toggle
  Future<void> _toggleDarkMode(bool value) async {
    setState(() {
      _isDarkMode = value;
    });
    
    // Save to persistent storage
    await ThemeService.setDarkMode(value);
    
    // Trigger theme change in root widget
    if (widget.onThemeChange != null) {
      widget.onThemeChange!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SETTINGS',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... Other settings sections ...

            // APPEARANCE SECTION
            Text(
              'Appearance',
              style: GoogleFonts.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),

            // DARK MODE TOGGLE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side: Icon + Label
                  Row(
                    children: [
                      Icon(
                        _isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dark Mode',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isDarkMode ? 'Enabled' : 'Disabled',
                            style: GoogleFonts.inter(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Right side: Toggle Switch
                  Switch(
                    value: _isDarkMode,
                    onChanged: _toggleDarkMode,
                    activeColor: theme.primaryColor,
                  ),
                ],
              ),
            ),

            // ... Rest of settings ...
          ],
        ),
      ),
    );
  }
}
```

---

## Data Flow & State Management

### Theme Change Flow Diagram

```
User toggles Dark Mode switch in ProfileSettingsScreen
                    │
                    ▼
         _toggleDarkMode(bool value)
                    │
        ┌───────────┴───────────┐
        │                       │
        ▼                       ▼
  setState()            ThemeService.setDarkMode()
  Update local           │
  _isDarkMode state      ├─ Get SharedPreferences instance
                         ├─ Save isDarkMode boolean
                         ├─ Persist to device storage
                         └─ Return Future
        │                       │
        ├───────┬───────────────┘
        │       │
        ▼       ▼
  onThemeChange!(value)
  Call parent callback
                    │
                    ▼
        updateTheme(bool isDark)
        in _CosmicQuestAppState
                    │
                    ▼
              setState()
              Update _themeMode
                    │
                    ▼
        MaterialApp.build()
        with new themeMode
                    │
                    ▼
         Theme rebuilds entire app
         All widgets auto-adapt
```

### State Management Strategy

**Local State (ProfileSettingsScreen):**
```dart
bool _isDarkMode = false;  // Local UI state
```
- Reflects current theme preference
- Updated immediately on toggle (optimistic update)
- Loaded in `initState()` from persistent storage

**Persistent State (SharedPreferences):**
```dart
await ThemeService.setDarkMode(value);
```
- Survives app restarts
- Retrieved on app startup
- Single source of truth for user preference

**Global State (CosmicQuestApp):**
```dart
late ThemeMode _themeMode;
```
- Controls MaterialApp theme
- Updated via callback from ProfileSettingsScreen
- Triggers widget rebuilds across entire app

---

## Theme Service

### Purpose
The `ThemeService` class abstracts all theme persistence logic using SharedPreferences.

### Key Methods

#### `isDarkMode()` - Check Current Theme
```dart
static Future<bool> isDarkMode() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_themeKey) ?? false;
}
```
- **Returns:** `true` if dark mode enabled, `false` for light mode
- **Default:** `false` (light mode) if no preference stored
- **Usage:** Called on app startup to load preference

#### `setDarkMode(bool isDark)` - Save Theme
```dart
static Future<void> setDarkMode(bool isDark) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_themeKey, isDark);
}
```
- **Parameter:** `isDark` - Target theme (true=dark, false=light)
- **Usage:** Called when user toggles switch
- **Side Effect:** Persists to device storage

#### `getThemeMode(bool isDark)` - Convert to ThemeMode
```dart
static ThemeMode getThemeMode(bool isDark) {
  return isDark ? ThemeMode.dark : ThemeMode.light;
}
```
- **Converts:** Boolean to Flutter's `ThemeMode` enum
- **Usage:** Optional helper (not currently used in v1)

### SharedPreferences Details

**Key:** `'isDarkMode'`  
**Type:** Boolean  
**Storage Location:**
- **Android:** `/data/data/com.example.cosmicx/shared_prefs/`
- **iOS:** `Library/Preferences/` 
- **Web:** localStorage
- **Windows/Linux:** Registry/config files

---

## Main App Configuration

### Theme Loading Flow

```
1. main() async
   │
   ├─ WidgetsFlutterBinding.ensureInitialized()
   ├─ dotenv.load()
   ├─ Firebase.initializeApp()
   └─ runApp(CosmicQuestApp())

2. CosmicQuestApp created (StatefulWidget)
   │
   └─ _CosmicQuestAppState

3. _CosmicQuestAppState.initState()
   │
   └─ _loadThemePreference()
      │
      ├─ await ThemeService.isDarkMode()
      │  └─ Read from SharedPreferences
      │
      └─ setState(() {
           _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
           _initialized = true;
         })

4. _CosmicQuestAppState.build()
   │
   ├─ if (!_initialized)
   │  └─ Show loading screen
   │
   └─ if (_initialized)
      └─ MaterialApp(
           theme: AppTheme.lightTheme,
           darkTheme: AppTheme.darkTheme,
           themeMode: _themeMode,  // Controls active theme
           home: AuthGate(onThemeChange: updateTheme),
         )
```

### MaterialApp Theme Properties

```dart
MaterialApp(
  // Light theme used when themeMode = ThemeMode.light
  theme: AppTheme.lightTheme,
  
  // Dark theme used when themeMode = ThemeMode.dark
  darkTheme: AppTheme.darkTheme,
  
  // Controls which theme is active
  themeMode: _themeMode,  // ThemeMode.light, ThemeMode.dark, or ThemeMode.system
  
  // Home widget receives theme change callback
  home: AuthGate(onThemeChange: updateTheme),
)
```

---

## Theme System

### Theme Properties by Mode

| Property | Dark Mode | Light Mode |
|----------|-----------|-----------|
| **Background** | spaceBlack (#0B0D17) | skyWhite (#FFFFFF) |
| **Primary Color** | neonBlue (#00D4FF) | deepNavy (#0B3D91) |
| **Text Color** | starlightWhite (#F9FAFB) | textBlack (#111827) |
| **Card Color** | voidGrey (#1F2937) | Light Grey (#E8E8F0) |
| **Error Color** | marsRed (#FF5E5B) | marsRed (#FF5E5B) |
| **Font:** Headers | Orbitron Bold | Orbitron Bold |
| **Font:** Body | Inter Regular | Inter Regular |

### Accessing Theme in Widgets

```dart
// In any widget, access current theme
final theme = Theme.of(context);

// Use theme properties
Container(
  decoration: BoxDecoration(
    color: theme.scaffoldBackgroundColor,      // Background color
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'Hello',
    style: TextStyle(
      color: theme.primaryColor,               // Primary accent
      fontSize: 18,
    ),
  ),
)
```

### Automatic Theme Application

All material widgets automatically adapt:
- ✅ AppBar colors
- ✅ Button styles
- ✅ Input field styling
- ✅ Bottom navigation bar
- ✅ Card backgrounds
- ✅ Icon colors
- ✅ Text colors
- ✅ Dividers and borders

---

## User Interface Implementation

### Dark Mode Toggle UI

Located in ProfileSettingsScreen under "Appearance" section.

```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: theme.cardColor,                    // Adapts to theme
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: theme.primaryColor.withOpacity(0.2),
    ),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Left: Icon + Label
      Row(
        children: [
          // Dynamic icon based on current mode
          Icon(
            _isDarkMode
                ? Icons.dark_mode_rounded      // Moon icon
                : Icons.light_mode_rounded,    // Sun icon
            color: theme.primaryColor,
          ),
          const SizedBox(width: 16),
          
          // Text label
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dark Mode',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              
              // Status label
              Text(
                _isDarkMode ? 'Enabled' : 'Disabled',  // Changes with state
                style: GoogleFonts.inter(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      
      // Right: Toggle Switch
      Switch(
        value: _isDarkMode,                    // Current state
        onChanged: _toggleDarkMode,            // Callback on toggle
        activeColor: theme.primaryColor,       // Color when ON
      ),
    ],
  ),
)
```

### UI Feedback

1. **Immediate Visual Feedback**
   - Switch toggles instantly
   - Icon changes (sun ↔️ moon)
   - Status label updates (Enabled ↔️ Disabled)

2. **App-Wide Update**
   - Entire app theme changes without navigation
   - All screens automatically re-render
   - Colors adapt to new theme

3. **Persistence Confirmation**
   - No additional confirmation required
   - Preference automatically saved
   - Setting restored on next app launch

---

## How to Use

### For Users

1. **Open Profile Settings**
   - Tap Profile tab in bottom navigation
   - Tap settings icon (gear) in top right

2. **Toggle Dark Mode**
   - Find "Appearance" section
   - Tap the switch next to "Dark Mode"
   - See sun/moon icon change
   - Watch entire app change theme

3. **Theme Persists**
   - Close and reopen app
   - Your preference is remembered

### For Developers

#### Adding Dark Mode to a New Widget

```dart
class MyCustomWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.scaffoldBackgroundColor,  // Adapts to theme
      child: Text(
        'This will be light/dark!',
        style: TextStyle(
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
    );
  }
}
```

#### Accessing Theme Mode

```dart
// Check if dark mode is active
if (Theme.of(context).brightness == Brightness.dark) {
  // Dark mode is active
}

// Alternative using ThemeData
final isDark = Theme.of(context).brightness == Brightness.dark;
```

#### Custom Theme Colors

Access defined colors in AppTheme:

```dart
import 'package:cosmicx/theme/app_theme.dart';

// Access color constants
Color darkBg = AppTheme.spaceBlack;
Color accent = AppTheme.neonBlue;
Color text = AppTheme.starlightWhite;
```

#### Passing Theme Change Through Widgets

When creating new screens that need theme control:

```dart
class NewScreen extends StatefulWidget {
  final Function(bool)? onThemeChange;  // Add this
  
  const NewScreen({super.key, this.onThemeChange});
  
  // ... rest of widget
}
```

---

## Best Practices

### 1. **Always Use Theme Colors**
```dart
// ✅ GOOD - Adapts to theme
Container(
  color: Theme.of(context).scaffoldBackgroundColor,
)

// ❌ BAD - Hard-coded color
Container(
  color: const Color(0xFF0B0D17),  // Only dark
)
```

### 2. **Use Google Fonts for Typography**
```dart
// ✅ GOOD
Text(
  'Header',
  style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
)

// ❌ BAD
Text(
  'Header',
  style: TextStyle(fontFamily: 'Arial'),
)
```

### 3. **Leverage Theme Brightness**
```dart
// ✅ GOOD - Dynamic selection
Icon(
  Icons.brightness_high,
  color: Theme.of(context).brightness == Brightness.dark
      ? Colors.yellow
      : Colors.orange,
)

// ❌ BAD - Same color in both themes
Icon(
  Icons.brightness_high,
  color: Colors.yellow,
)
```

### 4. **Define Theme-Aware Opacity**
```dart
// ✅ GOOD - Opacity works in both themes
Container(
  color: theme.primaryColor.withOpacity(0.2),  // Adapts
)

// ❌ BAD - May be hard to see in one theme
Container(
  color: const Color(0xFF00D4FF).withOpacity(0.05),
)
```

### 5. **Document Theme Requirements**
```dart
/// Widget that displays user profile
/// 
/// **Theme Support:**
/// - Adapts to light and dark modes automatically
/// - Uses [AppTheme] colors for consistency
/// - Text styled with Google Fonts (Orbitron/Inter)
///
/// **Parameters:**
/// - [user]: Firebase user object
class UserProfileCard extends StatelessWidget {
  // ...
}
```

### 6. **Test Both Themes**
- Test every screen in light mode
- Test every screen in dark mode
- Check readability and contrast ratios
- Verify icon visibility on both backgrounds

### 7. **Handle Static Colors Carefully**
```dart
// When you MUST use a static color
const Color _accentColor = AppTheme.neonBlue;

// Or better: define in AppTheme and always reference it
static const Color accentColor = neonBlue;
```

---

## Troubleshooting

### Issue: Theme doesn't change when toggle is switched

**Cause:** `onThemeChange` callback not being called

**Solution:**
```dart
// In ProfileSettingsScreen._toggleDarkMode()
if (widget.onThemeChange != null) {
  widget.onThemeChange!(value);  // Make sure this is called
}
```

### Issue: Theme reverts to light after app restart

**Cause:** Preference not being saved to SharedPreferences

**Solution:**
```dart
// Verify in ProfileSettingsScreen._toggleDarkMode()
await ThemeService.setDarkMode(value);  // Must await
```

### Issue: New widgets don't follow theme

**Cause:** Using hard-coded colors instead of theme colors

**Solution:**
```dart
// Replace this:
color: Colors.blue,

// With this:
color: Theme.of(context).primaryColor,
```

### Issue: Light theme looks washed out

**Cause:** Colors not defined properly in lightTheme

**Solution:** Ensure AppTheme.lightTheme has:
- Proper contrast ratios (WCAG AA minimum 4.5:1)
- Defined inputDecorationTheme
- Defined buttonTheme
- Proper text colors

### Issue: Toggle freezes when switching themes

**Cause:** Async operation not handled properly

**Solution:**
```dart
Future<void> _toggleDarkMode(bool value) async {
  // Update UI immediately (optimistic update)
  setState(() => _isDarkMode = value);
  
  // Then save asynchronously
  await ThemeService.setDarkMode(value);
  
  // Trigger parent update
  widget.onThemeChange?.call(value);
}
```

### Issue: No loading screen on app start

**Cause:** Theme not initialized before build

**Check:** In `_CosmicQuestAppState.build()`:
```dart
if (!_initialized) {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: AppTheme.spaceBlack,
      body: Center(
        child: CircularProgressIndicator(
          color: AppTheme.neonBlue,
        ),
      ),
    ),
  );
}
```

---

## Advanced Topics

### Extending Theme System

To add additional theme modes (e.g., high contrast):

1. **Add constant to ThemeService:**
```dart
static const String _contrastKey = 'highContrast';

static Future<bool> isHighContrast() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_contrastKey) ?? false;
}
```

2. **Create new theme in AppTheme:**
```dart
static ThemeData get highContrastTheme {
  return ThemeData(
    // Much higher contrast colors
  );
}
```

3. **Add to MaterialApp:**
```dart
highContrastTheme: AppTheme.highContrastTheme,
```

### Custom Theme Builder Pattern

For complex theme customization:

```dart
class ThemeBuilder extends StatefulWidget {
  final Widget Function(BuildContext, ThemeMode) builder;
  
  const ThemeBuilder({required this.builder});
  
  @override
  State<ThemeBuilder> createState() => _ThemeBuilderState();
}

class _ThemeBuilderState extends State<ThemeBuilder> {
  late ThemeMode _themeMode;
  
  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }
  
  Future<void> _loadThemeMode() async {
    final isDark = await ThemeService.isDarkMode();
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _themeMode);
  }
}
```

---

## Summary

The dark mode implementation in CosmicX provides:

✅ **Persistent theme preference** using SharedPreferences  
✅ **Instant switching** without app restart  
✅ **Callback-based state propagation** through widget tree  
✅ **Complete light & dark themes** with consistent design  
✅ **User-friendly toggle** in settings with visual feedback  
✅ **Automatic widget adaptation** via Theme.of(context)  
✅ **No breaking changes** to existing functionality  

The system is production-ready and easily extensible for future enhancements!

---

## References

- [Flutter Theme Documentation](https://docs.flutter.dev/cookbook/design/themes)
- [SharedPreferences Package](https://pub.dev/packages/shared_preferences)
- [Material 3 Design System](https://m3.material.io/)
- [Google Fonts Package](https://pub.dev/packages/google_fonts)
