import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../models/chat_message.dart';
import '../models/user_progress.dart';
import '../models/roadmap_step.dart';
import '../services/api_service.dart';

class AppProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // State flags
  bool _isLoadingGoals = false;
  bool _isLoadingProgress = false;
  bool _isLoadingChat = false;
  bool _isSendingChat = false;
  bool _hasError = false;

  // Data state
  List<Goal> _goals = [];
  UserProgress? _progress;
  List<ChatMessage> _chatHistory = [];
  String _searchQuery = '';
  String _activeCategory = 'All';

  // Getters
  bool get isLoadingGoals => _isLoadingGoals;
  bool get isLoadingProgress => _isLoadingProgress;
  bool get isLoadingChat => _isLoadingChat;
  bool get isSendingChat => _isSendingChat;
  bool get hasError => _hasError;
  UserProgress? get progress => _progress;
  List<ChatMessage> get chatHistory => _chatHistory;
  String get searchQuery => _searchQuery;
  String get activeCategory => _activeCategory;

  // Filtered goals list based on search query & active category
  List<Goal> get filteredGoals {
    return _goals.where((goal) {
      final matchesQuery = goal.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          goal.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _activeCategory == 'All' || goal.category == _activeCategory;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  List<String> get categories {
    final Set<String> cats = {'All'};
    for (var g in _goals) {
      cats.add(g.category);
    }
    return cats.toList();
  }

  // Load initial dashboard details
  Future<void> initializeData() async {
    _hasError = false;
    _isLoadingGoals = true;
    _isLoadingProgress = true;
    _isLoadingChat = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.fetchGoals(),
        _api.fetchUserProgress(),
        _api.fetchChatMessages(),
      ]);

      _goals = results[0] as List<Goal>;
      _progress = results[1] as UserProgress;
      _chatHistory = results[2] as List<ChatMessage>;
    } catch (e) {
      _hasError = true;
    } finally {
      _isLoadingGoals = false;
      _isLoadingProgress = false;
      _isLoadingChat = false;
      notifyListeners();
    }
  }

  // Refresh goals list
  Future<void> refreshGoals() async {
    _hasError = false;
    notifyListeners();
    try {
      _goals = await _api.fetchGoals();
    } catch (e) {
      _hasError = true;
    } finally {
      notifyListeners();
    }
  }

  // Search filter
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Category filter
  void updateCategory(String category) {
    _activeCategory = category;
    notifyListeners();
  }

  // Submit chat prompt and trigger Captain Mascot reply
  Future<void> sendChatMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      text: text,
      timestamp: DateTime.now(),
    );

    _chatHistory.add(userMsg);
    _isSendingChat = true;
    notifyListeners();

    try {
      final botText = await _api.sendChatMessage(text);
      final botMsg = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        role: 'bot',
        text: botText,
        timestamp: DateTime.now(),
      );
      _chatHistory.add(botMsg);
      
      // Award XP for asking questions!
      if (_progress != null) {
        _progress = _progress!.copyWith(
          xpCount: _progress!.xpCount + 10,
        );
      }
    } catch (e) {
      // Handle error locally
    } finally {
      _isSendingChat = false;
      notifyListeners();
    }
  }

  // Complete a step on the roadmap path
  void completeRoadmapStep(String goalId, String stepId) {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex == -1) return;

    final goal = _goals[goalIndex];
    final stepIndex = goal.roadmap.indexWhere((s) => s.id == stepId);
    if (stepIndex == -1) return;

    final step = goal.roadmap[stepIndex];
    if (step.status == 'completed') return;

    // 1. Update the step status
    final updatedStep = step.copyWith(
      status: 'completed',
      completedSteps: step.totalSteps,
    );

    final updatedRoadmap = List<RoadmapStep>.from(goal.roadmap);
    updatedRoadmap[stepIndex] = updatedStep;

    // 2. Unlock the NEXT step in line
    if (stepIndex + 1 < updatedRoadmap.length) {
      final nextStep = updatedRoadmap[stepIndex + 1];
      updatedRoadmap[stepIndex + 1] = nextStep.copyWith(
        status: 'active',
      );
    }

    // 3. Compute overall goal progress
    int completedCount = updatedRoadmap.where((s) => s.status == 'completed').length;
    double newGoalProgress = completedCount / updatedRoadmap.length;

    // 4. Update the goal state
    _goals[goalIndex] = goal.copyWith(
      progress: newGoalProgress,
      roadmap: updatedRoadmap,
    );

    // 5. Update user progress stats (Award +25 XP and update Daily progress)
    if (_progress != null) {
      int newXp = _progress!.xpCount + 25;
      int extraLevel = (newXp / 100).floor(); // level up every 100 XP
      int newLevel = 12 + extraLevel;

      _progress = _progress!.copyWith(
        xpCount: newXp,
        level: newLevel,
        dailyProgress: (_progress!.dailyProgress + 0.15).clamp(0.0, 1.0),
      );
    }

    notifyListeners();
  }
}
