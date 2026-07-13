import 'dart:async';
import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../models/roadmap_step.dart';
import '../models/user_progress.dart';
import '../models/chat_message.dart';

class ApiService {
  // Simulates a realistic network call delay (800ms) to trigger skeleton loaders
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  Future<List<Goal>> fetchGoals() async {
    await _simulateDelay();
    return [
      Goal(
        id: '1',
        title: 'Master Flutter',
        progress: 0.05,
        category: 'Programming',
        themeColor: Colors.orangeAccent,
        description: 'Complete cross-platform mobile development track from basics to final production deployment.',
        roadmap: [
          RoadmapStep(
            id: 'm1_1',
            title: 'Hello World',
            desc: 'Create your first Flutter application and view output.',
            icon: Icons.menu_book,
            status: 'completed',
            completedSteps: 3,
            totalSteps: 3,
          ),
          RoadmapStep(
            id: 'm1_2',
            title: 'Widget Trees',
            desc: 'Understand composition, parent-child structures, and building trees.',
            icon: Icons.account_tree,
            status: 'active',
            completedSteps: 2,
            totalSteps: 3,
          ),
          RoadmapStep(
            id: 'm1_3',
            title: 'Stateless Widgets',
            desc: 'Build static, reusable visual components and styles.',
            icon: Icons.extension,
            status: 'locked',
            completedSteps: 0,
            totalSteps: 3,
          ),
          RoadmapStep(
            id: 'm2_1',
            title: 'Rows & Columns',
            desc: 'Master linear layouts, alignment, and distribution.',
            icon: Icons.view_column,
            status: 'locked',
            completedSteps: 0,
            totalSteps: 3,
          ),
          RoadmapStep(
            id: 'm2_2',
            title: 'Containers & Styling',
            desc: 'Apply padding, margins, borders, decorations, and shadows.',
            icon: Icons.aspect_ratio,
            status: 'locked',
            completedSteps: 0,
            totalSteps: 3,
          ),
          RoadmapStep(
            id: 'm2_3',
            title: 'Gestures & Buttons',
            desc: 'Handle taps, double taps, long presses, and interactive logic.',
            icon: Icons.touch_app,
            status: 'locked',
            completedSteps: 0,
            totalSteps: 3,
          ),
          RoadmapStep(
            id: 'm3_1',
            title: 'Stateful Widgets',
            desc: 'Build interactive screens with dynamic state updates.',
            icon: Icons.refresh,
            status: 'locked',
            completedSteps: 0,
            totalSteps: 3,
          ),
          RoadmapStep(
            id: 'm3_2',
            title: 'Navigator 1.0',
            desc: 'Push and pop routes on the screen navigation stack.',
            icon: Icons.directions_run,
            status: 'locked',
            completedSteps: 0,
            totalSteps: 3,
          ),
          RoadmapStep(
            id: 'm3_3',
            title: 'Custom Themes',
            desc: 'Create standard dark/light color schemes and style variables.',
            icon: Icons.palette,
            status: 'locked',
            completedSteps: 0,
            totalSteps: 3,
          ),
        ],
      ),
      Goal(
        id: '2',
        title: 'UI/UX Design',
        progress: 0.15,
        category: 'Design',
        themeColor: Colors.purpleAccent,
        description: 'Learn modern visual design principles, low-fi wireframing, and usability testing.',
        roadmap: [],
      ),
      Goal(
        id: '3',
        title: 'Backend Integration',
        progress: 0.35,
        category: 'Programming',
        themeColor: Colors.blueAccent,
        description: 'Connect Flutter clients to Node/Go APIs, query schemas, and configure token auth.',
        roadmap: [],
      ),
      Goal(
        id: '4',
        title: 'DSA Mastery',
        progress: 0.25,
        category: 'Algorithms',
        themeColor: Colors.greenAccent,
        description: 'Solve coding puzzles, understand Big O, and master binary search trees.',
        roadmap: [],
      ),
      Goal(
        id: '5',
        title: 'Open Source Contribution',
        progress: 0.45,
        category: 'Career',
        themeColor: Colors.cyanAccent,
        description: 'Fork codebases, address open issues, and merge pull requests on GitHub.',
        roadmap: [],
      ),
      Goal(
        id: '6',
        title: 'Mobile App Launch',
        progress: 0.65,
        category: 'Career',
        themeColor: Colors.amberAccent,
        description: 'Build production bundles, configure signing certificates, and publish to Play/App Store.',
        roadmap: [],
      ),
    ];
  }

  Future<UserProgress> fetchUserProgress() async {
    await _simulateDelay();
    return UserProgress(
      dailyStreak: 5,
      xpCount: 320,
      completedGoalsCount: 2,
      level: 12,
      dailyProgress: 0.45,
    );
  }

  Future<List<ChatMessage>> fetchChatMessages() async {
    await _simulateDelay();
    return [
      ChatMessage(
        id: 'c1',
        role: 'bot',
        text: 'Ready to set sail? Tell me your learning goal, and I will generate a custom road pathway map for you!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  Future<String> sendChatMessage(String messageText) async {
    await _simulateDelay();
    String txt = messageText.toLowerCase();
    if (txt.contains('flutter')) {
      return "Ahoy! Flutter is a goated choice. I've created a learning map for you. Select it from your goals dashboard to sail! 🚀";
    } else if (txt.contains('design') || txt.contains('ux')) {
      return "Design is the map to beautiful interfaces! I've loaded a visual design track for you in your explorer tab! 🎨";
    } else {
      return "Arr! That learning goal sounds like a grand adventure. I've mapped out a general fundamentals pathway for you! Let's get coding! ⛵";
    }
  }
}
