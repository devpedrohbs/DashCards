import 'package:flutter/material.dart';
import 'widgets/profile_bar.dart';

class SubjectTopicsScreen extends StatelessWidget {
  const SubjectTopicsScreen({super.key});

  final List<String> _topics_data = const [
    'Aritmética',
    'Álgebra',
    'Geometria',
    'Trigonometria'
  ];

  @override
  Widget build(BuildContext context) {
    final subjectName = ModalRoute.of(context)!.settings.arguments as String;

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
          ElevatedButton(
            onPressed: () => print('Criar Temas Tapped'),
            child: const Text('CRIAR TEMAS'),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: _topics_data.length,
              itemBuilder: (context, index) {
                final topic = _topics_data[index];
                return _TopicButton(
                  topicName: topic,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/flashcard',
                      arguments: topic,
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
      ),
    );
  }
}