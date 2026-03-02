import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark Mode Colors
  static const Color spaceBlack = Color(0xFF0B0D17); // Deep background
  static const Color neonBlue = Color(0xFF00D4FF); // Primary Buttons/Accents
  static const Color starlightWhite = Color(0xFFF9FAFB); // Text
  static const Color marsRed = Color(0xFFFF5E5B); // Errors
  static const Color voidGrey = Color(0xFF1F2937); // Cards

  // Light Mode Colors (High Contrast for Accessibility)
  static const Color skyWhite = Color(0xFFFFFFFF);
  static const Color deepNavy = Color(0xFF0B3D91); // NASA Blue
  static const Color textBlack = Color(0xFF111827);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: spaceBlack,
      primaryColor: neonBlue,

      // Define Text Styles (Futuristic Headers, Readable Body)
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: starlightWhite,
        ),
        headlineSmall: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: neonBlue,
        ),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: starlightWhite),
      ),

      // Input Fields (Login/Signup)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: voidGrey,
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

      // Buttons (Big & Tappable for Kids)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonBlue,
          foregroundColor: spaceBlack, // Text color on button
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

      // Bottom Nav Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: spaceBlack,
        selectedItemColor: neonBlue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: skyWhite,
      primaryColor: deepNavy,

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
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: textBlack),
      ),

      // Input Fields (Login/Signup)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE8E8F0),
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

      // Buttons
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

      // Bottom Nav Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: skyWhite,
        selectedItemColor: deepNavy,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
