import 'package:flutter/material.dart';

class CreateDashcardScreen extends StatefulWidget {
  const CreateDashcardScreen({super.key});

  @override
  State<CreateDashcardScreen> createState() => _CreateDashcardScreenState();
}

class _CreateDashcardScreenState extends State<CreateDashcardScreen> {
  // Mock data for subjects and their topics
  final Map<String, List<String>> _subjectsAndTopics = {
    'INGLÊS': ['Verbs', 'Vocabulary', 'Grammar'],
    'HISTÓRIA': ['Brasil Colônia', 'Guerra Fria', 'Revolução Francesa'],
    'PORTUGUÊS': ['Literatura', 'Gramática', 'Redação'],
    'BIOLOGIA': ['Citologia', 'Genética', 'Ecologia'],
    'MATEMÁTICA': ['Aritmética', 'Álgebra', 'Geometria'],
    'GEOGRAFIA': ['Geopolítica', 'Climatologia', 'Relevo'],
  };

  String? _selectedSubject;
  String? _selectedTopic;
  List<String> _availableTopics = [];

  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _onSubjectChanged(String? newValue) {
    setState(() {
      _selectedSubject = newValue;
      _availableTopics = _subjectsAndTopics[newValue!] ?? [];
      _selectedTopic = null; // Reset topic when subject changes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRIAR DASHCARD'),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Dropdown to select subject
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              hint: const Text('Selecione a Matéria', style: TextStyle(color: Colors.white70)),
              isExpanded: true,
              onChanged: _onSubjectChanged,
              items: _subjectsAndTopics.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              dropdownColor: const Color(0xFF1A3A3A),
            ),
            const SizedBox(height: 20),
            // Dropdown to select topic (dependent on subject)
            if (_selectedSubject != null)
              DropdownButtonFormField<String>(
                value: _selectedTopic,
                hint: const Text('Selecione o Tema', style: TextStyle(color: Colors.white70)),
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTopic = newValue;
                  });
                },
                items: _availableTopics.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                dropdownColor: const Color(0xFF1A3A3A),
              ),
            const SizedBox(height: 30),
            // Question field
            const Text('PERGUNTA:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _questionController,
              maxLines: 5,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                fillColor: Colors.yellow.shade100,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Answer field
            const Text('RESPOSTA:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _answerController,
              maxLines: 5,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                fillColor: Colors.lightGreen.shade100,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement save logic
                print('Saving Flashcard...');
                if (_selectedSubject != null && _selectedTopic != null && _questionController.text.isNotEmpty && _answerController.text.isNotEmpty) {
                  print('Subject: $_selectedSubject');
                  print('Topic: $_selectedTopic');
                  print('Question: ${_questionController.text}');
                  print('Answer: ${_answerController.text}');
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Flashcard salvo com sucesso!')),
                  );
                  Navigator.of(context).pop();
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, preencha todos os campos.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('SALVAR FLASHCARD'),
            ),
          ],
        ),
      ),
    );
  }
}
