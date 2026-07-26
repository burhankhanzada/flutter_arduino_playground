import 'package:flutter/material.dart';

class AppTheme {
  // Dark Colors
  static const Color darkBackground = Color(0xFF1E1E1E);
  static const Color darkSurface = Color(0xFF252526);
  static const Color darkBorder = Color(0xFF3C3C3C);

  // Light Colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF3F3F3);
  static const Color lightBorder = Color(0xFFE8E8E8);

  static const Color accentColor = Color(0xFF007ACC);

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: accentColor,
      surface: darkSurface,
      outline: darkBorder,
    ),
    dividerColor: darkBorder,
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: darkBorder),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        hoverColor: Colors.white12,
        highlightColor: Colors.transparent, // Disable splash
        splashFactory: NoSplash.splashFactory,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: darkBorder,
      space: 1,
      thickness: 1,
    ),
  );

  static final ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: accentColor,
      surface: lightSurface,
      outline: lightBorder,
    ),
    dividerColor: lightBorder,
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: lightBorder),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        hoverColor: Colors.black12,
        highlightColor: Colors.transparent, // Disable splash
        splashFactory: NoSplash.splashFactory,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: lightBorder,
      space: 1,
      thickness: 1,
    ),
  );
}
