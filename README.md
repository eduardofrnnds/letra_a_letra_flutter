Letra a Letra

Um elegante e viciante jogo de adivinhar palavras, inspirado em sucessos como Wordle e Termo, construído com Flutter. Desafie a sua mente todos os dias com uma nova palavra ou pratique sem limites no modo de treinamento.

✨ Funcionalidades
O "Letra a Letra" foi desenhado com uma interface limpa e uma experiência de utilizador focada.

Modo Diário: Um único desafio por dia com uma palavra sincronizada para todos os jogadores. O seu progresso fica guardado, impedindo que jogue mais de uma vez.

Modo Treinamento: Jogue quantas vezes quiser com palavras aleatórias para aprimorar as suas habilidades.

Persistência Local: O seu jogo diário é guardado. Se fechar a aplicação, pode voltar mais tarde no mesmo dia e continuar de onde parou ou ver o seu resultado final.

Feedback Visual Claro: O sistema de cores clássico (verde, amarelo e cinzento) indica o quão perto está de acertar a palavra.

Teclado Inteligente: O teclado virtual atualiza as suas cores para o ajudar a eliminar letras e a pensar na próxima jogada.

Suporte a Acentos: O jogo valida palavras com e sem acentos de forma inteligente, mas exibe sempre a forma ortográfica correta.

Design Responsivo com Tema Escuro/Claro: Uma interface moderna que se adapta ao seu dispositivo e às suas preferências de tema.

🛠️ Tecnologias Utilizadas
Este projeto foi construído utilizando tecnologias modernas para criar uma experiência fluida e de alta qualidade:

Flutter: Framework principal para a construção da interface de utilizador multiplataforma.

Dart: Linguagem de programação base do Flutter.

shared_preferences: Para persistência de dados locais, guardando o estado do jogo diário.

google_fonts: Para uma tipografia elegante e legível.

Arquitetura Limpa: O código foi organizado separando a UI (Páginas e Widgets), a lógica de negócio (Controllers) e os dados (Repositório).


📁 Estrutura de Pastas
O código fonte está organizado da seguinte forma para facilitar a manutenção e escalabilidade:

lib/
├── config/
│   └── theme/
│       └── app_theme.dart   # Definição dos temas claro e escuro
├── controllers/
│   └── jogo_controller.dart # Lógica principal e estado do jogo
├── data/
│   └── word_repository.dart # Carregamento das palavras do JSON
├── models/
│   └── estado_letra.dart    # Enum para o estado das letras
├── pages/
│   ├── game_page.dart       # Tela principal do jogo
│   └── home_page.dart       # Tela inicial
├── utils/
│   └── string_normalizer.dart # Função para remover acentos
├── widgets/
│   ├── grade_jogo.dart      # Widget da grelha de letras
│   └── teclado_virtual.dart # Widget do teclado
├── app.dart                 # Configuração do MaterialApp
└── main.dart                # Ponto de entrada da aplicação

👤 Autor
Eduardo Fernandes

GitHub: @eduardofrnnds

📜 Licença
Este projeto está sob a licença MIT. Veja o ficheiro LICENSE para mais detalhes.
