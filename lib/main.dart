import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe o Firebase Auth
import 'firebase_options.dart';

import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'my_dashcards_screen.dart';
import 'subject_topics_screen.dart';
import 'flashcard_screen.dart';
import 'edit_profile_screen.dart';
import 'create_dashcard_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashcards',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFF132F2C),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1A3A3A),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
             backgroundColor: const Color(0xFF4A7C59).withOpacity(0.8),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
         inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
        ),
      ),
      // A tela inicial agora depende do estado de autenticação
      home: StreamBuilder<User?>( // Ouve as mudanças no estado de autenticação
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Exibe um indicador de carregamento
          }
          if (snapshot.hasData) {
            // Se houver dados (usuário logado), vai para a tela principal
            return const HomeScreen();
          } else {
            // Caso contrário (usuário não logado), vai para a tela inicial de login/cadastro
            return const InitialScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/my_dashcards': (context) => const MyDashcardsScreen(),
        '/subject_topics': (context) => const SubjectTopicsScreen(),
        '/flashcard': (context) => const FlashcardScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/create_dashcard': (context) => const CreateDashcardScreen(),
      },
    );
  }
}

// A InitialScreen original permanece, mas agora é acessada via rota ou como fallback
class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
       backgroundColor: const Color(0xFF1A3A3A),
      body: Stack(
        children: [
          Positioned(
            top: -screenHeight * 0.15,
            left: -screenWidth * 0.2,
            child: Container(
              width: screenWidth * 0.8,
              height: screenHeight * 0.4,
              decoration: BoxDecoration(
                color: const Color(0xFF2C5D5A).withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -screenHeight * 0.25,
            right: -screenWidth * 0.3,
            child: Container(
              width: screenWidth * 1.2,
              height: screenHeight * 0.6,
              decoration: BoxDecoration(
                color: const Color(0xFF4A7C59).withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(300),
                  topRight: Radius.circular(100),
                )
              ),
            ),
          ),
           Positioned(
            bottom: -screenHeight * 0.1,
            left: -screenWidth * 0.4,
            child: Container(
              width: screenWidth * 1.0,
              height: screenHeight * 0.4,
              decoration: BoxDecoration(
                color: const Color(0xFF60987C).withOpacity(0.6),
                 borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(200),
                )
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.flash_on, color: Colors.white, size: 40),
                        const SizedBox(width: 8),
                        Text(
                          'Dashcards',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 36),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Dashcards é um app de estudos com flashcards personalizáveis',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Comece entrando na sua conta ou se inscrevendo',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 60),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text('ENTRAR'),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text('INSCREVER'),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
