import 'package:flutter/material.dart';

/// Flutter ThemeData generated from VS Code's official
/// Dark Modern & Light Modern themes.
///
/// Usage:
///   MaterialApp(
///     theme: VSCodeTheme.light,
///     darkTheme: VSCodeTheme.dark,
///     themeMode: ThemeMode.system,
///   )
abstract final class VSCodeTheme {
  static ThemeData get light => _createTheme(Brightness.light);
  static ThemeData get dark => _createTheme(Brightness.dark);

  static ThemeData _createTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final isDark = !isLight;

    // Palette
    final primary = isLight ? const Color(0xFF005FB8) : const Color(0xFF0078D4);
    final primaryHover = isLight ? const Color(0xFF0258A8) : const Color(0xFF026EC1);
    final onPrimary = const Color(0xFFFFFFFF);
    final secondary = isLight ? const Color(0xFFCCCCCC) : const Color(0xFF2B2B2B);
    final onSecondary = isLight ? const Color(0xFF3B3B3B) : const Color(0xFFCCCCCC);
    final background = isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1F1F1F);
    final surface = isLight ? const Color(0xFFF8F8F8) : const Color(0xFF181818);
    final surfaceVariant = isLight ? const Color(0xFFF3F3F3) : const Color(0xFF2B2B2B);
    final onSurface = isLight ? const Color(0xFF3B3B3B) : const Color(0xFFCCCCCC);
    final onSurfaceVariant = isLight ? const Color(0xFF616161) : const Color(0xFF9D9D9D);
    final outline = isLight ? const Color(0xFFE5E5E5) : const Color(0xFF2B2B2B);
    final outlineVariant = isLight ? const Color(0xFFCECECE) : const Color(0xFF3C3C3C);
    final error = const Color(0xFFF85149);
    final onError = const Color(0xFFFFFFFF);
    final errorContainer = isLight ? const Color(0xFFC72E0F) : const Color(0xFF8B1A1A);
    final onErrorContainer = isLight ? const Color(0xFFFFFFFF) : const Color(0xFFFFCCCC);
    final tertiary = const Color(0xFF2EA043);
    final onTertiary = const Color(0xFFFFFFFF);
    final tertiaryContainer = isLight ? const Color(0xFFE5EBF1) : const Color(0xFF1A3A1A);
    final onTertiaryContainer = isLight ? const Color(0xFF3B3B3B) : const Color(0xFFCCFFCC);
    final inverseSurface = isLight ? const Color(0xFF1F1F1F) : const Color(0xFFF8F8F8);
    final onInverseSurface = isLight ? const Color(0xFFF8F8F8) : const Color(0xFF1F1F1F);
    final inversePrimary = isLight ? const Color(0xFF4DAAFC) : const Color(0xFF005FB8);
    final shadow = isLight ? const Color(0x1A000000) : const Color(0x40000000);
    final scrim = isLight ? const Color(0x1A000000) : const Color(0x40000000);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: isLight ? const Color(0xFFADCEFF) : const Color(0xFF264778),
      onPrimaryContainer: isLight ? const Color(0xFF003366) : const Color(0xFFCCE4FF),
      primaryFixed: isLight ? const Color(0xFFBED6ED) : const Color(0xFF2489DB),
      primaryFixedDim: isLight ? primary : primaryHover,
      onPrimaryFixed: isLight ? const Color(0xFF000000) : onPrimary,
      onPrimaryFixedVariant: isLight ? primaryHover : const Color(0xFF85B6FF),
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: isLight ? const Color(0xFFE8E8E8) : const Color(0xFF313131),
      onSecondaryContainer: isLight ? const Color(0xFF000000) : const Color(0xFFCCCCCC),
      secondaryFixed: isLight ? const Color(0xFFF2F2F2) : const Color(0xFF252525),
      secondaryFixedDim: secondary,
      onSecondaryFixed: onSecondary,
      onSecondaryFixedVariant: isLight ? const Color(0xFF868686) : onSurfaceVariant,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      tertiaryFixed: isLight ? const Color(0xFFC8DDF1) : const Color(0xFF1A4020),
      tertiaryFixedDim: tertiary,
      onTertiaryFixed: isLight ? const Color(0xFF003320) : const Color(0xFF99FFAA),
      onTertiaryFixedVariant: isLight ? const Color(0xFF1A6B2E) : const Color(0xFF55CC77),
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceDim: isLight ? const Color(0xFFECECEC) : const Color(0xFF111111),
      surfaceBright: isLight ? background : const Color(0xFF2B2B2B),
      surfaceContainerLowest: isLight ? background : const Color(0xFF111111),
      surfaceContainerLow: surface,
      surfaceContainer: isLight ? surfaceVariant : const Color(0xFF1F1F1F),
      surfaceContainerHigh: isLight ? const Color(0xFFEEEEEE) : const Color(0xFF252525),
      surfaceContainerHighest: isLight ? outline : const Color(0xFF313131),
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: onInverseSurface,
      inversePrimary: inversePrimary,
      surfaceTint: primary,
    );

    // Legacy colors
    final cardColor = isLight ? surface : const Color(0xFF202020);
    final hintColor = isLight ? const Color(0xFF767676) : const Color(0xFF989898);
    final disabledColor = isLight ? const Color(0xFF8B949E) : const Color(0xFF6E7681);
    final highlightColor = isLight ? const Color(0xFFADD6FF) : const Color(0xFF9E6A03);
    final splashColor = isLight ? const Color(0x1A005FB8) : const Color(0x280078D4);
    final focusColor = isLight ? const Color(0xFF005FB8) : const Color(0xFF0078D4);
    final hoverColor = isLight ? const Color(0xFFF2F2F2) : const Color(0x1AF1F1F1);
    final unselectedWidgetColor = isLight ? const Color(0xFF616161) : const Color(0xFF868686);
    final secondaryHeaderColor = isLight ? surface : const Color(0xFF181818);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,

      // ── Legacy top-level color slots (backward compat) ──────────────────────
      scaffoldBackgroundColor: background,
      cardColor: cardColor,
      canvasColor: background,
      dividerColor: outline,
      hintColor: hintColor,
      disabledColor: disabledColor,
      highlightColor: highlightColor,
      splashColor: splashColor,
      focusColor: focusColor,
      hoverColor: hoverColor,
      unselectedWidgetColor: unselectedWidgetColor,
      secondaryHeaderColor: secondaryHeaderColor,

      // ── Typography ──────────────────────────────────────────────────────────
      fontFamily: 'Consolas',

      // ── AppBar ──────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      // ── Card ────────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: outline, width: 1),
        ),
        margin: const EdgeInsets.all(0),
      ),

      // ── Divider ─────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: outline,
        thickness: 1,
        space: 1,
      ),

      // ── ElevatedButton ──────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: disabledColor.withAlpha(60),
          disabledForegroundColor: disabledColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),

      // ── OutlinedButton ──────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: BorderSide(color: outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(fontSize: 13),
        ),
      ),

      // ── TextButton ──────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          textStyle: const TextStyle(fontSize: 13),
        ),
      ),

      // ── IconButton ──────────────────────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),

      // ── InputDecoration ─────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF313131) : Colors.white,
        hintStyle: TextStyle(color: hintColor, fontSize: 13),
        labelStyle: TextStyle(
          color: onSurfaceVariant,
          fontSize: 13,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: outline.withAlpha(isDark ? 255 : 200),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: error, width: 1.5),
        ),
        isDense: true,
      ),

      // ── ListTile ────────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: primary.withAlpha(30),
        selectedColor: primary,
        iconColor: onSurface,
        textColor: onSurface,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // ── Checkbox ────────────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return isDark ? const Color(0xFF313131) : const Color(0xFFF8F8F8);
        }),
        checkColor: WidgetStateProperty.all(onPrimary),
        side: BorderSide(color: outline, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),

      // ── Switch ──────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return onPrimary;
          }
          return onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return outline;
        }),
      ),

      // ── Chip ────────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF313131) : const Color(0xFFF3F3F3),
        selectedColor: primary.withAlpha(40),
        labelStyle: TextStyle(color: onSurface, fontSize: 12),
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      ),

      // ── Dialog ──────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: outline),
        ),
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(color: onSurface, fontSize: 13),
      ),

      // ── Tooltip ─────────────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3C3C3C) : const Color(0xFF3B3B3B),
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        waitDuration: const Duration(milliseconds: 500),
      ),

      // ── SnackBar ─────────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF313131) : const Color(0xFF3B3B3B),
        contentTextStyle: const TextStyle(
          color: Color(0xFFCCCCCC),
          fontSize: 13,
        ),
        actionTextColor: primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        behavior: SnackBarBehavior.floating,
      ),

      // ── ProgressIndicator ────────────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: outline,
        circularTrackColor: Colors.transparent,
      ),

      // ── Tab ─────────────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: onSurface,
        unselectedLabelColor: onSurfaceVariant,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primary, width: 2),
        ),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        dividerColor: outline,
      ),

      // ── NavigationBar ────────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withAlpha(40),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary);
          }
          return IconThemeData(color: onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(color: primary, fontSize: 12);
          }
          return TextStyle(color: onSurfaceVariant, fontSize: 12);
        }),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),

      // ── NavigationRail ───────────────────────────────────────────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        selectedIconTheme: IconThemeData(color: primary),
        unselectedIconTheme: IconThemeData(color: onSurfaceVariant),
        selectedLabelTextStyle: TextStyle(
          color: primary,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: onSurfaceVariant,
          fontSize: 12,
        ),
        indicatorColor: primary.withAlpha(30),
        elevation: 0,
      ),

      // ── Drawer ───────────────────────────────────────────────────────────────
      drawerTheme: DrawerThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),

      // ── BottomSheet ──────────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: onSurfaceVariant,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ),

      // ── FloatingActionButton ─────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // ── Popup Menu ───────────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF8F8F8),
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: outline),
        ),
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(color: onSurface, fontSize: 13),
        ),
      ),

      // ── Badge ────────────────────────────────────────────────────────────────
      badgeTheme: BadgeThemeData(
        backgroundColor: primary,
        textColor: onPrimary,
        smallSize: 8,
        largeSize: 16,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),

      // ── Icon ─────────────────────────────────────────────────────────────────
      iconTheme: IconThemeData(color: onSurface, size: 18),
      primaryIconTheme: IconThemeData(color: onPrimary, size: 18),

      // ── Text Selection ───────────────────────────────────────────────────────
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primary,
        selectionColor: primary.withAlpha(60),
        selectionHandleColor: primary,
      ),
    );
  }
}
