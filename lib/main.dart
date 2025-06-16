import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'controllers/theme_controller.dart';
import 'data/word_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await carregarPalavras();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const WordleApp(),
    ),
  );
}
