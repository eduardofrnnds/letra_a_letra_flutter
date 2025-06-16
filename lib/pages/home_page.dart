import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';
import 'game_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final themeController = context.watch<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          // Botão para trocar o tema, agora na AppBar
          IconButton(
            icon: Icon(
              themeController.themeMode == ThemeMode.dark 
                ? Icons.light_mode_outlined 
                : Icons.dark_mode_outlined,
            ),
            onPressed: () {
              final newMode = themeController.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
              context.read<ThemeController>().setThemeMode(newMode);
            },
            tooltip: "Mudar Tema",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: AnimatedOpacity(
              opacity: _isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeIn,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'LETRA A LETRA',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 80),
                  FilledButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('DIÁRIO'),
                    onPressed: () => _navigateToGame(context, isDaily: true),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.secondary, // Usando a cor de destaque
                    ),
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('PRATICAR'),
                    onPressed: () => _navigateToGame(context, isDaily: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context, {required bool isDaily}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(isModoDiario: isDaily),
      ),
    );
  }
}
