import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe o Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Importe o Firestore

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // Para exibir o email (não editável)

  User? _currentUser; // Usuário logado do Firebase Auth
  DocumentSnapshot? _userProfile; // Documento do perfil do usuário no Firestore

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadUserProfile(); // Carrega os dados do perfil ao iniciar a tela
  }

  // Função para carregar os dados do perfil do Firestore
  Future<void> _loadUserProfile() async {
    if (_currentUser == null) {
      // Usuário não logado, não há perfil para carregar
      return;
    }

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          _userProfile = docSnapshot;
          _nameController.text = _userProfile!['name'] as String? ?? 'Usuário Dashcards';
          _emailController.text = _currentUser!.email ?? 'N/A'; // Email do Firebase Auth
        });
      } else {
        // Documento do perfil não existe, pode ser um novo usuário ou erro
        setState(() {
          _nameController.text = 'Usuário Dashcards';
          _emailController.text = _currentUser!.email ?? 'N/A';
        });
        // Opcional: Criar o documento do perfil se não existir (já feito no signup)
        // Mas para garantir, podemos criar aqui se for necessário
        await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).set({
          'email': _currentUser!.email,
          'name': 'Usuário Dashcards',
          'createdAt': Timestamp.now(),
        }, SetOptions(merge: true)); // Usa merge para não sobrescrever dados existentes
      }
    } catch (e) {
      print('Erro ao carregar perfil: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar perfil: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Função para salvar as alterações do perfil no Firestore
  Future<void> _saveProfile() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Usuário não logado.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
        'name': _nameController.text.trim(),
        // Futuramente, outros campos como 'profileImageUrl' podem ser atualizados aqui
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
      Navigator.of(context).pop(); // Volta para a tela anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar perfil: $e')),
      );
      print('Erro ao salvar perfil: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF132F2C),
        body: Center(
          child: Text('Você precisa estar logado para editar o perfil.', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('EDITAR PERFIL'),
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
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                const CircleAvatar(
                  radius: 60,
                  // Mantendo o placeholder de ícone, pois o upload de imagem é mais complexo
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white, size: 60),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: () {
                        // TODO: Implementar seleção de imagem de perfil (requer Firebase Storage)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidade de troca de imagem de perfil em desenvolvimento!')),
                        );
                        print('Change profile picture');
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'NOME DE USUÁRIO',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              readOnly: true, // Email não editável
              decoration: const InputDecoration(
                labelText: 'EMAIL',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveProfile, // Chama a função para salvar
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('SALVAR ALTERAÇÕES'),
            ),
          ],
        ),
      ),
    );
  }
}
