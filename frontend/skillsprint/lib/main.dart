import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

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
