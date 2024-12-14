class GameModel {
  int score;
  int consecutiveCorrect;
  int currentLevel;
  double rocketProgress;
  int currentQuestionIndex;
  String gameStage;
  String explanationText;

  Map<String, dynamic> gameStats;

  GameModel({
    this.score = 0,
    this.consecutiveCorrect = 0,
    this.currentLevel = 1,
    this.rocketProgress = 0,
    this.currentQuestionIndex = 0,
    this.gameStage = 'playing',
    this.explanationText = '',
    Map<String, dynamic>? gameStats,
  }) : gameStats = gameStats ?? {
          'correctAnswers': 0,
          'wrongAnswers': 0,
          'totalTimeTaken': 0,
          'averageResponseTime': 0,
        };

  void reset() {
    score = 0;
    consecutiveCorrect = 0;
    currentLevel = 1;
    rocketProgress = 0;
    currentQuestionIndex = 0;
    gameStage = 'playing';
    explanationText = '';
    gameStats = {
      'correctAnswers': 0,
      'wrongAnswers': 0,
      'totalTimeTaken': 0,
      'averageResponseTime': 0,
    };
  }
}