import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe o Firebase Auth
import 'widgets/profile_bar.dart';

class MyDashcardsScreen extends StatefulWidget {
  const MyDashcardsScreen({super.key});

  @override
  State<MyDashcardsScreen> createState() => _MyDashcardsScreenState();
}

class _MyDashcardsScreenState extends State<MyDashcardsScreen> {
  final TextEditingController _newSubjectController = TextEditingController();

  @override
  void dispose() {
    _newSubjectController.dispose();
    super.dispose();
  }

  // Função para exibir o diálogo de criação de nova matéria
  void _showCreateSubjectDialog(String userId) { // Agora recebe o userId
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A3A3A),
          title: const Text('Criar Nova Matéria', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _newSubjectController,
            decoration: InputDecoration(
              hintText: 'Nome da Matéria',
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
                _newSubjectController.clear();
              },
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                final String subjectName = _newSubjectController.text.trim();
                if (subjectName.isNotEmpty) {
                  _addSubjectToFirestore(userId, subjectName); // Passa o userId
                  Navigator.of(context).pop();
                  _newSubjectController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, digite o nome da matéria.')),
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

  // Função assíncrona para adicionar a matéria ao Firestore
  Future<void> _addSubjectToFirestore(String userId, String name) async { // Agora recebe o userId
    try {
      await FirebaseFirestore.instance
          .collection('users') // Adiciona a coleção 'users'
          .doc(userId)         // E o documento do usuário
          .collection('subjects')
          .add({
        'name': name,
        'createdAt': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Matéria "$name" criada com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar matéria: $e')),
      );
      print('Erro ao adicionar matéria ao Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtém o UID do usuário logado
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Caso o usuário não esteja logado (embora main.dart já deveria redirecionar)
      return const Center(child: Text('Você precisa estar logado para ver suas Dashpastas.', style: TextStyle(color: Colors.white)));
    }

    final String userId = user.uid; // O UID do usuário logado

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('MEUS DASHCARDS', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: ElevatedButton(
              onPressed: () => _showCreateSubjectDialog(userId), // Passa o userId para o diálogo
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.white.withOpacity(0.9),
              ),
              child: const Text('CRIAR DASHPASTA'),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Altera a referência para incluir o userId
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('subjects')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar matérias: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Nenhuma matéria encontrada. Crie sua primeira Dashpasta!', style: TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center,));
                }

                final subjects = snapshot.data!.docs;

                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subjectData = subjects[index].data() as Map<String, dynamic>;
                      final subjectName = subjectData['name'] as String;
                      final subjectId = subjects[index].id;

                      return _FolderItem(
                        folderName: subjectName,
                        onTap: () {
                          // Passa o userId, subjectId e subjectName para a próxima tela
                          Navigator.pushNamed(
                            context,
                            '/subject_topics',
                            arguments: {
                              'userId': userId, // Adiciona o userId
                              'subjectId': subjectId,
                              'subjectName': subjectName
                            },
                          );
                        },
                      );
                    },
                  ),
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

class _FolderItem extends StatelessWidget {
  final String folderName;
  final VoidCallback onTap;

  const _FolderItem({required this.folderName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder, color: Colors.lightBlue[200], size: 80),
          const SizedBox(height: 8),
          Text(
            folderName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
