import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF006399),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFCDE5FF),
  onPrimaryContainer: Color(0xFF001D32),
  secondary: Color(0xFFB88E00), // Amarelo/Laranja para "posição errada"
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFFFDF9E),
  onSecondaryContainer: Color(0xFF241A00),
  tertiary: Color(0xFF4CAF50), // Verde para "correto"
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFC8F7C5),
  onTertiaryContainer: Color(0xFF0D1F0C),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFF8F9FF),
  onBackground: Color(0xFF191C20),
  surface: Color(0xFFF8F9FF),
  onSurface: Color(0xFF191C20),
  surfaceVariant: Color(0xFFDEE3EB), // Fundo do teclado
  onSurfaceVariant: Color(0xFF42474E), // Texto do teclado
  outline: Color(0xFF72787E),
  outlineVariant: Color(0xFFC2C7CE),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFF2E3135),
  onInverseSurface: Color(0xFFF0F1F6),
  inversePrimary: Color(0xFF96CCFF),
);

const _darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF96CCFF),
  onPrimary: Color(0xFF003352),
  primaryContainer: Color(0xFF004A74),
  onPrimaryContainer: Color(0xFFCDE5FF),
  secondary: Color(0xFFD4C33D), // Amarelo/Laranja para "posição errada"
  onSecondary: Color(0xFF3D2F00),
  secondaryContainer: Color(0xFF584400),
  onSecondaryContainer: Color(0xFFFFDF9E),
  tertiary: Color(0xFF67D46D), // Verde para "correto"
  onTertiary: Color(0xFF00390F),
  tertiaryContainer: Color(0xFF2B7536),
  onTertiaryContainer: Color(0xFFB5F3AC),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF111418),
  onBackground: Color(0xFFE2E2E6),
  surface: Color(0xFF111418),
  onSurface: Color(0xFFE2E2E6),
  surfaceVariant: Color(0xFF42474E), // Fundo do teclado
  onSurfaceVariant: Color(0xFFC2C7CE), // Texto do teclado
  outline: Color(0xFF8C9198),
  outlineVariant: Color(0xFF42474E),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFFE2E2E6),
  onInverseSurface: Color(0xFF191C20),
  inversePrimary: Color(0xFF006399),
);

class AppTheme {
  // Tema Claro
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    textTheme: GoogleFonts.robotoTextTheme(),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: _lightColorScheme.background,
      foregroundColor: _lightColorScheme.onBackground,
      elevation: 0,
      titleTextStyle: GoogleFonts.roboto(
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    ),
  );

  // Tema Escuro
  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    textTheme: GoogleFonts.robotoTextTheme().apply(
      bodyColor: _darkColorScheme.onBackground,
      displayColor: _darkColorScheme.onBackground,
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: _darkColorScheme.background,
      foregroundColor: _darkColorScheme.onBackground,
      elevation: 0,
      titleTextStyle: GoogleFonts.roboto(
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    ),
  );
}
