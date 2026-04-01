import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color constants — Material Theme Builder dark scheme
  static const Color background    = Color(0xFF0F1512); // dark.background / scheme.surface
  static const Color surface       = Color(0xFF1B211E); // surfaceContainer
  static const Color card          = Color(0xFF252B29); // surfaceContainerHigh
  static const Color accent        = Color(0xFF88D6BB); // primary
  static const Color accentText    = Color(0xFF00382B); // onPrimary
  static const Color textPrimary   = Color(0xFFDEE4DF); // onSurface
  static const Color textSecondary = Color(0xFFBFC9C3); // onSurfaceVariant
  static const Color error         = Color(0xFFFFB4AB); // error
  static const Color success       = Color(0xFF88D6BB); // reuse primary
  static const Color warning       = Color(0xFFFFB800);
  static const Color divider       = Color(0xFF252B29); // surfaceContainerHigh

  // Semantic budget-state colors (domain-specific, outside M3 scheme)
  static const Color budgetGood    = Color(0xFF40AC02); // healthy
  static const Color budgetWarning = Color(0xFFE8A020); // caution (amber adjusted for dark)
  static const Color budgetBad     = Color(0xFFC70909); // overspent

  static Color budgetStateColor(double spentFraction) {
    if (spentFraction < 0.7) return budgetGood;
    if (spentFraction < 0.9) return budgetWarning;
    return budgetBad;
  }

  // Material Theme Builder — dark scheme
  static const ColorScheme _colorScheme = ColorScheme(
    brightness:           Brightness.dark,
    primary:              Color(0xFF88D6BB),
    onPrimary:            Color(0xFF00382B),
    primaryContainer:     Color(0xFF00513F),
    onPrimaryContainer:   Color(0xFFA3F2D6),
    secondary:            Color(0xFFB2CCC1),
    onSecondary:          Color(0xFF1E352D),
    secondaryContainer:   Color(0xFF344C43),
    onSecondaryContainer: Color(0xFFCEE9DD),
    tertiary:             Color(0xFFA8CBE2),
    onTertiary:           Color(0xFF0C3446),
    tertiaryContainer:    Color(0xFF274B5D),
    onTertiaryContainer:  Color(0xFFC3E8FE),
    error:                Color(0xFFFFB4AB),
    onError:              Color(0xFF690005),
    errorContainer:       Color(0xFF93000A),
    onErrorContainer:     Color(0xFFFFDAD6),
    surface:              Color(0xFF0F1512),
    onSurface:            Color(0xFFDEE4DF),
    surfaceContainerHighest: Color(0xFF3F4945),
    onSurfaceVariant:        Color(0xFFBFC9C3),
    outline:              Color(0xFF89938E),
    outlineVariant:       Color(0xFF3F4945),
    shadow:               Color(0xFF000000),
    scrim:                Color(0xFF000000),
    inverseSurface:       Color(0xFFDEE4DF),
    onInverseSurface:     Color(0xFF2C322F),
    inversePrimary:       Color(0xFF146B55),
  );

  // Manrope text theme — bold, confident voice for all type scales
  static TextTheme get _textTheme => TextTheme(
    displayLarge:  GoogleFonts.manrope(fontSize: 57, fontWeight: FontWeight.w700, color: textPrimary),
    displayMedium: GoogleFonts.manrope(fontSize: 45, fontWeight: FontWeight.w700, color: textPrimary),
    displaySmall:  GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w600, color: textPrimary),
    headlineLarge: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w600, color: textPrimary),
    headlineMedium:GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w600, color: textPrimary),
    headlineSmall: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary),
    titleLarge:    GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary),
    titleMedium:   GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
    titleSmall:    GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
    bodyLarge:     GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
    bodyMedium:    GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary),
    bodySmall:     GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary),
    labelLarge:    GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
    labelMedium:   GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary),
    labelSmall:    GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w400, color: textSecondary),
  );

  static ThemeData get dark => ThemeData(
        useMaterial3:            true,
        colorScheme:             _colorScheme,
        scaffoldBackgroundColor: background,
        textTheme:               _textTheme,

        // AppBar
        appBarTheme: AppBarTheme(
          backgroundColor:        background,
          foregroundColor:        textPrimary,
          elevation:              0,
          scrolledUnderElevation: 2,
          centerTitle:            true,
          titleTextStyle: GoogleFonts.manrope(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            color: textPrimary,
          ),
        ),

        // Cards — large shape token = 16px
        cardTheme: const CardThemeData(
          color:     card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          margin: EdgeInsets.zero,
        ),

        // Input fields — large shape token = 16px (flat/borderless style)
        inputDecorationTheme: const InputDecorationTheme(
          filled:    true,
          fillColor: surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide:   BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide:   BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide:   BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide:   BorderSide(color: error, width: 1),
          ),
          hintStyle:      TextStyle(color: textSecondary, fontSize: 14),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),

        // FilledButton — M3 primary action, large shape token = 16px
        // Using ButtonStyle directly — FilledButton.styleFrom() can lose shape to M3 stadium default
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(accent),
            foregroundColor: WidgetStateProperty.all(accentText),
            minimumSize:     WidgetStateProperty.all(const Size(double.infinity, 52)),
            elevation:       WidgetStateProperty.all(0),
            shape: WidgetStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            textStyle: WidgetStateProperty.all(
              const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),

        // Text buttons
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: accent,
            textStyle: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Bottom navigation
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: surface,
          // Explicit primaryContainer pill — no more muddy rectangle
          indicatorColor: const Color(0xFF00513F), // primaryContainer
          indicatorShape: const StadiumBorder(),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: accent);
            }
            return const IconThemeData(color: textSecondary);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: accent,
              );
            }
            return const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w400, color: textSecondary,
            );
          }),
          elevation:   2,
          shadowColor: const Color(0xFF000000),
          height:      64,
        ),

        // Bottom sheet — M3 extra-large shape token = 28px top corners
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          elevation: 0,
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color:     divider,
          thickness: 0.5,
          space:     0,
        ),

        // Chip — 12px
        chipTheme: const ChipThemeData(
          backgroundColor: card,
          labelStyle: TextStyle(fontSize: 12, color: textPrimary),
          side:  BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),

        // Dialog — M3 extra-large shape token = 28px
        dialogTheme: const DialogThemeData(
          elevation: 6,
          shadowColor: Color(0xFF000000), // colorScheme.shadow
          backgroundColor: card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
        ),

        // Snackbar — 12px floating
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: card,
          contentTextStyle: TextStyle(fontSize: 13, color: textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
