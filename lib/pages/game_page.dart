import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/jogo_controller.dart';
import '../widgets/grade_jogo.dart';
import '../widgets/teclado_virtual.dart';

class GamePage extends StatelessWidget {
  final bool isModoDiario;
  final JogoController? practiceController;

  const GamePage({
    super.key, 
    required this.isModoDiario,
    this.practiceController
  });

  @override
  Widget build(BuildContext context) {
    if (!isModoDiario && practiceController != null) {
      return ChangeNotifierProvider.value(
        value: practiceController!,
        child: const _GameView(),
      );
    }
    
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
  String? _errorMessage;
  Timer? _errorTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeGame());
  }
  
  @override
  void dispose() {
    _errorTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    final controller = context.read<JogoController>();
    if (controller.isModoDiario) {
      await controller.carregarJogoDiario();
    }
    if (mounted) setState(() => _isLoading = false);
  }
  
  void _mostrarDialogoDesistir(BuildContext context) {
    final controller = context.read<JogoController>();
    if (controller.jogoTerminou) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desistir?'),
        content: const Text('Tem a certeza de que quer desistir? A palavra será revelada.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            child: const Text('Desistir'),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              controller.desistir();
              _mostrarDialogoFimDeJogo(controller);
            },
          ),
        ],
      ),
    );
  }

  void _showErrorToast(String message) {
    _errorTimer?.cancel();
    setState(() => _errorMessage = message);
    _errorTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _errorMessage = null);
    });
  }
  
  void _onEnterTapped() {
    final controller = context.read<JogoController>();
    if (controller.jogoTerminou) return;
    final resultado = controller.submeterPalpite();
    if (resultado != null) _showErrorToast(resultado);
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
        appBar: AppBar(title: Text(context.read<JogoController>().isModoDiario ? 'PALAVRA DO DIA' : 'PRATICAR')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    final controller = context.watch<JogoController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isModoDiario ? 'PALAVRA DO DIA' : 'Modo Treinamento'),
        actions: [
          if (!controller.jogoTerminou)
            IconButton(
              icon: const Icon(Icons.flag_outlined),
              onPressed: () => _mostrarDialogoDesistir(context),
              tooltip: 'Desistir',
            ),
          // CORREÇÃO: Botão de reiniciar removido para simplificar a UI
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _errorMessage == null
                  ? const SizedBox.shrink()
                  : Material(
                      elevation: 4,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Theme.of(context).colorScheme.onError, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}