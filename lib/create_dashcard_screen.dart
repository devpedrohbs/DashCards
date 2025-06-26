import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importe o Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Importe o Firebase Auth

class CreateDashcardScreen extends StatefulWidget {
  const CreateDashcardScreen({super.key});

  @override
  State<CreateDashcardScreen> createState() => _CreateDashcardScreenState();
}

class _CreateDashcardScreenState extends State<CreateDashcardScreen> {
  String? _currentUserId; // Novo: para armazenar o userId
  String? _selectedSubjectId;
  String? _selectedSubjectName;
  String? _selectedTopicId;
  String? _selectedTopicName;

  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  // Map para armazenar os tópicos de uma matéria selecionada
  // Usado para reconstruir a lista de tópicos quando a matéria muda
  List<Map<String, String>> _availableTopics = [];

  @override
  void initState() {
    super.initState();
    // Inicializa os dropdowns se argumentos forem passados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadArguments();
    });
  }

  void _loadArguments() {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Map<String, String>) {
      setState(() {
        _currentUserId = args['userId']; // Obtém o userId dos argumentos
        _selectedSubjectId = args['subjectId'];
        _selectedSubjectName = args['subjectName'];
        _selectedTopicId = args['topicId'];
        _selectedTopicName = args['topicName'];
      });
      // Se um subjectId for preenchido, carregamos seus tópicos
      if (_selectedSubjectId != null && _currentUserId != null) {
        _fetchTopicsForSubject(_currentUserId!, _selectedSubjectId!);
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  // Função para buscar tópicos de uma matéria específica
  Future<void> _fetchTopicsForSubject(String userId, String subjectId) async { // Agora recebe userId
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users') // Adiciona a coleção 'users'
          .doc(userId)         // E o documento do usuário
          .collection('subjects')
          .doc(subjectId)
          .collection('topics')
          .get();

      setState(() {
        _availableTopics = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['name'] as String,
          };
        }).toList();
      });
    } catch (e) {
      print('Erro ao carregar tópicos para a matéria: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar tópicos: $e')),
      );
    }
  }

  void _onSubjectChanged(String? newSubjectId) {
    if (newSubjectId != null && _currentUserId != null) { // Verifica se userId não é nulo
      setState(() {
        _selectedSubjectId = newSubjectId;
        _selectedSubjectName = null; // Limpa o nome para buscar o novo
        _selectedTopicId = null; // Reseta o tópico ao mudar a matéria
        _selectedTopicName = null;

        // Encontra o nome da matéria pelo ID para exibição
        FirebaseFirestore.instance.collection('users').doc(_currentUserId).collection('subjects').doc(newSubjectId).get().then((docSnapshot) {
          if (docSnapshot.exists) {
            setState(() {
              _selectedSubjectName = docSnapshot['name'] as String;
            });
          }
        });
      });
      _fetchTopicsForSubject(_currentUserId!, newSubjectId); // Carrega os tópicos da nova matéria
    }
  }

  void _onTopicChanged(String? newTopicId) {
    if (newTopicId != null) {
      setState(() {
        _selectedTopicId = newTopicId;
        _selectedTopicName = _availableTopics.firstWhere((topic) => topic['id'] == newTopicId)['name'];
      });
    }
  }

  // Função para salvar o flashcard no Firestore
  Future<void> _saveFlashcard() async {
    if (_currentUserId == null || _selectedSubjectId == null || _selectedTopicId == null || _questionController.text.isEmpty || _answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos e selecione matéria e tema.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('subjects')
          .doc(_selectedSubjectId)
          .collection('topics')
          .doc(_selectedTopicId)
          .collection('flashcards')
          .add({
        'question': _questionController.text.trim(),
        'answer': _answerController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flashcard salvo com sucesso!')),
      );
      Navigator.of(context).pop(); // Volta para a tela anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar flashcard: $e')),
      );
      print('Erro ao adicionar flashcard ao Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // É importante que _currentUserId seja definido antes de construir o StreamBuilder
    // Se o argumento não foi passado (tela acessada diretamente), o usuário logado é pego aqui
    if (_currentUserId == null) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args != null && args is Map<String, String>) {
        _currentUserId = args['userId'];
      }
      // Fallback para caso não venha via argumento (ex: navegação direta)
      // Embora o fluxo atual garanta que ele sempre venha via argumento
      _currentUserId ??= FirebaseAuth.instance.currentUser?.uid;
    }

    // Se _currentUserId ainda for nulo, significa que não há usuário logado.
    if (_currentUserId == null) {
      return const Center(child: Text('Você precisa estar logado para criar flashcards.', style: TextStyle(color: Colors.white)));
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('CRIAR DASHCARD'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Dropdown para selecionar a matéria
            StreamBuilder<QuerySnapshot>(
              // Agora filtra as matérias pelo userId
              stream: FirebaseFirestore.instance.collection('users').doc(_currentUserId).collection('subjects').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}', style: TextStyle(color: Colors.white));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                List<DropdownMenuItem<String>> subjectItems = snapshot.data!.docs.map((doc) {
                  return DropdownMenuItem<String>(
                    value: doc.id, // O valor é o ID do documento da matéria
                    child: Text(doc['name'] as String),
                  );
                }).toList();

                // Garante que o item pré-selecionado esteja na lista de itens
                if (_selectedSubjectId != null && !subjectItems.any((item) => item.value == _selectedSubjectId)) {
                  // Se o ID pré-selecionado não estiver na lista (ex: carregamento assíncrono),
                  // adicionamos um item temporário para que o valor seja exibido.
                  if (_selectedSubjectName != null) {
                    subjectItems.add(DropdownMenuItem<String>(
                      value: _selectedSubjectId!,
                      child: Text(_selectedSubjectName!),
                    ));
                  }
                }


                return DropdownButtonFormField<String>(
                  value: _selectedSubjectId,
                  hint: const Text('Selecione a Matéria', style: TextStyle(color: Colors.white70)),
                  isExpanded: true,
                  onChanged: _onSubjectChanged,
                  items: subjectItems,
                  decoration: const InputDecoration(),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  dropdownColor: const Color(0xFF1A3A3A),
                );
              },
            ),
            const SizedBox(height: 20),
            // Dropdown para selecionar o tópico (dependente da matéria)
            if (_selectedSubjectId != null) // Só mostra o dropdown de tópico se uma matéria estiver selecionada
              DropdownButtonFormField<String>(
                value: _selectedTopicId,
                hint: const Text('Selecione o Tema', style: TextStyle(color: Colors.white70)),
                isExpanded: true,
                onChanged: _onTopicChanged,
                items: _availableTopics.map<DropdownMenuItem<String>>((Map<String, String> topic) {
                  return DropdownMenuItem<String>(
                    value: topic['id'],
                    child: Text(topic['name']!),
                  );
                }).toList(),
                decoration: const InputDecoration(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                dropdownColor: const Color(0xFF1A3A3A),
              ),
            const SizedBox(height: 30),
            // Campo de Pergunta
            const Text('PERGUNTA:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _questionController,
              maxLines: 5,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                fillColor: Colors.yellow.shade100,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Campo de Resposta
            const Text('RESPOSTA:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _answerController,
              maxLines: 5,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                fillColor: Colors.lightGreen.shade100,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveFlashcard, // Chama a função para salvar o flashcard
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('SALVAR FLASHCARD'),
            ),
          ],
        ),
      ),
    );
  }
}
