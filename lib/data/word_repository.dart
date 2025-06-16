import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../utils/string_normalizer.dart'; // Importa o nosso normalizador

// Armazena as palavras originais (com acentos)
List<String> palavrasOriginais = [];

// Armazena as palavras normalizadas para a lógica do jogo (sem acentos)
List<String> palavrasNormalizadas = [];

Future<void> carregarPalavras() async {
  try {
    final String jsonString = await rootBundle.loadString('assets/palavras.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    
    // Limpa as listas antes de carregar para evitar duplicados
    palavrasOriginais.clear();
    palavrasNormalizadas.clear();

    for (var item in jsonList) {
      final palavraOriginal = item.toString().trim().toUpperCase();
      if (palavraOriginal.isNotEmpty) {
        palavrasOriginais.add(palavraOriginal);
        // Adiciona a versão sem acentos à lista de lógica
        palavrasNormalizadas.add(normalizeString(palavraOriginal));
      }
    }

    print('Palavras carregadas com sucesso: ${palavrasOriginais.length} palavras.');

  } catch (e) {
    print('Erro ao carregar o arquivo de palavras: $e');
    palavrasOriginais = ['ERRO'];
    palavrasNormalizadas = ['ERRO'];
  }
}
