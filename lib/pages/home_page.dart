import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_page.dart'; // CORREÇÃO: Removido 'pages/' do caminho de importação

class HomePage extends StatefulWidget {
  // CORREÇÃO: Sintaxe moderna para construtores
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Adiciona um pequeno delay para a animação de fade-in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            // Animação de opacidade para a tela aparecer suavemente
            child: AnimatedOpacity(
              opacity: _isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeIn,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Letra a Letra',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 80),
                  // Botão moderno com ícone
                  FilledButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Modo Diário'),
                    onPressed: () => _navigateToGame(context, isDaily: true),
                  ),
                  const SizedBox(height: 20),
                  // Segundo estilo de botão, para variar
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('Modo Treinamento'),
                    onPressed: () => _navigateToGame(context, isDaily: false),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Configurações ainda não implementadas.'))
                          );
                        },
                        iconSize: 28,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () => _mostrarInstrucoes(context),
                        iconSize: 28,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  )
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

  void _mostrarInstrucoes(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Como Jogar'),
        content: const SingleChildScrollView(
          child: Text(
            'Adivinhe a palavra secreta em 6 tentativas.\n\n'
            'Após cada tentativa, a cor das letras mudará para mostrar o quão perto você está:\n\n'
            'Verde: A letra está na palavra e na posição correta.\n'
            'Amarelo: A letra está na palavra, mas na posição errada.\n'
            'Cinza: A letra não está na palavra.\n'
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Entendi!'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
