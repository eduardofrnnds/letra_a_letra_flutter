import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../utils/string_normalizer.dart'; 


List<String> palavrasOriginais = [];

List<String> palavrasNormalizadas = [];

Future<void> carregarPalavras() async {
  try {
    final String jsonString = await rootBundle.loadString('assets/palavras.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    
    palavrasOriginais.clear();
    palavrasNormalizadas.clear();

    for (var item in jsonList) {
      final palavraOriginal = item.toString().trim().toUpperCase();
      if (palavraOriginal.isNotEmpty) {
        palavrasOriginais.add(palavraOriginal);
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
