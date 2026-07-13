import 'package:flutter/material.dart';

class XpBadge extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color themeColor;

  const XpBadge({
    super.key,
    required this.count,
    required this.label,
    required this.icon,
    this.themeColor = Colors.orangeAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: themeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: themeColor, size: 15),
          const SizedBox(width: 4),
          Text(
            "$count $label",
            style: TextStyle(
              color: themeColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
