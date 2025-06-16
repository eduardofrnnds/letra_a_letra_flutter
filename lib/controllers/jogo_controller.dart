import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/word_repository.dart';
import '../models/estado_letra.dart';
import '../utils/string_normalizer.dart';

class JogoController extends ChangeNotifier {
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
  String palpiteAtual = "";
  Map<String, EstadoLetra> estadosTeclado = {};
  bool jogoTerminou = false;
  bool venceu = false;
  bool _jogoJaFoiJogadoHoje = false;

  bool get jaJogouHoje => _jogoJaFoiJogadoHoje;

  JogoController({required this.isModoDiario});

  Future<void> inicializar() async {
    if (isModoDiario) {
      await _carregarOuIniciarJogoDiario();
    } else {
      iniciarJogoTreino();
    }
  }

  Future<void> _carregarOuIniciarJogoDiario() async {
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

  Future<void> _reconstruirJogoSalvo(SharedPreferences prefs) async {
    palavraSecretaOriginal = prefs.getString(_keyPalavra) ?? "ERRO";
    palavraSecreta = normalizeString(palavraSecretaOriginal);
    final tentativasSalvas = prefs.getStringList(_keyTentativas) ?? [];
    venceu = prefs.getBool(_keyVenceu) ?? false;
    
    _resetarEstadoBase();


    for (final palpite in tentativasSalvas) {
      palpiteAtual = palpite;
      _atualizarGradeComPalpite();
      submeterPalpite(salvarEstado: false);
    }
    
    jogoTerminou = true;
  }


  Future<void> _salvarEstadoDiario() async {
    final prefs = await SharedPreferences.getInstance();
    final hoje = _getDataFormatada(DateTime.now());

 
    List<String> tentativasFeitas = [];
    for (int i = 0; i < tentativaAtual; i++) {
      tentativasFeitas.add(grade[i].join());
    }

    await prefs.setString(_keyData, hoje);
    await prefs.setString(_keyPalavra, palavraSecretaOriginal);
    await prefs.setStringList(_keyTentativas, tentativasFeitas);
    await prefs.setBool(_keyVenceu, venceu);
  }
  
  void iniciarJogoTreino() {
    _iniciarNovoJogo(ehDiario: false);
  }

  void _iniciarNovoJogo({required bool ehDiario}) {
    _setPalavraSecreta(ehDiario: ehDiario);
    _resetarEstadoBase();
    jogoTerminou = false;
    venceu = false;
    notifyListeners();
  }

  void _resetarEstadoBase() {
    tentativaAtual = 0;
    palpiteAtual = "";
    grade = List.generate(maxTentativas, (_) => List.filled(tamanhoPalavra, ""));
    estadosGrade = List.generate(maxTentativas, (_) => List.filled(tamanhoPalavra, EstadoLetra.inicial));
    estadosTeclado.clear();
  }

  String _getDataFormatada(DateTime data) {
    return "${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}";
  }
  
  void _setPalavraSecreta({required bool ehDiario}) {
    if (palavrasOriginais.isEmpty) {
      palavraSecretaOriginal = "ERRO";
      palavraSecreta = "ERRO";
      return;
    }

    int index;
    if (ehDiario) {
      final diaDoAno = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
      index = diaDoAno % palavrasOriginais.length;
    } else {
      index = Random().nextInt(palavrasOriginais.length);
    }

    palavraSecretaOriginal = palavrasOriginais[index];
    palavraSecreta = palavrasNormalizadas[index];
  }

  String? submeterPalpite({bool salvarEstado = true}) {
    if (jogoTerminou) return null;

    if (palpiteAtual.length != tamanhoPalavra) {
      return 'A palavra deve ter $tamanhoPalavra letras.';
    }
    
    final palpiteNormalizado = normalizeString(palpiteAtual.toUpperCase());

    if (!palavrasNormalizadas.contains(palpiteNormalizado)) {
      return 'Palavra não existe na nossa lista.';
    }
    
    final novosEstados = List<EstadoLetra>.filled(tamanhoPalavra, EstadoLetra.errado);
    List<String> letrasSecretas = palavraSecreta.split('');
    List<String> letrasPalpite = palpiteNormalizado.split('');
    
    for (int i = 0; i < tamanhoPalavra; i++) {
      if (letrasPalpite[i] == letrasSecretas[i]) {
        novosEstados[i] = EstadoLetra.correto;
        letrasSecretas[i] = ''; 
      }
    }

    for (int i = 0; i < tamanhoPalavra; i++) {
      if (novosEstados[i] != EstadoLetra.correto) {
        if(letrasSecretas.contains(letrasPalpite[i])){
          novosEstados[i] = EstadoLetra.posicaoErrada;
          letrasSecretas[letrasSecretas.indexOf(letrasPalpite[i])] = '';
        }
      }
    }
    
    estadosGrade[tentativaAtual] = novosEstados;
    _atualizarEstadoTeclado(palpiteNormalizado, novosEstados);

    if (palpiteNormalizado == palavraSecreta) {
      venceu = true;
      jogoTerminou = true;
      
  
      final letrasOriginais = palavraSecretaOriginal.split('');
      for (int i = 0; i < tamanhoPalavra; i++) {
        grade[tentativaAtual][i] = letrasOriginais[i];
      }
    } else if (tentativaAtual == maxTentativas - 1) {
      jogoTerminou = true;
    }

    if (jogoTerminou && isModoDiario && salvarEstado) {
      _salvarEstadoDiario();
    }
    
    tentativaAtual++;
    palpiteAtual = "";
    notifyListeners();
    return null; 
  }
  
  void digitarLetra(String letra) {
    if (jogoTerminou || palpiteAtual.length >= tamanhoPalavra) return;
    palpiteAtual += letra;
    _atualizarGradeComPalpite();
    notifyListeners();
  }

  void apagarLetra() {
    if (jogoTerminou || palpiteAtual.isEmpty) return;
    palpiteAtual = palpiteAtual.substring(0, palpiteAtual.length - 1);
    _atualizarGradeComPalpite();
    notifyListeners();
  }

  void _atualizarGradeComPalpite() {
    final letras = palpiteAtual.split('');
    for (int i = 0; i < tamanhoPalavra; i++) {
      grade[tentativaAtual][i] = (i < letras.length) ? letras[i] : "";
    }
  }

  void _atualizarEstadoTeclado(String palpite, List<EstadoLetra> estados) {
    for (int i = 0; i < palpite.length; i++) {
      final letra = palpite[i];
      final estadoAtual = estadosTeclado[letra];
      final novoEstado = estados[i];

      if (estadoAtual == null || novoEstado.index > estadoAtual.index) {
        estadosTeclado[letra] = novoEstado;
      }
    }
  }

  void reiniciarJogoTreino() {
    _iniciarNovoJogo(ehDiario: false);
  }
}