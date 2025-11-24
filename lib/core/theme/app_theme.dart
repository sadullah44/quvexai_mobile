import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- RENK PALETİ ---
  static const Color _primaryLight = Color(0xFF6C63FF);
  static const Color _secondaryLight = Color(0xFF00BFA6);
  static const Color _backgroundLight = Color(0xFFF4F6F8);
  static const Color _surfaceLight = Colors.white;
  static const Color _errorLight = Color(0xFFE57373);

  // --- LIGHT THEME ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: const ColorScheme.light(
        primary: _primaryLight,
        onPrimary: Colors.white,
        secondary: _secondaryLight,
        onSecondary: Colors.white,
        surface: _surfaceLight,
        onSurface: Colors.black87,
        error: _errorLight,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: _backgroundLight,

      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        titleLarge: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        bodyMedium: const TextStyle(color: Colors.black54),
      ),

      // --- BURAYI AKTİF ETTİK ---
      cardTheme: CardThemeData(
        color: _surfaceLight,
        elevation: 2, // Biraz gölge verdik ki belli olsun
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Daha yuvarlak köşeler
          side: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        shadowColor: Colors.black.withOpacity(0.1), // Hafif gölge rengi
      ),

      // ---------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryLight,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: _primaryLight.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: _backgroundLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceLight,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryLight, width: 2),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surfaceLight,
        selectedItemColor: _primaryLight,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
