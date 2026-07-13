import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';
import '../screens/goals_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';

class FloatingNavDock extends StatelessWidget {
  final int activeIndex;

  const FloatingNavDock({
    super.key,
    required this.activeIndex,
  });

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 180),
    );
  }

  void _navigateToIndex(BuildContext context, int index) {
    if (index == activeIndex) return;

    Widget targetPage;
    switch (index) {
      case 0:
        targetPage = const ChatScreen();
        break;
      case 1:
        targetPage = const GoalsScreen();
        break;
      case 2:
        targetPage = const StatisticsScreen();
        break;
      case 3:
        targetPage = const ProfileScreen();
        break;
      case 4:
        targetPage = const SettingsScreen();
        break;
      default:
        return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      _createRoute(targetPage),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF141414).withOpacity(0.85),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildItem(context, 0, Icons.home_outlined, Icons.home),
          _buildItem(context, 1, Icons.explore_outlined, Icons.explore),
          _buildItem(context, 2, Icons.analytics_outlined, Icons.analytics),
          _buildItem(context, 3, Icons.person_outline, Icons.person),
          _buildItem(context, 4, Icons.settings_outlined, Icons.settings),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, IconData outlineIcon, IconData solidIcon) {
    final bool isActive = index == activeIndex;
    return GestureDetector(
      onTap: () => _navigateToIndex(context, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? Colors.orangeAccent.withOpacity(0.12) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isActive ? solidIcon : outlineIcon,
          color: isActive ? Colors.orangeAccent : Colors.white70,
          size: 24,
        ),
      ),
    );
  }
}
