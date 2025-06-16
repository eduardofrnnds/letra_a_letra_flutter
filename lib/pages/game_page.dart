import 'package:flutter/material.dart';
import '../controllers/jogo_controller.dart';
import '../widgets/grade_jogo.dart';
import '../widgets/teclado_virtual.dart';

class GamePage extends StatefulWidget {
  final bool isModoDiario;
  const GamePage({Key? key, required this.isModoDiario}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final JogoController _controller;
  // NOVO: Future para controlar o estado de inicialização
  Future<void>? _initFuture;

  @override
  void initState() {
    super.initState();
    _controller = JogoController(isModoDiario: widget.isModoDiario);
    // Inicia o processo de carregamento/inicialização
    _initFuture = _controller.inicializar();
    
    _controller.addListener(() {
      // O diálogo de fim de jogo não é mais acionado por aqui,
      // para evitar que apareça ao carregar um jogo já terminado.
      // Ele será mostrado apenas ao submeter a jogada final.
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _mostrarDialogoFimDeJogo() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_controller.venceu ? 'Parabéns!' : 'Que pena!'),
        content: Text(
          _controller.venceu
              ? 'Você acertou a palavra!'
              : 'A palavra era "${_controller.palavraSecretaOriginal}".',
        ),
        actions: [
          // No modo diário, só haverá a opção de voltar ao menu.
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Voltar ao Menu'),
          ),
        ],
      ),
    );
  }

  void _onEnterTapped() {
    final resultado = _controller.submeterPalpite();
    
    if (resultado != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(10),
        ),
      );
    }

    // NOVO: Mostra o diálogo de fim de jogo aqui, após a jogada final.
    if (_controller.jogoTerminou && !_controller.jaJogouHoje) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          _mostrarDialogoFimDeJogo();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isModoDiario ? 'Modo Diário' : 'Modo Treinamento'),
      ),
      // NOVO: FutureBuilder para lidar com a inicialização assíncrona.
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mostra um indicador de carregamento enquanto verifica o SharedPreferences.
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar o jogo: ${snapshot.error}'));
          }

          // Quando a inicialização estiver completa, constrói a interface do jogo.
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        child: GradeJogo(
                          grade: _controller.grade,
                          estadosGrade: _controller.estadosGrade,
                          tentativaAtual: _controller.tentativaAtual,
                        ),
                      ),
                    ),
                    // NOVO: Mostra a mensagem se o jogo diário já foi completado.
                    if (widget.isModoDiario && _controller.jaJogouHoje)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Você já jogou hoje. Volte amanhã!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    // NOVO: Desativa o teclado se o jogo tiver terminado.
                    IgnorePointer(
                      ignoring: _controller.jogoTerminou,
                      child: TecladoVirtual(
                        onKeyTapped: _controller.digitarLetra,
                        onBackspaceTapped: _controller.apagarLetra,
                        onEnterTapped: _onEnterTapped,
                        estadosTeclado: _controller.estadosTeclado,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
