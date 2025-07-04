import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe o Firebase Auth

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Instância do Firebase Authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async { // Tornar a função assíncrona
    if (_formKey.currentState!.validate()) {
      try {
        // Tenta fazer login com email e senha
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login realizado com sucesso!')),
        );
        // Navega para a tela inicial após o login
        Navigator.pushReplacementNamed(context, '/home');
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'Nenhum usuário encontrado para esse e-mail.';
        } else if (e.code == 'wrong-password') {
          message = 'Senha incorreta para esse e-mail.';
        } else if (e.code == 'invalid-email') {
          message = 'O formato do e-mail é inválido.';
        } else {
          message = 'Erro ao fazer login: ${e.message}';
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
            right: -screenWidth * 0.3,
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
            left: -screenWidth * 0.5,
            child: Container(
              width: screenWidth * 1.2,
              height: screenHeight * 0.45,
              decoration: BoxDecoration(
                color: const Color(0xFF4A7C59).withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(300),
                )
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
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
                    'Entre na sua\nDashcount',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 50),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                       padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text('ENTRAR'),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
