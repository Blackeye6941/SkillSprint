import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with TickerProviderStateMixin {
  late AnimationController _floatController;

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

  // CHARACTER DATA MAPPING
  Map<String, dynamic> getCharacterTheme(double progress) {
    int p = (progress * 100).toInt();
    if (p >= 100) return {'color': Colors.amber, 'img': 'assets/images/roger.png'};
    if (p >= 90) return {'color': Colors.redAccent, 'img': 'assets/images/luffy.png'};
    if (p >= 80) return {'color': Colors.greenAccent, 'img': 'https://i.ibb.co/zoro.png'};
    if (p >= 70) return {'color': Colors.blueAccent, 'img': 'https://i.ibb.co/sanji.png'};
    if (p >= 60) return {'color': Colors.blue, 'img': 'https://i.ibb.co/jinbe.png'};
    if (p >= 50) return {'color': Colors.purpleAccent, 'img': 'https://i.ibb.co/robin.png'};
    if (p >= 40) return {'color': Colors.cyanAccent, 'img': 'https://i.ibb.co/franky.png'};
    if (p >= 30) return {'color': Colors.white, 'img': 'https://i.ibb.co/brook.png'};
    if (p >= 20) return {'color': Colors.brown, 'img': 'https://i.ibb.co/usopp.png'};
    if (p >= 10) return {'color': Colors.pinkAccent, 'img': 'https://i.ibb.co/chopper.png'};
    return {'color': Colors.orangeAccent, 'img': 'https://i.ibb.co/nami.png'};
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> goals = [
      {'title': 'Master Flutter', 'progress': 0.92},
      {'title': 'UI/UX Design', 'progress': 0.15},
      {'title': 'DSA Mastery', 'progress': 0.82},
      {'title': 'Pirate King Goal', 'progress': 1.0},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF000814),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('LOGBOOK', style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.w900, color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          final double progress = goal['progress'];
          final theme = getCharacterTheme(progress);

          return AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              // Subtle "Sailing" motion for each card
              double offset = 5 * math.sin((_floatController.value + (index * 0.2)) * 2 * math.pi);
              
              return Transform.translate(
                offset: Offset(0, offset),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 25),
                  height: 110,
                  child: Stack(
                    children: [
                      // GLASS BACKGROUND CARD
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: theme['color'].withOpacity(0.3)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // CONTENT ROW
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            _buildProgressCharacter(progress, theme),
                            const SizedBox(width: 25),
                            Expanded(
                              child: Text(
                                goal['title'].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
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
          // GLOWING RING
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 5,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation(theme['color']),
          ),
          
          // CHARACTER CIRCLE
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
                )
              ],
            ),
            child: ClipOval(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    theme['img'],
                    fit: BoxFit.cover,
                    width: 65,
                    height: 65,
                    errorBuilder: (c, e, s) => Container(color: Colors.black26),
                  ),
                  // SEMI-TRANSPARENT PERCENTAGE OVERLAY
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    alignment: Alignment.center,
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
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