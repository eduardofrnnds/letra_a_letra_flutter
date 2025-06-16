import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/word_repository.dart';
import '../models/estado_letra.dart';
import '../utils/string_normalizer.dart';

class JogoController extends ChangeNotifier {
  // --- Variáveis de Estado e Constantes ---
  static const _keyData = 'ultima_data_diario';
  static const _keyPalavra = 'palavra_diario';
  static const _keyTentativas = 'tentativas_diario';
  static const _keyVenceu = 'venceu_diario';

  late String palavraSecreta;
  late String palavraSecretaOriginal;
  final bool isModoDiario;
  final int maxTentativas = 6;
  final int tamanhoPalavra = 5;
  int tentativaAtual = 0;
  List<List<String>> grade = [];
  List<List<EstadoLetra>> estadosGrade = [];
  Map<String, EstadoLetra> estadosTeclado = {};
  bool jogoTerminou = false;
  bool venceu = false;
  bool _jogoJaFoiJogadoHoje = false;
  int colunaSelecionada = 0;
  
  bool get jaJogouHoje => _jogoJaFoiJogadoHoje;

  JogoController({required this.isModoDiario}) {
    _resetarEstadoBase();
  }

  // --- Lógica de Inicialização ---
  void iniciarJogoTreino() {
    _iniciarNovoJogo(ehDiario: false);
    notifyListeners();
  }
  
  Future<void> carregarJogoDiario() async {
    final prefs = await SharedPreferences.getInstance();
    final hoje = _getDataFormatada(DateTime.now());
    final ultimaDataSalva = prefs.getString(_keyData);
    if (hoje == ultimaDataSalva) {
      _jogoJaFoiJogadoHoje = true;
      await _reconstruirJogoSalvo(prefs);
    } else {
      _jogoJaFoiJogadoHoje = false;
      _iniciarNovoJogo(ehDiario: true);
    }
    notifyListeners();
  }
  
  void desistir() {
    if (jogoTerminou) return;
    grade[tentativaAtual] = palavraSecretaOriginal.split('');
    estadosGrade[tentativaAtual] = List.filled(tamanhoPalavra, EstadoLetra.errado);
    jogoTerminou = true;
    venceu = false;
    tentativaAtual = maxTentativas;
    if (isModoDiario) _salvarEstadoDiario();
    notifyListeners();
  }

  // --- Lógica do Jogo (Interação do Utilizador) ---
  void selecionarCelula(int coluna) { if (jogoTerminou || tentativaAtual >= maxTentativas) return; colunaSelecionada = coluna; notifyListeners(); }
  void digitarLetra(String letra) { if (jogoTerminou || colunaSelecionada >= tamanhoPalavra) return; grade[tentativaAtual][colunaSelecionada] = letra.toUpperCase(); int proximaPosicao = -1; for (int i = colunaSelecionada + 1; i < tamanhoPalavra; i++) { if (grade[tentativaAtual][i] == '') { proximaPosicao = i; break; } } if (proximaPosicao != -1) { colunaSelecionada = proximaPosicao; } else { for (int i = 0; i < colunaSelecionada; i++) { if (grade[tentativaAtual][i] == '') { proximaPosicao = i; break; } } colunaSelecionada = (proximaPosicao != -1) ? proximaPosicao : tamanhoPalavra; } notifyListeners(); }

  // CORREÇÃO #1: Lógica de apagar refeita para agir como um "backspace" clássico.
  void apagarLetra() {
    if (jogoTerminou) return;

    // Encontra a última célula preenchida na linha atual
    int ultimoIndicePreenchido = -1;
    for (int i = tamanhoPalavra - 1; i >= 0; i--) {
        if (grade[tentativaAtual][i].isNotEmpty) {
            ultimoIndicePreenchido = i;
            break;
        }
    }

    // Se houver uma letra para apagar, apaga-a e move o cursor para essa posição.
    if (ultimoIndicePreenchido != -1) {
        grade[tentativaAtual][ultimoIndicePreenchido] = '';
        colunaSelecionada = ultimoIndicePreenchido;
    }
    
    notifyListeners();
  }

  String? submeterPalpite({bool salvarEstado = true}) {
    if (jogoTerminou) return null;
    final palpiteAtual = grade[tentativaAtual].join();
    if (palpiteAtual.length != tamanhoPalavra) return 'A palavra deve ter $tamanhoPalavra letras.';
    final palpiteNormalizado = normalizeString(palpiteAtual.toUpperCase());
    if (!palavrasNormalizadas.contains(palpiteNormalizado)) return 'Palavra não existe na nossa lista.';
    
    final novosEstados = _avaliarPalpite(palpiteNormalizado);
    estadosGrade[tentativaAtual] = novosEstados;
    _atualizarEstadoTeclado(palpiteNormalizado, novosEstados);

    if (palpiteNormalizado == palavraSecreta) {
      venceu = true;
      jogoTerminou = true;
      grade[tentativaAtual] = palavraSecretaOriginal.split('');
    } else if (tentativaAtual == maxTentativas - 1) {
      jogoTerminou = true;
    }

    if (jogoTerminou && isModoDiario && salvarEstado) _salvarEstadoDiario();
    
    tentativaAtual++;
    colunaSelecionada = 0;
    notifyListeners();
    return null;
  }
  
  // --- Métodos Privados Auxiliares ---
  List<EstadoLetra> _avaliarPalpite(String palpite) { final letrasPalpite = palpite.split(''); final letrasSecretas = palavraSecreta.split(''); final estados = List<EstadoLetra>.filled(tamanhoPalavra, EstadoLetra.inicial); final tempLetrasSecretas = List.from(letrasSecretas); for (int i = 0; i < tamanhoPalavra; i++) { if (letrasPalpite[i] == tempLetrasSecretas[i]) { estados[i] = EstadoLetra.correto; tempLetrasSecretas[i] = ''; } } for (int i = 0; i < tamanhoPalavra; i++) { if (estados[i] == EstadoLetra.inicial) { final indexNaSecreta = tempLetrasSecretas.indexOf(letrasPalpite[i]); if (indexNaSecreta != -1) { estados[i] = EstadoLetra.posicaoErrada; tempLetrasSecretas[indexNaSecreta] = ''; } else { estados[i] = EstadoLetra.errado; } } } _diferenciarRepeticoes(estados, letrasPalpite); return estados; }
  void _diferenciarRepeticoes(List<EstadoLetra> estados, List<String> palpite) { final acertosVerdes = <String>{}; final acertosLaranjas = <String>{}; for(int i = 0; i < tamanhoPalavra; i++) { final letra = palpite[i]; if (estados[i] == EstadoLetra.correto) { if (acertosVerdes.contains(letra)) { estados[i] = EstadoLetra.corretoRepetido; } else { acertosVerdes.add(letra); } } else if (estados[i] == EstadoLetra.posicaoErrada) { if (acertosVerdes.contains(letra) || acertosLaranjas.contains(letra)) { estados[i] = EstadoLetra.posicaoErradaRepetida; } else { acertosLaranjas.add(letra); } } } }
  void _atualizarEstadoTeclado(String palpite, List<EstadoLetra> estados) { for (int i = 0; i < palpite.length; i++) { final letra = palpite[i]; final estadoAtual = estadosTeclado[letra]; final novoEstado = estados[i]; if (estadoAtual == null || novoEstado.index > estadoAtual.index) { estadosTeclado[letra] = novoEstado; } } }
  void _iniciarNovoJogo({required bool ehDiario}) { _setPalavraSecreta(ehDiario: ehDiario); _resetarEstadoBase(ehDiario: ehDiario); jogoTerminou = false; venceu = false; }
  
  void _resetarEstadoBase({bool ehDiario = false}) {
    tentativaAtual = 0;
    colunaSelecionada = 0;
    grade = List.generate(maxTentativas, (_) => List.filled(tamanhoPalavra, ""));
    estadosGrade = List.generate(maxTentativas, (_) => List.filled(tamanhoPalavra, EstadoLetra.inicial));
    
    // CORREÇÃO #2: Limpa o teclado apenas se for um novo jogo diário.
    // No modo treino, as cores persistem para ajudar o jogador.
    if (ehDiario) {
      estadosTeclado = {};
    }
  }
  
  void _setPalavraSecreta({required bool ehDiario}) { if (palavrasOriginais.isEmpty) { palavraSecretaOriginal = "ERRO"; palavraSecreta = "ERRO"; return; } int index; if (ehDiario) { final diaDoAno = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays; index = diaDoAno % palavrasOriginais.length; } else { index = Random().nextInt(palavrasOriginais.length); } palavraSecretaOriginal = palavrasOriginais[index]; palavraSecreta = palavrasNormalizadas[index]; }
  String _getDataFormatada(DateTime data) { return "${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}"; }
  Future<void> _reconstruirJogoSalvo(SharedPreferences prefs) async { palavraSecretaOriginal = prefs.getString(_keyPalavra) ?? "ERRO"; palavraSecreta = normalizeString(palavraSecretaOriginal); final tentativasSalvas = prefs.getStringList(_keyTentativas) ?? []; venceu = prefs.getBool(_keyVenceu) ?? false; _resetarEstadoBase(ehDiario: true); for (final palpite in tentativasSalvas) { grade[tentativaAtual] = palpite.split(''); submeterPalpite(salvarEstado: false); } jogoTerminou = true; }
  Future<void> _salvarEstadoDiario() async { final prefs = await SharedPreferences.getInstance(); final hoje = _getDataFormatada(DateTime.now()); List<String> tentativasFeitas = []; for (int i = 0; i < tentativaAtual; i++) { tentativasFeitas.add(grade[i].join()); } await prefs.setString(_keyData, hoje); await prefs.setString(_keyPalavra, palavraSecretaOriginal); await prefs.setStringList(_keyTentativas, tentativasFeitas); await prefs.setBool(_keyVenceu, venceu); }
}
