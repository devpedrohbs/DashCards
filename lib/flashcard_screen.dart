import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importe o Firestore
import 'dart:math'; // Já existente, mas manter explícito

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  bool _isFlipped = false;
  List<QueryDocumentSnapshot> _flashcards = []; // Lista para armazenar os flashcards
  int _currentFlashcardIndex = 0; // Índice do flashcard atual

  @override
  void initState() {
    super.initState();
    // Não precisamos carregar aqui, o StreamBuilder fará isso.
    // Apenas certificamos que o estado inicial está pronto.
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _nextCard() {
    setState(() {
      _isFlipped = false; // Vira o cartão de volta para a pergunta
      if (_flashcards.isNotEmpty) {
        _currentFlashcardIndex = (_currentFlashcardIndex + 1) % _flashcards.length;
      }
    });
  }

  void _previousCard() {
    setState(() {
      _isFlipped = false; // Vira o cartão de volta para a pergunta
      if (_flashcards.isNotEmpty) {
        _currentFlashcardIndex = (_currentFlashcardIndex - 1 + _flashcards.length) % _flashcards.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Recebe os argumentos passados da tela anterior
    final Map<String, String> args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final String userId = args['userId']!; // Obtém o userId
    final String subjectId = args['subjectId']!;
    final String subjectName = args['subjectName']!;
    final String topicId = args['topicId']!;
    final String topicName = args['topicName']!;

    return Scaffold(
      appBar: AppBar(
        title: Text(topicName.toUpperCase()),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // Navega para a tela de criação de flashcards, passando os IDs (incluindo userId)
              Navigator.pushNamed(
                context,
                '/create_dashcard',
                arguments: {
                  'userId': userId, // Adiciona o userId
                  'subjectId': subjectId,
                  'subjectName': subjectName,
                  'topicId': topicId,
                  'topicName': topicName,
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>( // StreamBuilder para os flashcards
        stream: FirebaseFirestore.instance
            .collection('users') // Adiciona a coleção 'users'
            .doc(userId)         // E o documento do usuário
            .collection('subjects')
            .doc(subjectId)
            .collection('topics')
            .doc(topicId)
            .collection('flashcards')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar flashcards: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Nenhum flashcard encontrado neste tópico.',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/create_dashcard',
                        arguments: {
                          'userId': userId, // Adiciona o userId
                          'subjectId': subjectId,
                          'subjectName': subjectName,
                          'topicId': topicId,
                          'topicName': topicName,
                        },
                      );
                    },
                    child: const Text('CRIAR SEU PRIMEIRO FLASHCARD'),
                  ),
                ],
              ),
            );
          }

          _flashcards = snapshot.data!.docs;
          // Garante que o índice atual esteja dentro dos limites da lista
          if (_currentFlashcardIndex >= _flashcards.length) {
            _currentFlashcardIndex = 0; // Reinicia se o último flashcard for removido ou se a lista for vazia
          }

          final currentFlashcardData = _flashcards[_currentFlashcardIndex].data() as Map<String, dynamic>;
          final String question = currentFlashcardData['question'] as String? ?? 'N/A';
          final String answer = currentFlashcardData['answer'] as String? ?? 'N/A';

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: _flipCard,
                    onVerticalDragEnd: (details) => _flipCard(),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
                        return AnimatedBuilder(
                          animation: rotateAnim,
                          child: child,
                          builder: (context, child) {
                            final isUnder = (ValueKey(_isFlipped) != child!.key);
                            var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
                            tilt = isUnder ? -tilt : tilt;
                            final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
                            return Transform(
                              transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                              alignment: Alignment.center,
                              child: child,
                            );
                          },
                        );
                      },
                      child: _isFlipped
                          ? _FlashcardContent(
                              key: const ValueKey(true),
                              title: 'RESPOSTA',
                              content: answer, // Conteúdo dinâmico
                              color: Colors.lightGreen.shade100,
                            )
                          : _FlashcardContent(
                              key: const ValueKey(false),
                              title: 'PERGUNTA',
                              content: question, // Conteúdo dinâmico
                              color: Colors.yellow.shade100,
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    _flashcards.isEmpty ? '' : 'Flashcard ${_currentFlashcardIndex + 1} de ${_flashcards.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Toque ou arraste para cima para ver a resposta!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _flashcards.isNotEmpty ? _previousCard : null, // Desabilita se não houver flashcards
                          child: const Text('ANTERIOR'),
                          style: TextButton.styleFrom(
                            backgroundColor: _flashcards.isNotEmpty ? const Color(0xFF2C5D5A) : Colors.grey.withOpacity(0.5), // Cor para desabilitado
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextButton(
                          onPressed: _flashcards.isNotEmpty ? _nextCard : null, // Desabilita se não houver flashcards
                          child: const Text('PRÓXIMO'),
                          style: TextButton.styleFrom(
                            backgroundColor: _flashcards.isNotEmpty ? const Color(0xFF2C5D5A) : Colors.grey.withOpacity(0.5), // Cor para desabilitado
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FlashcardContent extends StatelessWidget {
  final String title;
  final String content;
  final Color color;

  const _FlashcardContent({
    super.key,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.5,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          Center(
            child: SingleChildScrollView( // Adicionado para permitir scroll em conteúdo longo
              child: Text(
                content,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
