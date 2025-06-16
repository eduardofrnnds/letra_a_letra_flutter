enum EstadoLetra {
  inicial,        // Estado padrão, antes do palpite
  correto,        // Letra certa, na posição certa (Verde)
  corretoRepetido,// Letra repetida certa, na posição certa (Verde Escuro)
  posicaoErrada,  // Letra certa, na posição errada (Laranja/Amarelo)
  errado,         // Letra não existe na palavra (Cinza)
}
