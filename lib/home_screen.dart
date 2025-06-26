import 'package:flutter/material.dart';
import 'widgets/profile_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          // Main menu buttons
          _HomeMenuButton(
            label: 'CRIAR\nDASHCARDS',
            icon: Icons.library_books_outlined,
            gradient: const [Color(0xFF88D4E4), Color(0xFF65B9C9)],
            onTap: () => Navigator.pushNamed(context, '/create_dashcard'),
          ),
          const SizedBox(height: 30),
          _HomeMenuButton(
            label: 'QUESTÕES\nPROVAS',
            icon: Icons.note_alt_outlined,
            gradient: const [Color(0xFFA8E063), Color(0xFF8BC34A)],
            onTap: () => print('Questões Provas tapped'),
          ),
          const SizedBox(height: 30),
          _HomeMenuButton(
            label: 'MEUS\nDASHCARDS',
            icon: Icons.collections_bookmark_outlined,
            gradient: const [Color(0xFFFF8A65), Color(0xFFF4511E)],
            onTap: () => Navigator.pushNamed(context, '/my_dashcards'),
          ),
          const Spacer(),
          // Profile section at the bottom
          const ProfileBar(),
        ],
      ),
    );
  }
}

// Custom widget for the menu buttons on the home screen
class _HomeMenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _HomeMenuButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 120,
            width: 160,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20.0,
                  spreadRadius: -10.0,
                  offset: const Offset(0, 10),
                )
              ]
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15.0,
                        spreadRadius: 2.0,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 50),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              height: 1.2,
            ),
          )
        ],
      ),
    );
  }
}