import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/estado_letra.dart';

// Widget para a grade completa do jogo
class GradeJogo extends StatelessWidget {
  final List<List<String>> grade;
  final List<List<EstadoLetra>> estadosGrade;
  final int tentativaAtual;

  const GradeJogo({
    Key? key,
    required this.grade,
    required this.estadosGrade,
    required this.tentativaAtual,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                final letra = grade[linha][coluna];
                final estado = estadosGrade[linha][coluna];
                final foiSubmetida = linha < tentativaAtual;

                return CaixaLetra(
                  letra: letra,
                  estado: estado,
                  foiSubmetida: foiSubmetida,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// Animação de Flip na CaixaLetra
class CaixaLetra extends StatefulWidget {
  final String letra;
  final EstadoLetra estado;
  final bool foiSubmetida;

  const CaixaLetra({
    Key? key,
    required this.letra,
    required this.estado,
    required this.foiSubmetida,
  }) : super(key: key);

  @override
  State<CaixaLetra> createState() => _CaixaLetraState();
}

class _CaixaLetraState extends State<CaixaLetra> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(CaixaLetra oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Inicia a animação quando a caixa é submetida
    if (widget.foiSubmetida && !oldWidget.foiSubmetida) {
      _controller.forward();
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

        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(angulo);

        final Color corFundo;
        final Color corBorda;

        if (isFlipped) {
          switch (widget.estado) {
            case EstadoLetra.correto:
              corFundo = colors.tertiary;
              corBorda = colors.tertiary;
              break;
            case EstadoLetra.posicaoErrada:
              corFundo = colors.secondary;
              corBorda = colors.secondary;
              break;
            case EstadoLetra.errado:
              corFundo = colors.outline;
              corBorda = colors.outline;
              break;
            default:
              corFundo = Colors.transparent;
              corBorda = colors.outlineVariant;
          }
        } else {
          corFundo = Colors.transparent;
          corBorda = colors.outlineVariant;
        }

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              color: corFundo,
              border: Border.all(
                color: corBorda,
                width: widget.letra.isNotEmpty && !isFlipped ? 2.5 : 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Transform(
                transform: Matrix4.identity()..rotateX(isFlipped ? math.pi : 0),
                alignment: Alignment.center,
                child: Text(
                  widget.letra.toUpperCase(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isFlipped ? colors.onPrimary : colors.onSurface,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
