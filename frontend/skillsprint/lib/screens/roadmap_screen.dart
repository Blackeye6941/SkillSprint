import 'package:flutter/material.dart';
import 'dart:ui';

class RoadmapScreen extends StatelessWidget {
  final String goalTitle;
  final Color themeColor;

  const RoadmapScreen({
    super.key,
    required this.goalTitle,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    // Mock data for the roadmap phases
    final List<Map<String, String>> roadmapSteps = [
      {'title': 'The Beginning', 'desc': 'Master the basic syntax and environment setup.'},
      {'title': 'Building Foundation', 'desc': 'Understand core architecture and state management.'},
      {'title': 'The Grand Line', 'desc': 'Implement advanced animations and complex UI.'},
      {'title': 'New World', 'desc': 'Backend integration and performance optimization.'},
      {'title': 'Pirate King', 'desc': 'Launch the product and scale to global users.'},
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
        title: Text(
          goalTitle.toUpperCase(),
          style: TextStyle(
            color: themeColor,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Subtle background glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeColor.withOpacity(0.05),
              ),
            ),
          ),
          
          ListView.builder(
            padding: const EdgeInsets.all(25),
            itemCount: roadmapSteps.length,
            itemBuilder: (context, index) {
              return IntrinsicHeight(
                child: Row(
                  children: [
                    // TIMELINE LINE AND DOTS
                    Column(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: themeColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: themeColor.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                        ),
                        if (index != roadmapSteps.length - 1)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: themeColor.withOpacity(0.2),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    
                    // CONTENT CARD
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 30),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roadmapSteps[index]['title']!,
                              style: TextStyle(
                                color: themeColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              roadmapSteps[index]['desc']!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}