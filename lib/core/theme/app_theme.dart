import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Brand Colors ──────────────────────────────────────────────
  static const Color primaryGreen = Color(0xFF16A34A);
  static const Color deepGreen = Color(0xFF14532D);
  static const Color lightGreen = Color(0xFF22C55E);
  static const Color emeraldGreen = Color(0xFF059669);

  // ─── Background & Surface ──────────────────────────────────────
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color borderColor = Color(0xFFE5E7EB);

  // ─── Text Colors ───────────────────────────────────────────────
  static const Color textDark = Color(0xFF111827);
  static const Color textMedium = Color(0xFF374151);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  // ─── Semantic ──────────────────────────────────────────────────
  static const Color discountRed = Color(0xFFEF4444);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentGreen = Color(0xFF16A34A);
  static const Color warningColor = Color(0xFFFFBE21);
  static const Color successColor = Color(0xFF4ADE80);

  // Keep for compatibility
  static const Color priceOrange = Color(0xFF16A34A);
  static const Color buyBlack = Color(0xFF16A34A);

  // ─── Product card background tints ─────────────────────────────
  static const Color cardMint = Color(0xFFECFDF5);
  static const Color cardYellow = Color(0xFFFFFBEB);
  static const Color cardLavender = Color(0xFFF0F9FF);
  static const Color cardSkyBlue = Color(0xFFEFF6FF);
  static const Color cardPeach = Color(0xFFFFF7ED);
  static const Color cardRose = Color(0xFFFFF1F2);
  static const Color cardLightBlue = Color(0xFFF0FDFB);
  static const Color cardLightGreen = Color(0xFFF0FDF4);
  static const Color cardWhite = Color(0xFFFFFFFF);

  static const List<Color> cardColors = [
    cardMint,
    cardYellow,
    cardLavender,
    cardPeach,
    cardRose,
    cardLightBlue,
    cardSkyBlue,
    cardLightGreen,
  ];

  // ─── Auth dark theme ───────────────────────────────────────────
  static const Color darkBg = Color(0xFF052E16);
  static const Color darkCard = Color(0xFF14532D);
  static const Color darkSurface = Color(0xFF166534);
  static const Color darkBorder = Color(0xFF166534);
  static const Color textPrimary = Color(0xFFF0FFF4);
  static const Color textSecondary = Color(0xFF86EFAC);
  static const Color primaryColor = Color(0xFF22C55E);
  static const Color secondaryColor = Color(0xFF16A34A);

  // ─── Light Theme ───────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgWhite,
      fontFamily: GoogleFonts.poppins().fontFamily,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: lightGreen,
        surface: bgWhite,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textDark,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(color: textGrey, fontSize: 14),
        labelStyle: const TextStyle(color: textGrey),
      ),
<<<<<<< HEAD
      cardTheme: CardTheme(
        color: cardWhite,
=======
      cardTheme: CardThemeData(
        color: bgWhite,
>>>>>>> a7827dde489fe9ddcee36f37ba6a8f4e8457db94
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderColor, width: 0.8),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgWhite,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 11),
      ),
    );
  }

  // ─── Auth Dark Theme ───────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      fontFamily: GoogleFonts.poppins().fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: darkCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
      ),
      cardTheme: CardTheme(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 0.5),
        ),
      ),
    );
  }
}
