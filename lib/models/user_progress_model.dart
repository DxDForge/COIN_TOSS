
class UserProgress {
  int totalGamesPlayed = 0;
  int totalScore = 0;
  int highestConsecutiveStreak = 0;
Map<String, DifficultyProgress> difficultyProgress = {
  'Easy': DifficultyProgress.fromJson({}),
  'Medium': DifficultyProgress.fromJson({}),
  'Hard': DifficultyProgress.fromJson({}),
};
  List<Achievement> unlockedAchievements = [];

  // Constructor
  UserProgress();

  // JSON Serialization
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    UserProgress progress = UserProgress();
    progress.totalGamesPlayed = json['totalGamesPlayed'] ?? 0;
    progress.totalScore = json['totalScore'] ?? 0;
    progress.highestConsecutiveStreak = json['highestConsecutiveStreak'] ?? 0;

    // Deserialize difficulty progress
    if (json['difficultyProgress'] != null) {
      (json['difficultyProgress'] as Map).forEach((key, value) {
        progress.difficultyProgress[key] = DifficultyProgress.fromJson(value);
      });
    }

    // Deserialize achievements
    if (json['unlockedAchievements'] != null) {
      progress.unlockedAchievements = (json['unlockedAchievements'] as List)
          .map((achievementJson) => Achievement.fromJson(achievementJson))
          .toList();
    }

    return progress;
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGamesPlayed': totalGamesPlayed,
      'totalScore': totalScore,
      'highestConsecutiveStreak': highestConsecutiveStreak,
      'difficultyProgress': {
        for (var entry in difficultyProgress.entries)
          entry.key: entry.value.toJson()
      },
      'unlockedAchievements': unlockedAchievements.map((a) => a.toJson()).toList(),
    };
  }

  void updateProgress({
    required String difficulty, 
    required int gameScore, 
    required int consecutiveAnswers
  }) {
    totalGamesPlayed++;
    totalScore += gameScore;

    difficultyProgress[difficulty]?.updateProgress(
      gameScore: gameScore, 
      consecutiveAnswers: consecutiveAnswers
    );

    if (consecutiveAnswers > highestConsecutiveStreak) {
      highestConsecutiveStreak = consecutiveAnswers;
    }

    checkAchievements();
  }

  void checkAchievements() {
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

    for (var achievement in possibleAchievements) {
      if (achievement.condition() && 
          !unlockedAchievements.any((a) => a.id == achievement.id)) {
        unlockedAchievements.add(achievement);
      }
    }
  }

  String getOverallRank() {
    int totalMasteryScore = difficultyProgress.values
      .map((progress) => progress.masteryLevel)
      .reduce((a, b) => a + b);

    if (totalMasteryScore >= 15) return '🌟 BRAIN STORM LEGEND 🌟';
    if (totalMasteryScore >= 10) return '🚀 MASTER MIND';
    if (totalMasteryScore >= 5) return '💡 INTELLECTUAL';
    return '🆕 BRAIN TRAINEE';
  }
}

class DifficultyProgress {
  int gamesPlayed = 0;
  int totalScore = 0;
  int highestConsecutiveStreak = 0;
  int masteryLevel = 0;
  bool maxMasteryAchieved = false;
  DifficultyProgress();

  // JSON Serialization
  factory DifficultyProgress.fromJson(Map<String, dynamic> json) {
    DifficultyProgress progress = DifficultyProgress();
    progress.gamesPlayed = json['gamesPlayed'] ?? 0;
    progress.totalScore = json['totalScore'] ?? 0;
    progress.highestConsecutiveStreak = json['highestConsecutiveStreak'] ?? 0;
    progress.masteryLevel = json['masteryLevel'] ?? 0;
    progress.maxMasteryAchieved = json['maxMasteryAchieved'] ?? false;
    return progress;
  }

  Map<String, dynamic> toJson() {
    return {
      'gamesPlayed': gamesPlayed,
      'totalScore': totalScore,
      'highestConsecutiveStreak': highestConsecutiveStreak,
      'masteryLevel': masteryLevel,
      'maxMasteryAchieved': maxMasteryAchieved,
    };
  }

  void updateProgress({
    required int gameScore, 
    required int consecutiveAnswers
  }) {
    gamesPlayed++;
    totalScore += gameScore;

    if (consecutiveAnswers > highestConsecutiveStreak) {
      highestConsecutiveStreak = consecutiveAnswers;
    }

    if (consecutiveAnswers >= 50) {
      masteryLevel++;
      if (masteryLevel >= 5) {
        maxMasteryAchieved = true;
      }
    }
  }

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

  // JSON Serialization
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      condition: () => false, // Note: condition cannot be serialized
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}