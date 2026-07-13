import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/floating_nav_dock.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final stats = provider.progress;

    // Hardcoded weekly activity heights representing XP earned each day
    final List<Map<String, dynamic>> weeklyXP = [
      {'day': 'Mon', 'xp': 40},
      {'day': 'Tue', 'xp': 80},
      {'day': 'Wed', 'xp': 25},
      {'day': 'Thu', 'xp': 95},
      {'day': 'Fri', 'xp': 50},
      {'day': 'Sat', 'xp': 110},
      {'day': 'Sun', 'xp': 75},
    ];

    double maxXP = 120.0;

    return Scaffold(
      backgroundColor: const Color(0xFF070707),
      appBar: AppBar(
        title: const Text('ANALYTICS & METRICS'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // 1. Weekly Activity Chart Card
              const Text(
                "WEEKLY ACTIVITY (XP GAINED)",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white30),
              ),
              const SizedBox(height: 10),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Weekly Performance", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text("Avg: 67 XP/day", style: TextStyle(fontSize: 11, color: Colors.orangeAccent)),
                      ],
                    ),
                    const SizedBox(height: 25),
                    // Custom Bar Chart using Containers & Gradient Styling
                    SizedBox(
                      height: 140,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: weeklyXP.map((data) {
                          double factor = data['xp'] / maxXP;
                          double barHeight = (140 * factor).clamp(10.0, 140.0);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "${data['xp']}",
                                style: const TextStyle(fontSize: 9, color: Colors.white38),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 22,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFCC7200), Color(0xFFFF9100)],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orangeAccent.withOpacity(0.2),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data['day'],
                                style: const TextStyle(fontSize: 10, color: Colors.white70),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Category Completion Breakdown
              const Text(
                "COMPLETION BY CATEGORY",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white30),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          const ProgressRing(progress: 0.65, size: 60, strokeWidth: 4, color: Colors.orangeAccent),
                          const SizedBox(height: 8),
                          const Text("Coding", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          Text("Level ${stats?.level ?? 12}", style: const TextStyle(fontSize: 10, color: Colors.white38)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: const [
                          ProgressRing(progress: 0.25, size: 60, strokeWidth: 4, color: Colors.purpleAccent),
                          SizedBox(height: 8),
                          Text("UI Design", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          Text("Level 3", style: TextStyle(fontSize: 10, color: Colors.white38)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: const [
                          ProgressRing(progress: 0.40, size: 60, strokeWidth: 4, color: Colors.blueAccent),
                          SizedBox(height: 8),
                          Text("Algorithms", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          Text("Level 5", style: TextStyle(fontSize: 10, color: Colors.white38)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 3. Overall Sailor Achievements Card
              const Text(
                "TOTAL MILESTONES SECURED",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white30),
              ),
              const SizedBox(height: 10),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.stars, color: Colors.orangeAccent, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("PRO PIRATE DEVELOPER", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            "You completed ${stats?.completedGoalsCount ?? 2} goals in total and unlocked 14 intermediate learning steps!",
                            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6), height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const FloatingNavDock(activeIndex: 2),
    );
  }
}
