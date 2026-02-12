import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'roadmap_screen.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  Map<String, dynamic> getCharacterTheme(double progress) {
    int p = (progress * 100).toInt();
    if (p >= 100) {
      return {'color': Colors.amber, 'img': 'assets/images/roger.png'};
    }
    if (p >= 90) {
      return {'color': Colors.redAccent, 'img': 'assets/images/luffy.png'};
    }
    if (p >= 80) {
      return {'color': Colors.greenAccent, 'img': 'assets/images/zoro.png'};
    }
    if (p >= 70) {
      return {'color': Colors.blueAccent, 'img': 'assets/images/sanji.png'};
    }
    if (p >= 60) {
      return {'color': Colors.blue, 'img': 'assets/images/jinbe.png'};
    }
    if (p >= 50) {
      return {'color': Colors.purpleAccent, 'img': 'assets/images/robin.png'};
    }
    if (p >= 40) {
      return {'color': Colors.white, 'img': 'assets/images/brook.png'};
    }
    if (p >= 30) {
      return {'color': Colors.cyanAccent, 'img': 'assets/images/franky.png'};
    }
    if (p >= 20) {
      return {'color': Colors.brown, 'img': 'assets/images/ussop.png'};
    }
    if (p >= 10) {
      return {'color': Colors.pinkAccent, 'img': 'assets/images/chopper.png'};
    }
    return {'color': Colors.orangeAccent, 'img': 'assets/images/nami.png'};
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> goals = [
      {'title': 'Master Flutter', 'progress': 0.05},
      {'title': 'UI/UX Design', 'progress': 0.15},
      {'title': 'Backend Integration', 'progress': 0.35},
      {'title': 'DSA Mastery', 'progress': 0.25},
      {'title': 'Open Source Contribution', 'progress': 0.45},
      {'title': 'Mobile App Launch', 'progress': 0.65},
      {'title': 'Community Building', 'progress': 0.85},
      {'title': 'Tech Blogging', 'progress': 0.95},
      {'title': 'Mentorship', 'progress': 0.55},
      {'title': 'Global Recognition', 'progress': 0.75},
      {'title': 'Pirate King Goal', 'progress': 1.0},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF000814),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'PROGRESS',
          style: TextStyle(
            letterSpacing: 4,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          final double progress = goal['progress'];
          final theme = getCharacterTheme(progress);
          final bool isHovered = _hoveredIndex == index;

          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = null),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoadmapScreen(
                      goalTitle: goal['title'],
                      themeColor: theme['color'],
                    ),
                  ),
                );
              },
              child: AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  double offset =
                      5 *
                      math.sin(
                        (_floatController.value + (index * 0.2)) * 2 * math.pi,
                      );

                  return Transform.translate(
                    offset: Offset(0, offset),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 25),
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: isHovered
                            ? LinearGradient(
                                colors: [
                                  theme['color'].withOpacity(0.2),
                                  theme['color'].withOpacity(0.05),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isHovered
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: isHovered
                                          ? theme['color']
                                          : theme['color'].withOpacity(0.3),
                                      width: isHovered ? 2 : 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                _buildProgressCharacter(progress, theme),
                                const SizedBox(width: 25),
                                Expanded(
                                  child: Text(
                                    goal['title'].toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isHovered ? 19 : 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressCharacter(double progress, Map<String, dynamic> theme) {
    return SizedBox(
      width: 85,
      height: 85,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 5,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation(theme['color']),
          ),
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme['color'].withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    theme['img'],
                    width: 65,
                    height: 65,
                    fit: BoxFit.cover,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 22,
                      color: Colors.black.withOpacity(0.55),
                      alignment: Alignment.center,
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
