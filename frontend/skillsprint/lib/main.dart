import 'package:flutter/material.dart';

void main() {
  runApp(const SkillSprint());
}

class SkillSprint extends StatelessWidget {
  const SkillSprint({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkillSprint',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

// ================= CHAT SCREEN =================

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();

  bool showWelcome = true;
  bool isListening = false;

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      showWelcome = false;

      messages.add({'role': 'user', 'text': _controller.text});
      messages.add({
        'role': 'bot',
        'text': 'Great goal! I’m creating a learning plan for you 🚀',
      });

      _controller.clear();
      isListening = false;
    });
  }

  void toggleListening() {
    setState(() {
      isListening = !isListening;

      // Simulated voice input
      if (isListening) {
        _controller.text = "I want to learn Flutter";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'SkillSprint',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.3,
            color: Colors.blue,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: showWelcome ? _buildWelcomeScreen() : _buildChatList(),
          ),

          // INPUT FIELD (TEXT + VOICE)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type or speak your goal...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isListening ? Icons.mic_off : Icons.mic,
                        color: isListening ? Colors.red : Colors.teal,
                      ),
                      onPressed: toggleListening,
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.teal),
                      onPressed: sendMessage,
                    ),
                  ],
                ),
              ),
              onSubmitted: (_) => sendMessage(),
            ),
          ),

          // BOTTOM BUTTONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GoalsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.menu, size: 28),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.home, size: 28),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ================= WELCOME SCREEN =================

  Widget _buildWelcomeScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.flash_on, size: 70, color: Colors.teal),
            SizedBox(height: 20),
            Text(
              '👋 Hi! I’m SkillSprint',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Tell me what skill you want to learn.\nI’ll create a step-by-step plan for you 🎯',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CHAT LIST =================

  Widget _buildChatList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUser = message['role'] == 'user';

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser
                  ? const Color.fromARGB(255, 167, 195, 255)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message['text'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}

// ================= GOALS SCREEN =================

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> goals = [
      {'title': 'Learn Flutter', 'progress': 0.75},
      {'title': 'UI/UX Design', 'progress': 0.45},
      {'title': 'DSA Practice', 'progress': 0.9},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('My Goals'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          final progress = goal['progress'];

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progress * 100).toInt()}% completed',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
