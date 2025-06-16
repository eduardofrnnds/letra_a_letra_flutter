import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/jogo_controller.dart';
import '../widgets/grade_jogo.dart';
import '../widgets/teclado_virtual.dart';

class GamePage extends StatelessWidget {
  final bool isModoDiario;
  const GamePage({super.key, required this.isModoDiario});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JogoController(isModoDiario: isModoDiario),
      child: const _GameView(),
    );
  }
}

class _GameView extends StatefulWidget {
  const _GameView();

  @override
  __GameViewState createState() => __GameViewState();
}

class __GameViewState extends State<_GameView> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // A lógica de inicialização é chamada de forma segura
    // após o primeiro frame da UI ser construído.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  Future<void> _initializeGame() async {
    final controller = context.read<JogoController>();
    if (controller.isModoDiario) {
      await controller.carregarJogoDiario();
    } else {
      controller.iniciarJogoTreino();
    }

    // Após a inicialização, atualiza o estado para remover o loading
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onEnterTapped() {
    final controller = context.read<JogoController>();
    if (controller.jogoTerminou) return;

    final resultado = controller.submeterPalpite();
    
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

    if (controller.jogoTerminou) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) _mostrarDialogoFimDeJogo(controller);
      });
    }
  }

  void _mostrarDialogoFimDeJogo(JogoController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(controller.venceu ? 'Parabéns!' : 'Que pena!'),
        content: Text(
          controller.venceu
              ? 'Você acertou a palavra!'
              : 'A palavra era "${controller.palavraSecretaOriginal}".',
        ),
        actions: [
          if (!controller.isModoDiario)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.iniciarJogoTreino();
              },
              child: const Text('Jogar de Novo'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('Voltar ao Menu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.read<JogoController>().isModoDiario ? 'PALAVRA DO DIA' : 'PRATICAR'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final controller = context.watch<JogoController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isModoDiario ? 'PALAVRA DO DIA' : 'PRATICAR'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const GradeJogo(),
            const Spacer(),
            if (controller.isModoDiario && controller.jaJogouHoje)
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
            IgnorePointer(
              ignoring: controller.jogoTerminou,
              child: TecladoVirtual(
                onKeyTapped: context.read<JogoController>().digitarLetra,
                onBackspaceTapped: context.read<JogoController>().apagarLetra,
                onEnterTapped: _onEnterTapped,
                estadosTeclado: controller.estadosTeclado,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
