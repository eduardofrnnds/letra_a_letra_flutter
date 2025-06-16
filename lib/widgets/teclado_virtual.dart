import 'package:flutter/material.dart';
import '../models/estado_letra.dart';

class TecladoVirtual extends StatelessWidget {
  final void Function(String) onKeyTapped;
  final VoidCallback onBackspaceTapped;
  final VoidCallback onEnterTapped;
  final Map<String, EstadoLetra> estadosTeclado;
  
  const TecladoVirtual({
    super.key,
    required this.onKeyTapped,
    required this.onBackspaceTapped,
    required this.onEnterTapped,
    required this.estadosTeclado,
  });

  @override
  Widget build(BuildContext context) {
    const layoutTeclado = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: Column(
        children: layoutTeclado.map((linha) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: linha.map((key) {
              if (key == 'ENTER') {
                return BotaoTeclado.special(onTap: onEnterTapped, label: 'ENTER');
              }
              if (key == '⌫') {
                return BotaoTeclado.special(onTap: onBackspaceTapped, icon: Icons.backspace_outlined);
              }

              final estado = estadosTeclado[key] ?? EstadoLetra.inicial;

              if (estado == EstadoLetra.errado) {
                return const Expanded(flex: 2, child: SizedBox());
              }

              return BotaoTeclado(
                onTap: (letra) => onKeyTapped(letra),
                letra: key,
                estado: estado,
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

class BotaoTeclado extends StatelessWidget {
  final int flex;
  final String? letra;
  final EstadoLetra? estado;
  final String? label;
  final IconData? icon;
  final Function onTap;

  const BotaoTeclado({ super.key, required this.onTap, required this.letra, this.estado = EstadoLetra.inicial, this.flex = 2,}) : label = null, icon = null;
  const BotaoTeclado.special({ super.key, required this.onTap, this.label, this.icon, this.flex = 3,}) : letra = null, estado = null;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final Color corFundo;
    final Color corTexto;

    if (letra != null) {
      switch (estado) {
        case EstadoLetra.correto:
        case EstadoLetra.corretoRepetido:
          corFundo = colors.tertiary;
          corTexto = colors.onTertiary;
          break;
        case EstadoLetra.posicaoErrada:
        case EstadoLetra.posicaoErradaRepetida: // NOVO
          corFundo = colors.secondary;
          corTexto = colors.onSecondary;
          break;
        default: 
          corFundo = colors.surfaceContainerHighest;
          corTexto = colors.onSurfaceVariant;
      }
    } else { 
      corFundo = colors.surfaceContainerHighest;
      corTexto = colors.onSurfaceVariant;
    }

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Material(
          color: corFundo,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () {
              if (letra != null) {
                (onTap as void Function(String))(letra!);
              } else {
                (onTap as void Function())();
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 55,
              alignment: Alignment.center,
              child: _buildChild(corTexto),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildChild(Color color) {
    if (label != null) return Text(label!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color));
    if (icon != null) return Icon(icon, size: 24, color: color);
    return Text(letra!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color));
  }
}