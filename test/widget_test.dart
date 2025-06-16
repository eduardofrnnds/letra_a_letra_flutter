import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:acerta_palavra_app/app.dart';
import 'package:acerta_palavra_app/controllers/theme_controller.dart';

void main() {
  testWidgets('App loads and displays the home page', (WidgetTester tester) async {
    // Constrói a nossa aplicação com os providers necessários.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeController(),
        child: const WordleApp(),
      ),
    );

    // Verifica se o título "Letra a Letra" está na tela.
    expect(find.text('Letra a Letra'), findsOneWidget);
  });
}
