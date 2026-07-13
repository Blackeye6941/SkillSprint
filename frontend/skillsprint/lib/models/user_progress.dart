class UserProgress {
  final int dailyStreak;
  final int xpCount;
  final int completedGoalsCount;
  final int level;
  final double dailyProgress;

  UserProgress({
    required this.dailyStreak,
    required this.xpCount,
    required this.completedGoalsCount,
    required this.level,
    required this.dailyProgress,
  });

  UserProgress copyWith({
    int? dailyStreak,
    int? xpCount,
    int? completedGoalsCount,
    int? level,
    double? dailyProgress,
  }) {
    return UserProgress(
      dailyStreak: dailyStreak ?? this.dailyStreak,
      xpCount: xpCount ?? this.xpCount,
      completedGoalsCount: completedGoalsCount ?? this.completedGoalsCount,
      level: level ?? this.level,
      dailyProgress: dailyProgress ?? this.dailyProgress,
    );
  }
}
