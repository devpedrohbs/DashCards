import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe o Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Importe o Firestore
import '../main.dart'; // Importe main.dart para acessar InitialScreen

// Custom widget for the profile bar at the bottom
class ProfileBar extends StatefulWidget { // Mude para StatefulWidget
  const ProfileBar({super.key});
  
  @override
  State<ProfileBar> createState() => _ProfileBarState();
}

class _ProfileBarState extends State<ProfileBar> {
  // Instância do Firebase Authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Instância do Firebase Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para realizar o logout
  Future<void> _logout() async {
    try {
      await _auth.signOut();
      // Após o logout, redireciona explicitamente para a InitialScreen e limpa a pilha de rotas
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const InitialScreen()),
        (Route<dynamic> route) => false, // Remove todas as rotas anteriores
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão encerrada com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao sair da conta: $e')),
      );
      print('Erro ao fazer logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtém o usuário logado atualmente
    final User? user = _auth.currentUser;

    // Se não houver usuário logado, não exibe a ProfileBar
    if (user == null) {
      return const SizedBox.shrink(); // Widget vazio
    }

    final String userId = user.uid; // ID do usuário logado

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: const Color(0xFF4A7C59).withOpacity(0.4),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // StreamBuilder para ouvir as mudanças nos dados do perfil do usuário
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('users').doc(userId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('Erro ao carregar perfil: ${snapshot.error}');
                  return const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.error, color: Colors.white),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey,
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                String userName = 'Usuário';
                // String profileImageUrl = 'https://i.pravatar.cc/150?img=12'; // Imagem padrão

                if (snapshot.hasData && snapshot.data!.exists) {
                  final userData = snapshot.data!.data() as Map<String, dynamic>;
                  userName = userData['name'] as String? ?? 'Usuário Dashcards';
                  // if (userData['profileImageUrl'] != null) {
                  //   profileImageUrl = userData['profileImageUrl'] as String;
                  // }
                }

                return Row( // Agrupa a imagem e as informações do usuário
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      // Removido NetworkImage e adicionado um placeholder para evitar erros de rede em ambiente de teste
                      // Para produção, você pode voltar a usar NetworkImage ou carregar de um storage (Firebase Storage)
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName, // Nome do usuário do Firestore
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Manter esta linha como está por enquanto, sem integração Firebase
                        // Pois a contagem de dashcards exigiria uma query mais complexa ou campos dedicados no perfil
                        const Text(
                          '0 dashcards criados\n0 questões de provas', // Valores fixos por enquanto
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/edit_profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF132F2C).withOpacity(0.8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('EDITAR\nPERFIL', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 10), // Espaçamento entre botões
            ElevatedButton(
              onPressed: _logout, // Botão de logout
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.8), // Cor para o botão de logout
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('SAIR', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
            )
          ],
        ),
      ),
    );
  }
}
