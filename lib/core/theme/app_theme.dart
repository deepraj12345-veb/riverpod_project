import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Green Light Theme Colors ──────────────────────────────────────────────
  static const Color primaryGreen = Color(0xFF16A34A); // Main green
  static const Color deepGreen = Color(0xFF166534); // Dark green (buttons, nav)
  static const Color emeraldGreen = Color(0xFF059669); // Mid emerald
  static const Color lightGreen = Color(0xFF22C55E); // Bright green

  // Semantic aliases used across screens
  static const Color priceOrange = Color(0xFF15803D); // Price text → deep green
  static const Color buyBlack = Color(0xFF166534); // Buy button → forest green
  static const Color textDark = Color(0xFF14532D); // Primary text → dark forest
  static const Color textGrey = Color(0xFF6B7280); // Secondary text → grey
  static const Color bgWhite = Color(0xFFF0FDF4); // Scaffold → mint white
  static const Color cardWhite = Color(0xFFFFFFFF); // Card surface → pure white
  static const Color accentRed = Color(0xFF16A34A); // Accent → primary green
  static const Color accentGreen = Color(0xFF22C55E); // Success / in-stock

  // ─── Pastel card background palette (green-tinted) ────────────────────────
  static const Color cardLavender = Color(0xFFDCFCE7); // Mint green
  static const Color cardYellow = Color(0xFFF0FDF4); // Light mint
  static const Color cardSkyBlue = Color(0xFFECFDF5); // Pale emerald
  static const Color cardMint = Color(0xFFD1FAE5); // Soft mint
  static const Color cardPeach = Color(0xFFBBF7D0); // Light jade
  static const Color cardRose = Color(0xFFA7F3D0); // Aqua mint
  static const Color cardLightBlue = Color(0xFFCCFBF1); // Teal-mint
  static const Color cardLightGreen = Color(0xFFECFDF5); // Pale fresh

  // ─── Auth dark theme colours (kept dark, green accents) ───────────────────
  static const Color darkBg = Color(0xFF052E16); // Very dark green bg
  static const Color darkCard = Color(0xFF14532D); // Dark green card
  static const Color darkSurface = Color(0xFF166534); // Surface
  static const Color darkBorder = Color(0xFF166534); // Border
  static const Color textPrimary = Color(0xFFF0FFF4); // Near-white on dark
  static const Color textSecondary = Color(0xFF86EFAC); // Soft green on dark
  static const Color primaryColor = Color(0xFF22C55E); // Auth gradient start
  static const Color secondaryColor = Color(0xFF16A34A); // Auth gradient end
  static const Color successColor = Color(0xFF4ADE80);
  static const Color warningColor = Color(0xFFFFBE21);

  // ─── Card color cycle ─────────────────────────────────────────────────────
  static const List<Color> cardColors = [
    cardLavender,
    cardMint,
    cardSkyBlue,
    cardPeach,
    cardRose,
    cardLightBlue,
    cardYellow,
    cardLightGreen,
  ];

  // ─── Light (green) Theme ──────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgWhite,
      fontFamily: GoogleFonts.poppins().fontFamily,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: lightGreen,
        surface: cardWhite,
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
          fontSize: 22,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFBBF7D0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFBBF7D0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textGrey),
        hintStyle: const TextStyle(color: textGrey),
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardWhite,
        selectedItemColor: Color.fromARGB(255, 148, 9, 76),
        unselectedItemColor: Color.fromARGB(255, 16, 16, 17),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 11,
        ),
      ),
    );
  }

  // ─── Dark (auth) Theme — stays dark with green accents ─────
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
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
      cardTheme: CardThemeData(
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
