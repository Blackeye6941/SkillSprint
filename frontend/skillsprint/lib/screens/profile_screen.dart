import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/floating_nav_dock.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final stats = provider.progress;

    return Scaffold(
      backgroundColor: const Color(0xFF070707),
      appBar: AppBar(
        title: const Text('CAPTAIN PROFILE'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // 1. User Header Details Card
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withOpacity(0.12),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.orangeAccent, width: 2),
                          ),
                          child: const Icon(
                            Icons.anchor,
                            size: 40,
                            color: Colors.orangeAccent,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.orangeAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              "👑",
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "CAPTAIN CODER",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Sailing the code seas since July 2026",
                      style: TextStyle(fontSize: 11, color: Colors.white38),
                    ),
                    const SizedBox(height: 16),
                    if (stats != null) ...[
                      // XP and Level Progress Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("LEVEL ${stats.level}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                          Text("${stats.xpCount} / ${(stats.level + 1) * 35} XP", style: const TextStyle(fontSize: 11, color: Colors.white54)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (stats.xpCount % 100) / 100,
                          minHeight: 6,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Achievements Title
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "ACHIEVEMENTS",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white30),
                ),
              ),
              const SizedBox(height: 12),

              // Achievements Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _buildAchievementCard("Streak Sailor", "Maintain 5 day streak", "🔥", true),
                  _buildAchievementCard("Code Master", "Earn 300+ XP points", "⚡", true),
                  _buildAchievementCard("First Island", "Complete Unit 1 goal", "🏝️", true),
                  _buildAchievementCard("Full Deck", "Unlock 10 milestones", "🃏", false),
                ],
              ),

              const SizedBox(height: 20),

              // 3. Learning Statistics Summary Card
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "LEARNING METRICS",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white30),
                ),
              ),
              const SizedBox(height: 12),

              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  children: [
                    _buildStatRow("Completed Lessons", "${stats?.completedGoalsCount ?? 0} modules", Icons.verified),
                    const Divider(color: Colors.white10, height: 20),
                    _buildStatRow("Time Logged", "14h 45m", Icons.timer),
                    const Divider(color: Colors.white10, height: 20),
                    _buildStatRow("Success Rate", "94% correct", Icons.speed),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const FloatingNavDock(activeIndex: 3),
    );
  }

  Widget _buildAchievementCard(String title, String desc, String icon, bool unlocked) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      color: unlocked ? Colors.orangeAccent.withOpacity(0.04) : Colors.white.withOpacity(0.02),
      border: Border.all(
        color: unlocked ? Colors.orangeAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              if (unlocked)
                const Icon(Icons.check_circle, color: Colors.orangeAccent, size: 14)
              else
                const Icon(Icons.lock, color: Colors.white24, size: 12),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: unlocked ? Colors.white : Colors.white38,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(fontSize: 9, color: Colors.white38),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.orangeAccent, size: 18),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}
