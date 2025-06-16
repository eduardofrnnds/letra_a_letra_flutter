import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../config/theme/app_theme.dart';
import '../models/estado_letra.dart';
import '../controllers/jogo_controller.dart';
import 'package:provider/provider.dart';

class GradeJogo extends StatelessWidget {
  const GradeJogo({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<JogoController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        double cellSize = (maxWidth - 20) / 5;
        final double maxHeight = constraints.maxHeight;
        double maxCellHeight = (maxHeight - 25) / 6;
        if (cellSize > maxCellHeight) cellSize = maxCellHeight;

        return Center(
          child: SizedBox(
            width: cellSize * 5 + 20,
            height: cellSize * 6 + 25,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 30,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, mainAxisSpacing: 5, crossAxisSpacing: 5,
              ),
              itemBuilder: (context, index) {
                final linha = index ~/ 5;
                final coluna = index % 5;
                final isLinhaAtual = linha == controller.tentativaAtual;
                
                String letra = '';
                EstadoLetra estado = EstadoLetra.inicial;

                if (isLinhaAtual) {
                  letra = controller.palpiteAtualList[coluna];
                } else if (controller.tentativas[linha] != null) {
                  letra = controller.tentativas[linha]!.palavra.split('')[coluna];
                  estado = controller.tentativas[linha]!.estados[coluna];
                }

                return GestureDetector(
                  onTap: () {
                    if (isLinhaAtual) {
                      context.read<JogoController>().selecionarCelula(coluna);
                    }
                  },
                  child: CaixaLetra(
                    letra: letra,
                    estado: estado,
                    foiSubmetida: linha < controller.tentativaAtual,
                    isSelecionada: isLinhaAtual && coluna == controller.colunaSelecionada,
                    animationDelay: Duration(milliseconds: coluna * 100),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// O widget CaixaLetra permanece o mesmo, sem alterações necessárias.
class CaixaLetra extends StatefulWidget {
  final String letra;
  final EstadoLetra estado;
  final bool foiSubmetida;
  final bool isSelecionada;
  final Duration animationDelay;

  const CaixaLetra({
    super.key,
    required this.letra,
    required this.estado,
    required this.foiSubmetida,
    required this.isSelecionada,
    this.animationDelay = Duration.zero,
  });

  @override
  State<CaixaLetra> createState() => _CaixaLetraState();
}

class _CaixaLetraState extends State<CaixaLetra> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this,);
  }

  @override
  void didUpdateWidget(CaixaLetra oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.foiSubmetida && !oldWidget.foiSubmetida) {
      Future.delayed(widget.animationDelay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angulo = _controller.value * math.pi;
        final isFlipped = _controller.value >= 0.5;
        final transform = Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(angulo);

        final Color corFundo;
        Color corBorda;
        final Color corTexto;

        if (isFlipped) {
          switch (widget.estado) {
            case EstadoLetra.correto:
              corFundo = AppColors.success;
              break;
            case EstadoLetra.corretoRepetido:
              corFundo = AppColors.repeatedSuccess;
              break;
            case EstadoLetra.posicaoErrada:
              corFundo = AppColors.warning;
              break;
            case EstadoLetra.posicaoErradaRepetida:
              corFundo = AppColors.repeatedWarning;
              break;
            default:
              corFundo = AppColors.neutral;
          }
          corBorda = corFundo;
          corTexto = Colors.white;
        } else {
          corFundo = Colors.transparent;
          corBorda = colors.outline;
          corTexto = colors.onSurface;
        }

        if (widget.isSelecionada) corBorda = colors.secondary;

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: corFundo,
              border: Border.all(color: corBorda, width: widget.isSelecionada ? 3.0 : 2.0,),
              borderRadius: BorderRadius.circular(8),
              boxShadow: widget.isSelecionada ? [BoxShadow(color: colors.secondary.withAlpha(128), blurRadius: 5, spreadRadius: 1,)] : [],
            ),
            child: Center(
              child: Transform(
                transform: Matrix4.identity()..rotateX(isFlipped ? math.pi : 0),
                alignment: Alignment.center,
                child: Text(widget.letra.toUpperCase(), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: corTexto),),
              ),
            ),
          ),
        );
      },
    );
  }
}
