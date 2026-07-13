import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/app_provider.dart';
import '../models/goal.dart';
import '../models/roadmap_step.dart';

class RoadmapScreen extends StatefulWidget {
  final String goalTitle;
  final Color themeColor;
  final double progress;

  const RoadmapScreen({
    super.key,
    required this.goalTitle,
    required this.themeColor,
    required this.progress,
  });

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> with TickerProviderStateMixin {
  int? _selectedLessonIndex;
  final List<int> _mascotQuoteIndices = [0, 0, 0];

  late AnimationController _pulseController;
  late AnimationController _bobController;

  final double startY = 180.0;
  final double lessonGap = 220.0;
  final double unitSpacing = 280.0;

  // Realistic Captain Mascot quotes
  final List<String> _captainQuotes = [
    "Ahoy! Keep sailing down this path! ⛵",
    "We're making great progress, matey! Focus on the next lesson! ⚔️",
    "A clean codebase is a happy ship! Let's code! 💻",
    "No bugs can stop this captain! Onward! 🌊",
    "You're doing amazing! The treasure of mastery is close! 💎",
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _bobController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bobController.dispose();
    super.dispose();
  }

  // Winding mathematical function with increased width to cover more space
  double _getX(double y, double width) {
    double amplitude = math.min(width * 0.32, 130.0);
    return width / 2 + amplitude * math.sin(y / 140);
  }

  // Calculates the Y position of a lesson node at a given index
  double getLessonY(int index) {
    int u = index ~/ 3; // Unit index
    int k = index % 3;  // Lesson index within unit
    return startY + u * (3 * lessonGap + unitSpacing) + k * lessonGap;
  }

  // Helper to fallback-generate steps if the provider doesn't have populated roadmap items
  List<RoadmapStep> _fallbackRoadmap(String title) {
    String t = title.toLowerCase();
    List<Map<String, dynamic>> lessonData = [];
    
    if (t.contains('design') || t.contains('ux')) {
      lessonData = [
        {'title': 'Typography Hierarchy', 'desc': 'Select fonts, sizes, and weights for readability.', 'icon': Icons.text_fields},
        {'title': 'Color Harmonies', 'desc': 'Understand contrast, palettes, branding, and color psychology.', 'icon': Icons.color_lens},
        {'title': 'Grid Systems', 'desc': 'Align items perfectly across different screen breakpoints.', 'icon': Icons.grid_on},
        {'title': 'User Personas', 'desc': 'Define target audiences and document user goals.', 'icon': Icons.people},
        {'title': 'User Flow Mapping', 'desc': 'Diagram pathways users take to accomplish key actions.', 'icon': Icons.map},
        {'title': 'Low-Fi Wireframes', 'desc': 'Sketch layout skeletons without style details.', 'icon': Icons.draw},
        {'title': 'High-Fi Prototyping', 'desc': 'Add interactions, transitions, and realistic details.', 'icon': Icons.layers},
        {'title': 'Micro-interactions', 'desc': 'Design subtle response animations for actions.', 'icon': Icons.ads_click},
        {'title': 'Usability Testing', 'desc': 'Observe real users interacting with your prototypes.', 'icon': Icons.rule},
      ];
    } else {
      lessonData = [
        {'title': 'Introduction', 'desc': 'Overview of core concepts and environment setup.', 'icon': Icons.star_border},
        {'title': 'Syntax Basics', 'desc': 'Variables, data types, and simple operations.', 'icon': Icons.article},
        {'title': 'Control Flow', 'desc': 'If statements, loops, and conditional logic.', 'icon': Icons.alt_route},
        {'title': 'Functions & Scope', 'desc': 'Write modular, reusable code blocks and handle arguments.', 'icon': Icons.functions},
        {'title': 'Collections', 'desc': 'Store lists, arrays, maps, and sets.', 'icon': Icons.list_alt},
        {'title': 'Error Handling', 'desc': 'Catch exceptions and prevent application crashes.', 'icon': Icons.bug_report},
        {'title': 'Asynchronous Code', 'desc': 'Handle future promises and parallel async/await tasks.', 'icon': Icons.hourglass_empty},
        {'title': 'Performance Tips', 'desc': 'Optimize memory and speed up processing.', 'icon': Icons.speed},
        {'title': 'Final Capstone', 'desc': 'Combine all knowledge in a master project.', 'icon': Icons.emoji_events},
      ];
    }

    return List.generate(9, (index) {
      String status = index == 0 ? 'active' : 'locked';
      return RoadmapStep(
        id: 'fallback_$index',
        title: lessonData[index]['title'],
        desc: lessonData[index]['desc'],
        icon: lessonData[index]['icon'],
        status: status,
        completedSteps: 0,
        totalSteps: 3,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final int totalLessons = 9;
    
    // Read centralized provider state
    final provider = Provider.of<AppProvider>(context);
    
    // Find the goal in provider list to bind dynamically
    final Goal targetGoal = provider.filteredGoals.firstWhere(
      (g) => g.title == widget.goalTitle,
      orElse: () => Goal(
        id: 'unknown',
        title: widget.goalTitle,
        progress: widget.progress,
        category: 'Learning',
        themeColor: widget.themeColor,
        description: 'Explore custom milestones.',
        roadmap: _fallbackRoadmap(widget.goalTitle),
      ),
    );

    // Compute progress details
    final List<RoadmapStep> roadmap = targetGoal.roadmap.isNotEmpty
        ? targetGoal.roadmap
        : _fallbackRoadmap(widget.goalTitle);
        
    final int completedCount = roadmap.where((s) => s.status == 'completed').length;
    final double overallProgress = roadmap.isEmpty ? 0.0 : (completedCount / roadmap.length);

    // Height of total stack scroll
    final double totalHeight = getLessonY(totalLessons - 1) + 200.0;

    return Scaffold(
      backgroundColor: const Color(0xFF070707),
      body: Stack(
        children: [
          // 1. SCROLLABLE CONTAINER
          GestureDetector(
            onTap: () {
              if (_selectedLessonIndex != null) {
                setState(() => _selectedLessonIndex = null);
              }
            },
            child: SingleChildScrollView(
              child: SizedBox(
                height: totalHeight,
                child: Stack(
                  children: [
                    // A. PATHWAY CONNECTING LINE
                    CustomPaint(
                      size: Size(screenWidth, totalHeight),
                      painter: PathPainter(
                        screenWidth: screenWidth,
                        nodeCount: totalLessons,
                        gap: lessonGap,
                        unitSpacing: unitSpacing,
                        startY: startY,
                        completedProgressIndex: completedCount,
                      ),
                    ),

                    // B. UNIT HEADERS
                    ...List.generate(3, (uIndex) {
                      double yUnit = getLessonY(uIndex * 3) - 130.0;
                      
                      String unitTitle = "UNIT ${uIndex + 1}";
                      String unitDesc = "Master the core concepts of milestones ${uIndex * 3 + 1} to ${uIndex * 3 + 3}.";
                      if (widget.goalTitle.toLowerCase().contains('flutter')) {
                        if (uIndex == 0) {
                          unitTitle = "Flutter Foundations";
                          unitDesc = "Learn widget trees, stateless composition, and basics.";
                        } else if (uIndex == 1) {
                          unitTitle = "Layouts & Gestures";
                          unitDesc = "Master Columns, rows, containers, and taps.";
                        } else {
                          unitTitle = "State & Navigation";
                          unitDesc = "Push route stacks, set local states, and build themes.";
                        }
                      }

                      final Map<String, dynamic> unit = {
                        'number': uIndex + 1,
                        'title': unitTitle,
                        'description': unitDesc,
                      };

                      return Positioned(
                        top: yUnit,
                        left: 16,
                        right: 16,
                        child: _buildUnitCard(unit),
                      );
                    }),

                    // C. PATHWAY NODES (LESSONS)
                    ...List.generate(totalLessons, (index) {
                      double yPos = getLessonY(index);
                      double xPos = _getX(yPos, screenWidth) - 43.0; // centered offset

                      final lesson = roadmap[index];
                      final status = lesson.status;
                      double lessonProgress = (status == 'active') ? 0.66 : 0.0;

                      return Positioned(
                        top: yPos,
                        left: xPos,
                        child: LessonNode(
                          icon: lesson.icon,
                          status: status,
                          lessonProgress: lessonProgress,
                          themeColor: widget.themeColor,
                          pulseAnimation: _pulseController,
                          onTap: () {
                            setState(() {
                              _selectedLessonIndex = index;
                            });
                          },
                        ),
                      );
                    }),

                    // D. SAILING SHIP (TRAVELING BETWEEN ISLANDS)
                    _buildSailingShip(completedCount, screenWidth),

                    // E. CAPTAIN MASCOTS (ON THE SIDES, MIDWAY BETWEEN LESSONS)
                    _buildMascot(0, (getLessonY(0) + getLessonY(1)) / 2, screenWidth),
                    _buildMascot(1, (getLessonY(3) + getLessonY(4)) / 2, screenWidth),
                    _buildMascot(2, (getLessonY(6) + getLessonY(7)) / 2, screenWidth),

                    // F. POPUP DETAILS TOOLTIP
                    if (_selectedLessonIndex != null)
                      _buildTooltip(targetGoal, roadmap[_selectedLessonIndex!], _selectedLessonIndex!, screenWidth, provider),
                  ],
                ),
              ),
            ),
          ),

          // 2. STICKY TOP STATUS APP BAR
          _buildStatusBar(completedCount, totalLessons, overallProgress),
        ],
      ),
    );
  }

  Widget _buildUnitCard(Map<String, dynamic> unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "UNIT ${unit['number']}",
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  unit['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unit['description'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // View Guidebook Button
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.orange,
                  content: Text(
                    "Opening Guidebook for Unit ${unit['number']}! 📖",
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(
                Icons.menu_book,
                color: Colors.orangeAccent,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Renders a realistic captain avatar image with response quotes
  Widget _buildMascot(int mascotIndex, double yPos, double screenWidth) {
    double pathX = _getX(yPos, screenWidth);
    double center = screenWidth / 2;
    bool isLeft = pathX > center; // if path is right, mascot goes to the left side

    String quote = _captainQuotes[_mascotQuoteIndices[mascotIndex] % _captainQuotes.length];

    return Positioned(
      top: yPos,
      left: isLeft ? 24 : null,
      right: !isLeft ? 24 : null,
      child: AnimatedBuilder(
        animation: _bobController,
        builder: (context, child) {
          double bobOffset = 5 * _bobController.value;
          return Transform.translate(
            offset: Offset(0, bobOffset),
            child: Column(
              crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                // Speech bubble
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _mascotQuoteIndices[mascotIndex]++;
                    });
                  },
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orangeAccent.withOpacity(0.3), width: 1.5),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Text(
                          quote,
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                        // Beak pointer
                        Positioned(
                          bottom: -13,
                          left: isLeft ? 15 : null,
                          right: !isLeft ? 15 : null,
                          child: Transform.rotate(
                            angle: math.pi / 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                border: Border(
                                  right: BorderSide(color: Colors.orangeAccent.withOpacity(0.3), width: 1.5),
                                  bottom: BorderSide(color: Colors.orangeAccent.withOpacity(0.3), width: 1.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Floating Captain mascot avatar with realistic shadow
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _mascotQuoteIndices[mascotIndex]++;
                    });
                  },
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Floating shadow under character
                        Positioned(
                          bottom: -2,
                          child: Container(
                            width: 44,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.all(Radius.elliptical(22, 3)),
                            ),
                          ),
                        ),
                        // Realistic Captain Mascot Image
                        ClipOval(
                          child: Image.asset(
                            'assets/images/captain_mascot.jpg',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                color: Colors.orangeAccent,
                                child: const Icon(Icons.person, color: Colors.black),
                              );
                            },
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
    );
  }

  // Renders a bobbing pirate ship sailing dynamically on the pathway between islands
  Widget _buildSailingShip(int completedCount, double screenWidth) {
    double shipY;
    
    if (completedCount == 0) {
      // Anchored at first lesson
      shipY = getLessonY(0);
    } else if (completedCount >= 9) {
      // Anchored at final lesson
      shipY = getLessonY(8);
    } else {
      // Sails exactly midway/60% between previous completed lesson and current active lesson
      double prevY = getLessonY(completedCount - 1);
      double nextY = getLessonY(completedCount);
      shipY = prevY + (nextY - prevY) * 0.60;
    }
    
    double shipX = _getX(shipY, screenWidth);

    return Positioned(
      top: shipY - 30.0,
      left: shipX - 30.0,
      child: AnimatedBuilder(
        animation: _bobController,
        builder: (context, child) {
          double bob = 5 * _bobController.value;
          // Rotate ship relative to the slope of path
          double tilt = 0.08 * math.cos((shipY + bob) / 40);
          
          return Transform.translate(
            offset: Offset(0, bob),
            child: Transform.rotate(
              angle: tilt,
              child: SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Shadow under the ship
                    Positioned(
                      bottom: -4,
                      child: Container(
                        width: 46,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.all(Radius.elliptical(23, 4)),
                        ),
                      ),
                    ),
                    // Background-free pirate ship blending into black theme background
                    Image.asset(
                      'assets/images/pirate_ship.png',
                      width: 52,
                      height: 52,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.brown.shade800,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.directions_boat, color: Colors.white),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTooltip(Goal targetGoal, RoadmapStep lesson, int selectedIndex, double screenWidth, AppProvider provider) {
    int unitIndex = selectedIndex ~/ 3;
    int lessonIndexInUnit = selectedIndex % 3;
    final status = lesson.status;

    double nodeY = getLessonY(selectedIndex);
    double nodeX = _getX(nodeY, screenWidth);

    bool showAbove = selectedIndex >= 2;
    double tooltipWidth = 250.0;
    double tooltipHeight = 150.0;

    double tooltipY = showAbove ? nodeY - tooltipHeight - 15 : nodeY + 90;
    double tooltipX = (nodeX - tooltipWidth / 2 + 40.0).clamp(16.0, screenWidth - tooltipWidth - 16.0);

    double nodeCenterAbsolute = nodeX + 40.0;
    double beakX = (nodeCenterAbsolute - tooltipX - 8.0).clamp(15.0, tooltipWidth - 30.0);

    String startButtonText = "START";
    if (status == 'completed') {
      startButtonText = "PRACTICE";
    } else if (status == 'active') {
      startButtonText = "CONTINUE";
    }

    return Positioned(
      top: tooltipY,
      left: tooltipX,
      child: Container(
        width: tooltipWidth,
        height: tooltipHeight,
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orangeAccent.withOpacity(0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "UNIT ${unitIndex + 1} • LESSON ${lessonIndexInUnit + 1}",
                          style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _selectedLessonIndex = null),
                        child: const Icon(Icons.close, color: Colors.white54, size: 16),
                      ),
                    ],
                  ),
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    lesson.desc,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 10.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (status == 'active')
                    const Text(
                      "Progress: 2/3 Steps Completed",
                      style: TextStyle(color: Colors.white54, fontSize: 9.5, fontStyle: FontStyle.italic),
                    ),
                  if (status == 'completed')
                    const Text(
                      "Status: Completed!",
                      style: TextStyle(color: Colors.greenAccent, fontSize: 9.5, fontWeight: FontWeight.bold),
                    ),
                  _build3DStartButton(targetGoal, lesson, startButtonText, status, provider),
                ],
              ),
            ),
            // Triangle beak pointing to the node
            Positioned(
              top: showAbove ? null : -9,
              bottom: showAbove ? -9 : null,
              left: beakX,
              child: Transform.rotate(
                angle: math.pi / 4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    border: Border(
                      top: showAbove ? BorderSide.none : BorderSide(color: Colors.orangeAccent.withOpacity(0.6), width: 2),
                      left: showAbove ? BorderSide.none : BorderSide(color: Colors.orangeAccent.withOpacity(0.6), width: 2),
                      bottom: showAbove ? BorderSide(color: Colors.orangeAccent.withOpacity(0.6), width: 2) : BorderSide.none,
                      right: showAbove ? BorderSide(color: Colors.orangeAccent.withOpacity(0.6), width: 2) : BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DStartButton(Goal targetGoal, RoadmapStep lesson, String text, String status, AppProvider provider) {
    bool isPressed = false;
    return StatefulBuilder(
      builder: (context, setBtnState) {
        return GestureDetector(
          onTapDown: (_) => setBtnState(() => isPressed = true),
          onTapUp: (_) => setBtnState(() => isPressed = false),
          onTapCancel: () => setBtnState(() => isPressed = false),
          onTap: () {
            setState(() {
              _selectedLessonIndex = null;
            });
            if (status == 'active') {
              // Write to provider: completes the step and unlocks the next one!
              provider.completeRoadmapStep(targetGoal.id, lesson.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.orangeAccent,
                  content: Text(
                    "Milestone completed! +25 XP, next unit unlocked! 🏆",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.orangeAccent,
                  content: Text(
                    status == 'completed'
                        ? "Starting practice mode! Let's review ⛵"
                        : "Sailing path is locked! Complete active lessons first. 🔒",
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }
          },
          child: SizedBox(
            height: 34,
            child: Stack(
              children: [
                // Bottom Shadow
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCC7200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                // Top Face
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 60),
                  top: isPressed ? 4 : 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9100),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBar(int completedCount, int totalLessons, double progress) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(top: 50, bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F0F), // Premium solid dark background
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.06),
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Back Button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  // Course Title
                  Expanded(
                    child: Text(
                      widget.goalTitle.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // XP / Streak Flame
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 16),
                            const SizedBox(width: 3),
                            Text(
                              "${(progress * 150).toInt()} XP",
                              style: const TextStyle(
                                color: Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Hearts Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite, color: Color(0xFFFF4B4B), size: 16),
                            SizedBox(width: 3),
                            Text(
                              "5",
                              style: TextStyle(
                                color: Color(0xFFFF4B4B),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Horizontal course progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Stack(
                    children: [
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orangeAccent.withOpacity(0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
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
  }
}

class PathPainter extends CustomPainter {
  final double screenWidth;
  final int nodeCount;
  final double gap;
  final double unitSpacing;
  final double startY;
  final int completedProgressIndex;

  PathPainter({
    required this.screenWidth,
    required this.nodeCount,
    required this.gap,
    required this.unitSpacing,
    required this.startY,
    required this.completedProgressIndex,
  });

  double _getX(double y, double width) {
    double amplitude = math.min(width * 0.32, 130.0);
    return width / 2 + amplitude * math.sin(y / 140);
  }

  double getLessonY(int index) {
    int u = index ~/ 3;
    int k = index % 3;
    return startY + u * (3 * gap + unitSpacing) + k * gap;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double totalHeight = getLessonY(nodeCount - 1);

    final Paint bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final Paint fgPaint = Paint()
      ..color = Colors.orangeAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    // Draw background gray line for entire path
    Path bgPath = Path();
    bgPath.moveTo(_getX(startY, screenWidth), startY);
    for (double y = startY; y <= totalHeight; y += 4) {
      bgPath.lineTo(_getX(y, screenWidth), y);
    }
    canvas.drawPath(bgPath, bgPaint);

    // Draw active orange line up to active node index
    int activeIndex = completedProgressIndex.clamp(0, nodeCount - 1);
    double activeY = getLessonY(activeIndex);

    Path fgPath = Path();
    fgPath.moveTo(_getX(startY, screenWidth), startY);
    for (double y = startY; y <= activeY; y += 4) {
      fgPath.lineTo(_getX(y, screenWidth), y);
    }
    canvas.drawPath(fgPath, fgPaint);
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    return oldDelegate.completedProgressIndex != completedProgressIndex ||
        oldDelegate.screenWidth != screenWidth;
  }
}

class LessonNode extends StatefulWidget {
  final IconData icon;
  final String status;
  final double lessonProgress;
  final Color themeColor;
  final VoidCallback onTap;
  final Animation<double> pulseAnimation;

  const LessonNode({
    super.key,
    required this.icon,
    required this.status,
    required this.lessonProgress,
    required this.themeColor,
    required this.onTap,
    required this.pulseAnimation,
  });

  @override
  State<LessonNode> createState() => _LessonNodeState();
}

class _LessonNodeState extends State<LessonNode> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    bool isCompleted = widget.status == 'completed';
    bool isActive = widget.status == 'active';
    bool isLocked = widget.status == 'locked';

    Color faceColor = isLocked
        ? const Color(0xFF262626)
        : (isCompleted || isActive ? const Color(0xFFFF9100) : widget.themeColor);

    Color shadowColor = isLocked
        ? const Color(0xFF161616)
        : (isCompleted || isActive ? const Color(0xFFCC7200) : widget.themeColor.withOpacity(0.7));

    IconData displayIcon = isCompleted
        ? Icons.check
        : (isLocked ? Icons.lock : widget.icon);

    Color iconColor = isLocked ? const Color(0xFF555555) : Colors.black;

    double buttonSize = 70.0;
    double progressRingSize = 86.0;

    return GestureDetector(
      onTapDown: (_) {
        if (!isLocked) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (!isLocked) setState(() => _isPressed = false);
      },
      onTapCancel: () {
        if (!isLocked) setState(() => _isPressed = false);
      },
      onTap: isLocked ? null : widget.onTap,
      child: SizedBox(
        width: progressRingSize,
        height: progressRingSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. PULSING RING FOR ACTIVE NODE
            if (isActive)
              AnimatedBuilder(
                animation: widget.pulseAnimation,
                builder: (context, child) {
                  double scale = 1.0 + (widget.pulseAnimation.value * 0.08);
                  double opacity = 0.8 - (widget.pulseAnimation.value * 0.5);
                  return Container(
                    width: progressRingSize,
                    height: progressRingSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.orangeAccent.withOpacity(opacity.clamp(0.0, 1.0)),
                        width: 4,
                      ),
                    ),
                    transform: Matrix4.identity()..scale(scale),
                  );
                },
              ),

            // 2. ACTIVE NODE PROGRESS TRACK
            if (isActive && widget.lessonProgress > 0)
              SizedBox(
                width: progressRingSize - 4,
                height: progressRingSize - 4,
                child: CircularProgressIndicator(
                  value: widget.lessonProgress,
                  strokeWidth: 4,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                ),
              ),

            // 3. 3D INTERACTIVE BUTTON
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: Stack(
                children: [
                  // Bottom Shadow
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: buttonSize - 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: shadowColor,
                      ),
                    ),
                  ),
                  // Top Face
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 60),
                    top: _isPressed ? 6 : 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: buttonSize - 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: faceColor,
                        boxShadow: [
                          if (!isLocked && !_isPressed)
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Icon(
                        displayIcon,
                        color: iconColor,
                        size: 28,
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
  }
}