import 'package:coin_toss/views/Screens/game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserProgressManager {
  static const String _progressKey = 'user_progress_v1';

  // Singleton pattern to ensure single instance
  static final UserProgressManager _instance = UserProgressManager._internal();
  factory UserProgressManager() => _instance;
  UserProgressManager._internal();

  // Persistent user progress data
  UserProgress? _currentProgress;

  // Getter for current progress with improved null handling
  UserProgress get currentProgress {
    if (_currentProgress == null) {
      try {
        loadProgress();
      } catch (e) {
        print('Error loading progress in getter: $e');
        _currentProgress = UserProgress();
      }
    }
    return _currentProgress ?? UserProgress();
  }

  // Load progress from local storage with enhanced error handling
  Future<void> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_progressKey);

      if (progressJson != null) {
        try {
          final Map<String, dynamic> decodedJson = json.decode(progressJson);
          _currentProgress = UserProgress.fromJson(decodedJson);
        } catch (e) {
          print('Error parsing user progress JSON: $e');
          _currentProgress = UserProgress();
        }
      } else {
        _currentProgress = UserProgress();
      }
    } catch (e) {
      print('Unexpected error loading user progress: $e');
      _currentProgress = UserProgress();
    }
  }

  // Save progress to local storage with error handling
  Future<void> saveProgress(UserProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_progressKey, json.encode(progress.toJson()));
      _currentProgress = progress;
    } catch (e) {
      print('Error saving user progress: $e');
    }
  }

  // Reset progress with error handling
  Future<void> resetProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_progressKey);
      _currentProgress = UserProgress();
    } catch (e) {
      print('Error resetting user progress: $e');
    }
  }
}

class UserProgress {
  int totalGamesPlayed = 0;
  int totalScore = 0;
  int highestConsecutiveStreak = 0;
  Map<String, DifficultyProgress> difficultyProgress;

  List<Achievement> unlockedAchievements;

  // Constructor with optional parameters
  UserProgress({
    this.totalGamesPlayed = 0,
    this.totalScore = 0,
    this.highestConsecutiveStreak = 0,
    Map<String, DifficultyProgress>? difficultyProgress,
    List<Achievement>? unlockedAchievements,
  })  : difficultyProgress = difficultyProgress ?? {
          'Easy': DifficultyProgress(),
          'Medium': DifficultyProgress(),
          'Hard': DifficultyProgress(),
        },
        unlockedAchievements = unlockedAchievements ?? [];

  // Update progress method with additional validation
  void updateProgress({
    required String difficulty, 
    required int gameScore, 
    required int consecutiveAnswers
  }) {
    totalGamesPlayed++;
    totalScore += gameScore;

    // Ensure difficulty exists before updating
    difficultyProgress.putIfAbsent(difficulty, () => DifficultyProgress());
    difficultyProgress[difficulty]?.updateProgress(
      gameScore: gameScore, 
      consecutiveAnswers: consecutiveAnswers
    );

    if (consecutiveAnswers > highestConsecutiveStreak) {
      highestConsecutiveStreak = consecutiveAnswers;
    }

    checkAchievements();
  }

  // JSON serialization methods
  Map<String, dynamic> toJson() {
    return {
      'totalGamesPlayed': totalGamesPlayed,
      'totalScore': totalScore,
      'highestConsecutiveStreak': highestConsecutiveStreak,
      'difficultyProgress': {
        for (var entry in difficultyProgress.entries)
          entry.key: entry.value.toJson()
      },
      'unlockedAchievements': unlockedAchievements
          .map((achievement) => {
            'id': achievement.id,
            'name': achievement.name,
            'description': achievement.description,
          })
          .toList(),
    };
  }

  // JSON deserialization constructor with improved error handling
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    try {
      return UserProgress(
        totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
        totalScore: json['totalScore'] ?? 0,
        highestConsecutiveStreak: json['highestConsecutiveStreak'] ?? 0,
        difficultyProgress: (json['difficultyProgress'] as Map?)?.map(
          (key, value) => MapEntry(
            key, 
            DifficultyProgress.fromJson(value ?? {})
          )
        ) ?? {
          'Easy': DifficultyProgress(),
          'Medium': DifficultyProgress(),
          'Hard': DifficultyProgress(),
        },
        unlockedAchievements: (json['unlockedAchievements'] as List?)
            ?.map((achievementJson) => Achievement(
                  id: achievementJson['id'] ?? '',
                  name: achievementJson['name'] ?? '',
                  description: achievementJson['description'] ?? '',
                  condition: () => true, // Placeholder condition
                ))
            .toList() ?? [],
      );
    } catch (e) {
      print('Error in UserProgress.fromJson: $e');
      return UserProgress();
    }
  }

  // Get user's overall rank with fallback
  String getOverallRank() {
    try {
      int totalMasteryScore = difficultyProgress.values
        .map((progress) => progress.masteryLevel)
        .fold(0, (a, b) => a + b);

      if (totalMasteryScore >= 15) return '🌟 BRAIN STORM LEGEND 🌟';
      if (totalMasteryScore >= 10) return '🚀 MASTER MIND';
      if (totalMasteryScore >= 5) return '💡 INTELLECTUAL';
      return '🆕 BRAIN TRAINEE';
    } catch (e) {
      print('Error calculating overall rank: $e');
      return '🆕 BRAIN TRAINEE';
    }
  }

  // Check and unlock new achievements with improved error handling
  void checkAchievements() {
    try {
      final possibleAchievements = [
        Achievement(
          id: 'first_master',
          name: 'First Master',
          description: 'Complete a difficulty level with max consecutive answers',
          condition: () => difficultyProgress.values.any((progress) => 
            progress.maxMasteryAchieved)
        ),
        Achievement(
          id: 'total_score_milestone',
          name: 'Score Champion',
          description: 'Reach a total score of 1000',
          condition: () => totalScore >= 1000
        ),
        Achievement(
          id: 'multi_difficulty_master',
          name: 'Versatile Genius',
          description: 'Master all difficulty levels',
          condition: () => difficultyProgress.values.every((progress) => 
            progress.maxMasteryAchieved)
        )
      ];

      // Add newly unlocked achievements
      for (var achievement in possibleAchievements) {
        if (achievement.condition() && 
            !unlockedAchievements.any((a) => a.id == achievement.id)) {
          unlockedAchievements.add(achievement);
        }
      }
    } catch (e) {
      print('Error checking achievements: $e');
    }
  }
}

class DifficultyProgress {
  int gamesPlayed = 0;
  int totalScore = 0;
  int highestConsecutiveStreak = 0;
  int masteryLevel = 0;
  bool maxMasteryAchieved = false;

  // Constructor with optional parameters
  DifficultyProgress({
    this.gamesPlayed = 0,
    this.totalScore = 0,
    this.highestConsecutiveStreak = 0,
    this.masteryLevel = 0,
    this.maxMasteryAchieved = false,
  });

  void updateProgress({
    required int gameScore, 
    required int consecutiveAnswers
  }) {
    gamesPlayed++;
    totalScore += gameScore;

    if (consecutiveAnswers > highestConsecutiveStreak) {
      highestConsecutiveStreak = consecutiveAnswers;
    }

    // Improved mastery level logic
    if (consecutiveAnswers >= 10) {
      masteryLevel++;
      if (masteryLevel >= 5) {
        maxMasteryAchieved = true;
        masteryLevel = 5; // Cap at 5
      }
    }
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'gamesPlayed': gamesPlayed,
      'totalScore': totalScore,
      'highestConsecutiveStreak': highestConsecutiveStreak,
      'masteryLevel': masteryLevel,
      'maxMasteryAchieved': maxMasteryAchieved,
    };
  }

  // JSON deserialization constructor
  factory DifficultyProgress.fromJson(Map<String, dynamic> json) {
    return DifficultyProgress(
      gamesPlayed: json['gamesPlayed'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      highestConsecutiveStreak: json['highestConsecutiveStreak'] ?? 0,
      masteryLevel: json['masteryLevel'] ?? 0,
      maxMasteryAchieved: json['maxMasteryAchieved'] ?? false,
    );
  }

  // Get difficulty-specific rewards
  String getDifficultyReward() {
    if (maxMasteryAchieved) return '🏆 ULTIMATE MASTERY TROPHY & 1000 COINS';
    if (masteryLevel >= 3) return '🥇 GOLD BADGE & 500 COINS';
    if (masteryLevel >= 2) return '🥈 SILVER BADGE & 250 COINS';
    if (masteryLevel >= 1) return '🥉 BRONZE BADGE & 100 COINS';
    return '🌱 PARTICIPATION BADGE & 50 COINS';
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final bool Function() condition;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.condition,
  });

  // Optional: Add equality and hashCode for potential list comparisons
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Achievement && 
      runtimeType == other.runtimeType && 
      id == other.id;

  @override
  int get hashCode => id.hashCode;
}