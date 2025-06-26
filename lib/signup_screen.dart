import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe o Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Importe o Firestore para salvar dados do usuário

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Instância do Firebase Authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Instância do Firebase Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signup() async { // Tornar a função assíncrona
    if (_formKey.currentState!.validate()) {
      try {
        // Tenta criar um novo usuário com email e senha
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Se o usuário foi criado com sucesso
        if (userCredential.user != null) {
          final String uid = userCredential.user!.uid;
          final String email = userCredential.user!.email!;

          // Salva os dados do usuário no Firestore usando o UID como ID do documento
          await _firestore.collection('users').doc(uid).set({
            'email': email,
            'name': 'Usuário Dashcards', // Nome padrão, pode ser alterado posteriormente
            'createdAt': Timestamp.now(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conta criada com sucesso!')),
          );
          // Navega para a tela inicial após o cadastro
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'weak-password') {
          message = 'A senha fornecida é muito fraca.';
        } else if (e.code == 'email-already-in-use') {
          message = 'Já existe uma conta para esse endereço de e-mail.';
        } else {
          message = 'Erro ao criar conta: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Erro de autenticação: ${e.code} - ${e.message}');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ocorreu um erro inesperado: $e')),
        );
        print('Erro inesperado: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
       backgroundColor: const Color(0xFF1A3A3A),
      body: Stack(
        children: [
          Positioned(
            top: -screenHeight * 0.2,
            left: -screenWidth * 0.3,
            child: Container(
              width: screenWidth * 0.9,
              height: screenHeight * 0.5,
              decoration: BoxDecoration(
                color: const Color(0xFF2C5D5A).withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -screenHeight * 0.1,
            right: -screenWidth * 0.5,
            child: Container(
              width: screenWidth * 1.2,
              height: screenHeight * 0.45,
              decoration: BoxDecoration(
                color: const Color(0xFF4A7C59).withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(300),
                )
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Crie sua\nDashcount',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 32),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'É grátis!!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 40),
                         Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(hintText: 'EMAIL'),
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty || !value.contains('@')) {
                                    return 'Por favor, insira um email válido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _passwordController,
                                decoration: const InputDecoration(hintText: 'SENHA'),
                                style: const TextStyle(color: Colors.white),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty || value.length < 6) {
                                    return 'A senha deve ter pelo menos 6 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration: const InputDecoration(hintText: 'CONFIRMAR SENHA'),
                                style: const TextStyle(color: Colors.white),
                                obscureText: true,
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'As senhas não coincidem';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: _signup,
                           style: ElevatedButton.styleFrom(
                             padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          child: const Text('CRIAR CONTA'),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
