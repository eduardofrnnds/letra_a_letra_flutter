import 'package:flutter/material.dart';
import 'app.dart';
import 'data/word_repository.dart'; // Importa nosso novo carregador de palavras

Future<void> main() async {
  // Garante que os bindings do Flutter sejam inicializados antes de qualquer operação assíncrona.
  // É obrigatório ao usar 'await' na função main.
  WidgetsFlutterBinding.ensureInitialized();

  // Espera o carregamento do nosso arquivo JSON antes de iniciar o app.
  await carregarPalavras();

  // Inicia a execução do aplicativo com o widget WordleApp.
  runApp(const WordleApp());
}
