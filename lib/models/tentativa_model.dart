import 'estado_letra.dart';

// Representa uma única tentativa (linha) no jogo.
class Tentativa {
  // A palavra que foi submetida.
  final String palavra;
  
  // A lista de estados (cores) para cada letra.
  final List<EstadoLetra> estados;

  Tentativa({required this.palavra, required this.estados});
}
