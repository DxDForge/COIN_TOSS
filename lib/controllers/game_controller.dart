import 'dart:math';
import 'package:coin_toss/utility/difficulty_config.dart';
import '../models/game_model.dart';

class GameController {
  final GameModel model;
  final String difficulty;
  final int totalQuestions;

  GameModel get currentModel => model;

  GameController({
    required this.difficulty,
    this.totalQuestions = 10,
  }) : model = GameModel();

  static final List<String> motivationalQuotes = [
    "Challenge accepted! 💪",
    "Every problem solved makes you stronger. 🧠",
    "Keep pushing your limits! 🚀",
    "Learning is a journey, enjoy the ride! 🌟",
    "You're becoming a math wizard! ✨"
  ];

  Map<String, dynamic> get difficultyConfig => 
    DifficultyConfig.config[difficulty] ?? DifficultyConfig.config['Easy']!;

  MathQuestion generateQuestion() {
    int complexity = difficultyConfig['complexity'];
    int range = difficultyConfig['questionRange'];
    List<String> operators = difficultyConfig['operators'];

    switch (complexity) {
      case 1:
        return _generateSimpleQuestion(operators, range);
      case 2:
        return _generateMediumQuestion(operators, range);
      case 3:
        return _generateHardQuestion(operators, range);
      default:
        return _generateSimpleQuestion(operators, range);
    }
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
    if (selectedAnswer == correctAnswer) {
      _handleCorrectAnswer(timeLeft);
    } else {
      _handleWrongAnswer();
    }
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

class MathQuestion {
  final String question;
  final List<int> options;
  final int correctAnswer;

  MathQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}