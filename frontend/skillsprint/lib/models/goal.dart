import 'package:flutter/material.dart';
import 'roadmap_step.dart';

class Goal {
  final String id;
  final String title;
  final double progress;
  final String category;
  final Color themeColor;
  final String description;
  final List<RoadmapStep> roadmap;

  Goal({
    required this.id,
    required this.title,
    required this.progress,
    required this.category,
    required this.themeColor,
    required this.description,
    required this.roadmap,
  });

  Goal copyWith({
    String? id,
    String? title,
    double? progress,
    String? category,
    Color? themeColor,
    String? description,
    List<RoadmapStep>? roadmap,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      progress: progress ?? this.progress,
      category: category ?? this.category,
      themeColor: themeColor ?? this.themeColor,
      description: description ?? this.description,
      roadmap: roadmap ?? this.roadmap,
    );
  }
}
