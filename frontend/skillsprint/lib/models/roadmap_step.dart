import 'package:flutter/material.dart';

class RoadmapStep {
  final String id;
  final String title;
  final String desc;
  final IconData icon;
  final String status; // 'completed', 'active', 'locked'
  final int completedSteps;
  final int totalSteps;

  RoadmapStep({
    required this.id,
    required this.title,
    required this.desc,
    required this.icon,
    required this.status,
    required this.completedSteps,
    required this.totalSteps,
  });

  RoadmapStep copyWith({
    String? id,
    String? title,
    String? desc,
    IconData? icon,
    String? status,
    int? completedSteps,
    int? totalSteps,
  }) {
    return RoadmapStep(
      id: id ?? this.id,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      icon: icon ?? this.icon,
      status: status ?? this.status,
      completedSteps: completedSteps ?? this.completedSteps,
      totalSteps: totalSteps ?? this.totalSteps,
    );
  }
}
