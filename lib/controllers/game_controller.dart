import 'dart:math';
import 'package:coin_toss/utility/difficulty_config.dart';
import '../models/game_model.dart';

class GameController {
  final GameModel model;
  final String difficulty;
  final int totalQuestions;

    // New engagement tracking variables
  int _consecutiveChallenges = 0;
  int _flowStateMultiplier = 1;
  DateTime? _lastSuccessTimestamp;

  GameModel get currentModel => model;

  static final List<String> motivationalQuotes = [
    "Challenge accepted! 💪",
    "Every problem solved makes you stronger. 🧠",
    "Keep pushing your limits! 🚀",
    "Learning is a journey, enjoy the ride! 🌟",
    "You're becoming a math wizard! ✨",
    // New, more dynamic quotes
    "Your brain is getting a serious workout! 💡",
    "Math muscles growing stronger! 💪",
    "Genius mode: Activated! 🚀",
    "Breaking mental barriers! 🌈"
  ];

  // Dynamic bonus quote system
  static final List<String> bonusQuotes = [
    "Combo Breaker! 🔥",
    "Unstoppable Streak! 🌟",
    "Mind-Blowing Precision! ✨",
    "Lightning-Fast Thinking! ⚡",
    "Calculation Maestro! 🏆"
  ];

  GameController({
    required this.difficulty,
    this.totalQuestions = 10,
  }) : model = GameModel();




  Map<String, dynamic> get difficultyConfig => 
    DifficultyConfig.config[difficulty] ?? DifficultyConfig.config['Easy']!;

  void _breakFlowState() {
    _flowStateMultiplier = 1;
    _consecutiveChallenges = 0;
    model.explanationText = getRandomMotivationalQuote();
  }

  // Enhanced question generation with psychological engagement
  MathQuestion generateQuestion() {
    _adjustDynamicDifficulty();
    
    int complexity = difficultyConfig['complexity'];
    int range = difficultyConfig['questionRange'];
    List<String> operators = difficultyConfig['operators'];

    MathQuestion question;
    switch (complexity) {
      case 1:
        question = _generateSimpleQuestion(operators, range);
        break;
      case 2:
        question = _generateMediumQuestion(operators, range);
        break;
      case 3:
        question = _generateHardQuestion(operators, range);
        break;
      default:
        question = _generateSimpleQuestion(operators, range);
    }

    // Add psychological challenge elements
    question.timeLimit = _calculateTimeLimit(question);
    question.pointMultiplier = _calculatePointMultiplier();

    return question;
  }

  void _adjustDynamicDifficulty() {
    // Dynamically adjust difficulty based on player performance
    if (model.consecutiveCorrect > 5) {
      _flowStateMultiplier++;
      _consecutiveChallenges++;
    }

    // Reset flow state if performance drops
    if (model.consecutiveCorrect == 0) {
      _flowStateMultiplier = 1;
      _consecutiveChallenges = 0;
    }
  }

  int _calculateTimeLimit(MathQuestion question) {
    // Shorter time for more complex questions, with flow state consideration
    int baseTimeLimit = 15;
    int complexityReduction = question.question.split(' ').length * 2;
    return max(5, baseTimeLimit - complexityReduction + _flowStateMultiplier);
  }

  double _calculatePointMultiplier() {
    // Progressive point multiplier based on consecutive challenges
    return 1 + (_consecutiveChallenges * 0.1);
  }

  MathQuestion _generateSimpleQuestion(List<String> operators, int range) {
    final random = Random();
    int num1 = random.nextInt(range) + 1;
    int num2 = random.nextInt(range) + 1;
    String operation = operators[random.nextInt(operators.length)];

    int answer = _calculateAnswer(num1, num2, operation);

    return MathQuestion(
      question: '$num1 $operation $num2 = ?',
      options: _generateOptions(answer, range),
      correctAnswer: answer,
    );
  }

  MathQuestion _generateMediumQuestion(List<String> operators, int range) {
    final random = Random();
    int complexity = random.nextInt(2) + 1;

    if (complexity == 1) {
      return _generateSimpleQuestion(operators, range);
    } else {
      int num1 = random.nextInt(range) + 1;
      int num2 = random.nextInt(range) + 1;
      int num3 = random.nextInt(range) + 1;

      String op1 = operators[random.nextInt(operators.length)];
      String op2 = operators[random.nextInt(operators.length)];

      int intermediateResult = _calculateAnswer(num1, num2, op1);
      int answer = _calculateAnswer(intermediateResult, num3, op2);

      return MathQuestion(
        question: '$num1 $op1 $num2 $op2 $num3 = ?',
        options: _generateOptions(answer, range * 2),
        correctAnswer: answer,
      );
    }
  }

  MathQuestion _generateHardQuestion(List<String> operators, int range) {
    final random = Random();
    int complexity = random.nextInt(3) + 1;

    switch (complexity) {
      case 1:
        return _generateMediumQuestion(operators, range);
      case 2:
        int a = random.nextInt(range) + 1;
        int b = random.nextInt(range) + 1;
        int c = random.nextInt(range) + 1;
        int d = random.nextInt(range) + 1;

        String op1 = operators[random.nextInt(operators.length)];
        String op2 = operators[random.nextInt(operators.length)];
        String op3 = operators[random.nextInt(operators.length)];

        int step1 = _calculateAnswer(a, b, op1);
        int step2 = _calculateAnswer(c, d, op2);
        int answer = _calculateAnswer(step1, step2, op3);

        return MathQuestion(
          question: '($a $op1 $b) $op3 ($c $op2 $d) = ?',
          options: _generateOptions(answer, range * 3),
          correctAnswer: answer,
        );
      case 3:
        int a = random.nextInt(range) + 1;
        int b = random.nextInt(range) + 1;
        int c = random.nextInt(range) + 1;
        int d = random.nextInt(range) + 1;
        int e = random.nextInt(range) + 1;

        String op1 = operators[random.nextInt(operators.length)];
        String op2 = operators[random.nextInt(operators.length)];
        String op3 = operators[random.nextInt(operators.length)];
        String op4 = operators[random.nextInt(operators.length)];

        int step1 = _calculateAnswer(a, b, op1);
        int step2 = _calculateAnswer(c, d, op2);
        int step3 = _calculateAnswer(step1, step2, op3);
        int answer = _calculateAnswer(step3, e, op4);

        return MathQuestion(
          question: '(($a $op1 $b) $op3 ($c $op2 $d)) $op4 $e = ?',
          options: _generateOptions(answer, range * 4),
          correctAnswer: answer,
        );
      default:
        return _generateMediumQuestion(operators, range);
    }
  }

  int _calculateAnswer(int num1, int num2, String operation) {
    switch (operation) {
      case '+':
        return num1 + num2;
      case '-':
        return num1 - num2;
      case '*':
        return num1 * num2;
      case '/':
        if (num2 == 0) return num1;
        return (num1 / num2).truncate();
      default:
        return num1 + num2;
    }
  }

  List<int> _generateOptions(int correctAnswer, int range) {
    final optionsSet = <int>{correctAnswer};
    final random = Random();

    while (optionsSet.length < 4) {
      final randomOption = random.nextInt(range * 2) - range;
      optionsSet.add(randomOption);
    }

    return optionsSet.toList()..shuffle();
  }

void evaluateAnswer(int selectedAnswer, int correctAnswer, int timeLeft) {
    bool isCorrect = selectedAnswer == correctAnswer;
    
    if (isCorrect) {
      _handleCorrectAnswer(timeLeft);
      _updateFlowState();
    } else {
      _handleWrongAnswer();
      _breakFlowState();
    }
  }

  void _updateFlowState() {
    DateTime now = DateTime.now();
    if (_lastSuccessTimestamp != null) {
      Duration timeBetweenAnswers = now.difference(_lastSuccessTimestamp!);
      
      // Reward quick, accurate responses
      if (timeBetweenAnswers.inSeconds < 3) {
        model.score += 5; // Bonus for rapid problem-solving
        model.explanationText = _getRandomBonusQuote();
      }
    }
    _lastSuccessTimestamp = now;
  }



  String _getRandomBonusQuote() {
    return bonusQuotes[Random().nextInt(bonusQuotes.length)];
  }

  void _handleCorrectAnswer(int timeLeft) {
    model.score += timeLeft > 0 ? 10 + (timeLeft * 2) : 10;
    model.consecutiveCorrect++;
    model.rocketProgress += 10;
    model.currentQuestionIndex++;
    model.gameStats['correctAnswers']++;

    if (model.currentQuestionIndex >= totalQuestions) {
      model.gameStage = 'gameOver';
      return;
    }

    if (model.rocketProgress >= difficultyConfig['levelUpThreshold']) {
      model.currentLevel++;
      if (model.currentLevel > difficultyConfig['levelsRequired']) {
        model.gameStage = 'sectionComplete';
      } else {
        model.gameStage = 'levelUp';
      }
      model.rocketProgress = 0;
    }
  }

  void _handleWrongAnswer() {
    model.gameStage = 'wrongAnswer';
    model.gameStats['wrongAnswers']++;
  }

  String getRandomMotivationalQuote() {
    return motivationalQuotes[Random().nextInt(motivationalQuotes.length)];
  }
}

// Enhanced MathQuestion to support new psychological mechanics
class MathQuestion {
  final String question;
  final List<int> options;
  final int correctAnswer;
  int timeLimit;
  double pointMultiplier;

  MathQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.timeLimit = 15,
    this.pointMultiplier = 1.0,
  });
}