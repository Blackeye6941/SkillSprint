import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const SkillSprint());
}

class SkillSprint extends StatelessWidget {
  const SkillSprint({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppProvider()..initializeData(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SkillSprint',
        theme: AppTheme.darkTheme,
        home: const ChatScreen(),
      ),
    );
  }
}
