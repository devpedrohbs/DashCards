import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importe o Firestore
import 'widgets/profile_bar.dart';

class SubjectTopicsScreen extends StatefulWidget {
  const SubjectTopicsScreen({super.key});

  @override
  State<SubjectTopicsScreen> createState() => _SubjectTopicsScreenState();
}

class _SubjectTopicsScreenState extends State<SubjectTopicsScreen> {
  final TextEditingController _newTopicController = TextEditingController();

  @override
  void dispose() {
    _newTopicController.dispose();
    super.dispose();
  }

  // Função para exibir o diálogo de criação de novo tópico
  void _showCreateTopicDialog(String userId, String subjectId) { // Agora recebe userId e subjectId
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A3A3A),
          title: const Text('Criar Novo Tópico', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _newTopicController,
            decoration: InputDecoration(
              hintText: 'Nome do Tópico',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _newTopicController.clear();
              },
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                final String topicName = _newTopicController.text.trim();
                if (topicName.isNotEmpty) {
                  _addTopicToFirestore(userId, subjectId, topicName); // Passa userId e subjectId
                  Navigator.of(context).pop();
                  _newTopicController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, digite o nome do tópico.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7C59),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );
  }

  // Função assíncrona para adicionar o tópico ao Firestore
  Future<void> _addTopicToFirestore(String userId, String subjectId, String name) async { // Agora recebe userId e subjectId
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('subjects')
          .doc(subjectId)
          .collection('topics')
          .add({
        'name': name,
        'createdAt': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tópico "$name" criado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar tópico: $e')),
      );
      print('Erro ao adicionar tópico ao Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Recebe os argumentos passados da tela anterior
    final Map<String, String> args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final String userId = args['userId']!; // Obtém o userId
    final String subjectId = args['subjectId']!;
    final String subjectName = args['subjectName']!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Text(
            subjectName.toUpperCase(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 32),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton(
              onPressed: () => _showCreateTopicDialog(userId, subjectId), // Passa userId e subjectId para o diálogo
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.white.withOpacity(0.9),
              ),
              child: const Text('CRIAR TEMAS'),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: StreamBuilder<QuerySnapshot>( // StreamBuilder para os tópicos
              stream: FirebaseFirestore.instance
                  .collection('users') // Adiciona a coleção 'users'
                  .doc(userId)         // E o documento do usuário
                  .collection('subjects')
                  .doc(subjectId) // Filtra pelos tópicos da matéria atual
                  .collection('topics')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar tópicos: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Nenhum tópico encontrado. Crie seu primeiro tema!', style: TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center,));
                }

                final topics = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final topicData = topics[index].data() as Map<String, dynamic>;
                    final topicName = topicData['name'] as String;
                    final topicId = topics[index].id; // Obtém o ID do tópico

                    return _TopicButton(
                      topicName: topicName,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/flashcard',
                          arguments: {
                            'userId': userId, // Adiciona o userId
                            'subjectId': subjectId,
                            'subjectName': subjectName,
                            'topicId': topicId,
                            'topicName': topicName,
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const ProfileBar(),
        ],
      ),
    );
  }
}

class _TopicButton extends StatelessWidget {
  final String topicName;
  final VoidCallback onTap;

  const _TopicButton({required this.topicName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFF2C5D5A),
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(
          topicName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
      ),
    );
  }
}
