import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/chat_input.dart';
import '../widgets/xp_badge.dart';
import '../widgets/floating_nav_dock.dart';
import '../widgets/progress_ring.dart';
import '../widgets/skeleton_loader.dart';
import 'roadmap_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isListening = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(AppProvider provider) {
    if (_controller.text.trim().isEmpty) return;
    provider.sendChatMessage(_controller.text);
    _controller.clear();
    _isListening = false;
    
    // Auto-scroll to bottom of chat
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _controller.text = "Tell me about learning Flutter!";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 760;
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF070707),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Safe Top Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SKILLSPRINT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      fontStyle: FontStyle.italic,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  if (provider.progress != null)
                    XpBadge(
                      count: provider.progress!.xpCount,
                      label: 'XP',
                      icon: Icons.local_fire_department,
                    ),
                ],
              ),
            ),

            Expanded(
              child: isTablet
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tablet Left Pane: Rich Dashboard Stats
                        Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(left: 20, right: 10, bottom: 80),
                            child: _buildDashboardPane(provider),
                          ),
                        ),
                        // Tablet Right Pane: Chat Window
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 20, bottom: 80),
                            child: _buildChatPane(provider),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        // Phone Top: Dashboard Stats Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildPhoneDashboard(provider),
                        ),
                        const SizedBox(height: 10),
                        // Phone Bottom: Scrollable Chat History
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildChatPane(provider),
                          ),
                        ),
                        const SizedBox(height: 80), // spacer for bottom dock
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FloatingNavDock(activeIndex: 0),
    );
  }

  // Large grid dashboard layout for tablet widths
  Widget _buildDashboardPane(AppProvider provider) {
    if (provider.isLoadingProgress) {
      return const SkeletonLoader(child: DashboardSkeleton());
    }

    final stats = provider.progress;
    if (stats == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "DAILY DASHBOARD",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white30),
        ),
        const SizedBox(height: 12),
        // Stats Cards Row
        Row(
          children: [
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    const Icon(Icons.flash_on, color: Colors.orangeAccent, size: 24),
                    const SizedBox(height: 6),
                    Text("${stats.dailyStreak} DAYS", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Text("Daily Streak", style: TextStyle(fontSize: 10, color: Colors.white38)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                    const SizedBox(height: 6),
                    Text("${stats.completedGoalsCount} GOALS", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Text("Completed", style: TextStyle(fontSize: 10, color: Colors.white38)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Daily Progress Ring Card
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ProgressRing(
                progress: stats.dailyProgress,
                size: 75,
                strokeWidth: 5,
                color: Colors.orangeAccent,
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("TODAY'S TARGET", style: TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 1.1)),
                    SizedBox(height: 4),
                    Text("Daily Progress", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text("Complete steps to fill your ring and levels!", style: TextStyle(fontSize: 11, color: Colors.white54)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Level summary Card
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.anchor, color: Colors.orangeAccent, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("LEVEL ${stats.level} CAPTAIN", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text("Next Rank: Pirate King Goal (+680 XP)", style: TextStyle(fontSize: 10, color: Colors.white38)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Compact horizontal stats summary for phone layout
  Widget _buildPhoneDashboard(AppProvider provider) {
    if (provider.isLoadingProgress) {
      return const SkeletonLoader(child: SizedBox(height: 90, child: CardSkeleton()));
    }

    final stats = provider.progress;
    if (stats == null) return const SizedBox();

    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ProgressRing(
            progress: stats.dailyProgress,
            size: 55,
            strokeWidth: 4.5,
            color: Colors.orangeAccent,
            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("TODAY'S MISSION PROGRESS", style: TextStyle(fontSize: 9, color: Colors.white38, letterSpacing: 1.1)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 16),
                    const SizedBox(width: 2),
                    Text("${stats.dailyStreak} Day Streak", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    const Icon(Icons.anchor, color: Colors.orangeAccent, size: 14),
                    const SizedBox(width: 2),
                    Text("Lv. ${stats.level}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text("Ask the captain to map out a custom goal!", style: TextStyle(fontSize: 10, color: Colors.white54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Chat window pane containing messaging records
  Widget _buildChatPane(AppProvider provider) {
    return Column(
      children: [
        Expanded(
          child: provider.isLoadingChat
              ? const SkeletonLoader(
                  child: Column(
                    children: [
                      CardSkeleton(),
                      CardSkeleton(),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: provider.chatHistory.length,
                  itemBuilder: (context, index) {
                    final message = provider.chatHistory[index];
                    final isUser = message.role == 'user';
                    
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: isUser
                              ? const LinearGradient(
                                  colors: [Color(0xFFFF9100), Color(0xFFFFAB40)],
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.06),
                                    Colors.white.withOpacity(0.03),
                                  ],
                                ),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 0),
                            bottomRight: Radius.circular(isUser ? 0 : 16),
                          ),
                          border: isUser
                              ? null
                              : Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: isUser ? Colors.black : Colors.white,
                            fontSize: 14,
                            fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        ChatInput(
          controller: _controller,
          onSend: () => _sendMessage(provider),
          onMic: _toggleListening,
          isListening: _isListening,
          isSending: provider.isSendingChat,
        ),
      ],
    );
  }
}
