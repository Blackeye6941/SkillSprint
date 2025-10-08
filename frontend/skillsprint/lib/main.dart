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

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      messages.add({'role': 'user', 'text': _controller.text});
      messages.add({'role': 'bot', 'text': 'This is a sample SkillSprint reply 🤖'});
      _controller.clear();
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('SkillSprint'),
      centerTitle: true,
    ),
    body: Column(
      children: [
        // Chat messages
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isUser = message['role'] == 'user';
              return Align(
                alignment:
                    isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Colors.tealAccent.shade100
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
          ),
        ),

        const SizedBox(height: 12),

        // Text input field with mic disappearing while typing
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Type your message...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

              // Icons inside the text field
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Voice button: only visible if text field is empty
                  if (_controller.text.isEmpty)
                    IconButton(
                      icon: const Icon(Icons.mic, color: Colors.teal),
                      onPressed: () {
                        // TODO: Add voice recording action
                      },
                    ),

                  // Send button: always visible
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.teal),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
            onChanged: (text) {
              setState(() {}); // rebuild to update mic visibility
            },
          ),
        ),

        const SizedBox(height: 16),

        // Two options below text field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: Add Option 1 action
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
                onPressed: () {
                  // TODO: Add Option 2 action
                },
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
}