import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Classe para centralizar a paleta de cores do aplicativo.
class AppColors {
  static const primaryGreen = Color(0xFF2E7D32);
  static const accentOrange = Color(0xFFFF8F00);
  
  // Cores semânticas para o jogo
  static const success = Color(0xFF4CAF50);
  static const repeatedSuccess = Color(0xFF1B5E20);   // Verde Escuro
  static const warning = Color(0xFFFFA000);
  static const repeatedWarning = Color(0xFFE65100); // NOVO: Laranja Escuro
  static const neutral = Color(0xFF757575);
  
  // Cores de fundo e texto
  static const lightBackground = Color(0xFFF5F5F5);
  static const darkBackground = Color(0xFF121212);
  static const lightSurface = Colors.white;
  static const darkSurface = Color(0xFF1E1E1E);
  static const lightText = Color(0xFF212121);
  static const darkText = Color(0xFFE0E0E0);
}

// O resto da classe AppTheme permanece igual...
class AppTheme {
  // --- TEMA CLARO ---
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      brightness: Brightness.light,
      primary: AppColors.primaryGreen,
      secondary: AppColors.accentOrange, // Cor de destaque para botões
      tertiary: AppColors.success,      // Cor de sucesso (letra certa)
      surface: AppColors.lightBackground,
      onSurface: AppColors.lightText,
      surfaceContainer: AppColors.lightSurface,
      outline: Colors.grey.shade400,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: GoogleFonts.latoTextTheme(),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        fontSize: 22,
        color: AppColors.lightText,
      ),
      iconTheme: const IconThemeData(color: AppColors.lightText),
    ),
    filledButtonTheme: _getFilledButtonTheme(isDark: false),
  );

  // --- TEMA ESCURO ---
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      brightness: Brightness.dark,
      primary: AppColors.primaryGreen,
      secondary: AppColors.accentOrange,
      tertiary: AppColors.success,
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkText,
      surfaceContainer: AppColors.darkSurface,
      outline: Colors.grey.shade700,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: GoogleFonts.latoTextTheme().apply(bodyColor: AppColors.darkText),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        fontSize: 22,
        color: AppColors.darkText,
      ),
      iconTheme: const IconThemeData(color: AppColors.darkText),
    ),
    filledButtonTheme: _getFilledButtonTheme(isDark: true),
  );

  // Helper para centralizar o estilo dos botões
  static FilledButtonThemeData _getFilledButtonTheme({required bool isDark}) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primaryGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
    );
  }
}