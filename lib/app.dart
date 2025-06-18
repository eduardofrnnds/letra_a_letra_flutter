import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme/app_theme.dart';
import 'controllers/theme_controller.dart';
import 'pages/home_page.dart';

class WordleApp extends StatelessWidget {
  // CORREÇÃO: Usando a sintaxe moderna 'super.key'
  const WordleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Consome o ThemeController para obter o tema atual
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      title: 'LETRA A LETRA',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}