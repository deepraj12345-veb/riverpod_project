import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Green Light Theme Colors ──────────────────────────────────────────────
  static const Color primaryGreen = Color(0xFF16A34A);
  static const Color deepGreen = Color(0xFF166534);
  static const Color emeraldGreen = Color(0xFF059669);
  static const Color lightGreen = Color(0xFF22C55E);

  // Semantic aliases used across screens
  static const Color priceOrange = Color(0xFF15803D);
  static const Color buyBlack = Color(0xFF166534);
  static const Color textDark = Color(0xFF14532D);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color bgWhite = Color(0xFFF0FDF4);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color accentRed = Color(0xFF16A34A);
  static const Color accentGreen = Color(0xFF22C55E);

  // ─── Pastel card background palette (green-tinted) ────────────────────────
  static const Color cardLavender = Color(0xFFDCFCE7);
  static const Color cardYellow = Color(0xFFF0FDF4);
  static const Color cardSkyBlue = Color(0xFFECFDF5);
  static const Color cardMint = Color(0xFFD1FAE5);
  static const Color cardPeach = Color(0xFFBBF7D0);
  static const Color cardRose = Color(0xFFA7F3D0);
  static const Color cardLightBlue = Color(0xFFCCFBF1);
  static const Color cardLightGreen = Color(0xFFECFDF5);

  // ─── Auth dark theme colours (kept dark, green accents) ───────────────────
  static const Color darkBg = Color(0xFF052E16);
  static const Color darkCard = Color(0xFF14532D);
  static const Color darkSurface = Color(0xFF166534);
  static const Color darkBorder = Color(0xFF166534);
  static const Color textPrimary = Color(0xFFF0FFF4);
  static const Color textSecondary = Color(0xFF86EFAC);
  static const Color primaryColor = Color(0xFF22C55E);
  static const Color secondaryColor = Color(0xFF16A34A);
  static const Color successColor = Color(0xFF4ADE80);
  static const Color warningColor = Color(0xFFFFBE21);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textMedium = Color(0xFF374151);

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
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primaryGreen,
        selectionColor: cardPeach,
        selectionHandleColor: primaryGreen,
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
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primaryColor,
        selectionColor: darkSurface,
        selectionHandleColor: primaryColor,
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
