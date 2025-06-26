import 'package:flutter/material.dart';
import 'widgets/profile_bar.dart';

class MyDashcardsScreen extends StatelessWidget {
  const MyDashcardsScreen({super.key});

  // Mock data for subject folders
  final List<Map<String, String>> _folders_data = const [
    {'name': 'INGLÊS'},
    {'name': 'HISTÓRIA'},
    {'name': 'PORTUGUÊS'},
    {'name': 'BIOLOGIA'},
    {'name': 'MATEMÁTICA'},
    {'name': 'GEOGRAFIA'},
  ];

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => print('Criar Dashpasta Tapped'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.white.withOpacity(0.9),
              ),
              child: const Text('CRIAR DASHPASTA'),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.2,
                ),
                itemCount: _folders_data.length,
                itemBuilder: (context, index) {
                  return _FolderItem(
                    folderName: _folders_data[index]['name']!,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/subject_topics',
                        arguments: _folders_data[index]['name']!,
                      );
                    },
                  );
                },
              ),
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