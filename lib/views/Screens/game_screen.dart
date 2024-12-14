import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import 'package:coin_toss/controllers/game_controller.dart';

class GameScreen extends StatefulWidget {
  final String difficulty;
  final int totalQuestions;
  final Function(int finalScore, Map<String, dynamic> gameStats)? onGameOver;

  const GameScreen({
    Key? key,
    this.difficulty = 'Easy',
    this.totalQuestions = 10,
    this.onGameOver,
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late GameController _gameController;
  late AnimationController _animationController;
  late MathQuestion _currentQuestion;
  late int _timeLeft;
  Timer? _questionTimer;

  @override
  void initState() {
    super.initState();
    _gameController = GameController(
      difficulty: widget.difficulty,
      totalQuestions: widget.totalQuestions,
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _resetGame();
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startQuestionTimer() {
    final config = _gameController.difficultyConfig;
    _timeLeft = config['timer'];

    // Track total game time
    if (_gameController.currentModel.gameStats['startTime'] == null) {
      _gameController.currentModel.gameStats['startTime'] = DateTime.now();
    }

    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          timer.cancel();
          _handleTimeout();
        }
      });
    });
  }

void _handleTimeout() {
  // Calculate total game time
  if (_gameController.currentModel.gameStats['startTime'] != null) {
    _gameController.currentModel.gameStats['totalTimeTaken'] = 
      DateTime.now().difference(_gameController.currentModel.gameStats['startTime']).inSeconds;
  }

  setState(() {
    _gameController.currentModel.gameStage = 'gameOver';
    _gameController.currentModel.explanationText = 'Time ran out! Keep practicing.';
  });
  _questionTimer?.cancel();

  if (widget.onGameOver != null) {
    widget.onGameOver!(_gameController.currentModel.score, _gameController.currentModel.gameStats);
  }
}

  void _resetGame() {
    setState(() {
      _gameController.currentModel.reset();
      _generateQuestion();
      _startQuestionTimer();
    });
  }

  void _generateQuestion() {
    setState(() {
      _currentQuestion = _gameController.generateQuestion();
    });
  }

  void _evaluateAnswer(int selectedAnswer) {
    _questionTimer?.cancel();

    _gameController.evaluateAnswer(
      selectedAnswer, 
      _currentQuestion.correctAnswer, 
      _timeLeft
    );

    setState(() {
      switch (_gameController.currentModel.gameStage) {
        case 'playing':
          _generateQuestion();
          _startQuestionTimer();
          break;
        case 'levelUp':
          // Specific level up handling
          break;
        case 'sectionComplete':
          // Specific section complete handling
          break;
        case 'wrongAnswer':
          // Specific wrong answer handling
          break;
        case 'gameOver':
          if (widget.onGameOver != null) {
            widget.onGameOver!(_gameController.currentModel.score, _gameController.currentModel.gameStats);
          }
          break;
      }
    });
  }
  // Stage-specific build methods
  Widget _buildPlayingStage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _currentQuestion.question,
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ..._currentQuestion.options.map((option) => 
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton(
              onPressed: () => _evaluateAnswer(option),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
              child: Text(
                option.toString(),
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        ).toList(),
      ],
    );
  }

  Widget _buildLevelUpStage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.rocket_launch,
          size: 100,
          color: Colors.orange,
        ),
        const SizedBox(height: 20),
        Text(
          'Level Up!',
          style: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _gameController.getRandomMotivationalQuote(),
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _resetGame,
          child: Text(
            'Continue',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCompletedStage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.stars,
          size: 100,
          color: Colors.yellow[700],
        ),
        const SizedBox(height: 20),
        Text(
          'Section Completed!',
          style: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Congratulations on mastering this section!',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Potentially navigate to next section or reset
            _resetGame();
          },
          child: Text(
            'Next Challenge',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWrongAnswerStage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          size: 100,
          color: Colors.red,
        ),
        const SizedBox(height: 20),
        Text(
          'Oops! Wrong Answer',
          style: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'The correct answer was ${_currentQuestion.correctAnswer}',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _resetGame,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text(
            'Try Again',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameOverStage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.sentiment_very_dissatisfied,
          size: 100,
          color: Colors.red,
        ),
        const SizedBox(height: 20),
        Text(
          'Game Over',
          style: GoogleFonts.montserrat(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Final Score: ${_gameController.currentModel.score}',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _resetGame,
          child: Text(
            'Play Again',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Render methods
  Widget _renderGameStage() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: _getStageWidget(),
    );
  }

  Widget _getStageWidget() {
    switch (_gameController.currentModel.gameStage) {
      case 'playing':
        return _buildPlayingStage();
      case 'levelUp':
        return _buildLevelUpStage();
      case 'sectionComplete':
        return _buildSectionCompletedStage();
      case 'wrongAnswer':
        return _buildWrongAnswerStage();
      case 'gameOver':
        return _buildGameOverStage();
      default:
        return Container();
    }
  }

  // Reuse the existing stage rendering methods from the previous implementation
  // (Keep the _buildPlayingStage, _buildWrongAnswerStage, etc. methods from the previous code)

  Widget _buildEnhancedGameHeader() {
    final config = _gameController.difficultyConfig;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildAnimatedStatChip(
          icon: Icons.stars,
          label: 'Score',
          value: _gameController.currentModel.score.toString(),
          color: config['gradientColors'][0],
        ),
        _buildAnimatedStatChip(
          icon: Icons.rocket_launch,
          label: 'Level',
          value: _gameController.currentModel.currentLevel.toString(),
          color: config['gradientColors'][1],
        ),
        _buildAnimatedStatChip(
          icon: Icons.bolt,
          label: 'Streak',
          value: _gameController.currentModel.consecutiveCorrect.toString(),
          color: Colors.amber,
        ),
      ],
    );
  }

  Widget _buildTimerWidget() {
    return Text(
      'Time Left: $_timeLeft s',
      style: TextStyle(
        color: _timeLeft <= 3 ? Colors.red : Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRocketProgressBar() {
    final config = _gameController.difficultyConfig;
    return LinearProgressIndicator(
      value: _gameController.currentModel.rocketProgress / 100,
      backgroundColor: Colors.grey[300],
      valueColor: AlwaysStoppedAnimation<Color>(config['rocketColor']),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _gameController.difficultyConfig;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: config['gradientColors'],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 500,
                maxHeight: MediaQuery.of(context).size.height,
              ),
              child: Card(
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 12,
                shadowColor: Colors.black45,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildEnhancedGameHeader(),
                      const SizedBox(height: 8),
                      _buildTimerWidget(),
                      const SizedBox(height: 12),
                      _buildRocketProgressBar(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: PageTransitionSwitcher(
                          transitionBuilder: (child, animation, secondaryAnimation) {
                            return SharedAxisTransition(
                              animation: animation,
                              secondaryAnimation: secondaryAnimation,
                              transitionType: SharedAxisTransitionType.vertical,
                              child: child,
                            );
                          },
                          child: _renderGameStage(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.7), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.montserrat(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
  // Keep the _buildAnimatedStatChip method from the previous implementation







// import 'package:flutter/material.dart';
// import 'dart:math';
// import 'dart:async';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:animations/animations.dart';

// class GameScreen extends StatefulWidget {
//   final String difficulty;
//   final int totalQuestions;
//   final Function(int finalScore, Map<String, dynamic> gameStats)? onGameOver;

//   const GameScreen({
//     Key? key,
//     this.difficulty = 'Easy',
//     this.totalQuestions = 10,
//     this.onGameOver,
//   }) : super(key: key);

//   @override
//   _GameScreenState createState() => _GameScreenState();
// }

// class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
//   // Difficulty Configurations (Unchanged from previous code)
//   final Map<String, dynamic> difficultyConfig = {
//     'Easy': {
//       'timer': 20,
//       'questionRange': 20,
//       'operators': ['+', '-'],
//       'complexity': 1,
//       'levelsRequired': 4,
//       'levelUpThreshold': 40,
//       'rocketColor': Colors.green,
//       'mastery': 'Math Explorer',
//       'backgroundColor': [Colors.lightGreen[100]!, Colors.lightGreen[300]!],
//       'gradientColors': [
//         Color(0xFF6AB7F5),
//         Color(0xFF1D7DD4)
//       ]
//     },
//     'Medium': {
//       'timer': 15,
//       'questionRange': 50,
//       'operators': ['+', '-', '*', '/'],
//       'complexity': 2,
//       'levelsRequired': 4,
//       'levelUpThreshold': 80,
//       'rocketColor': Colors.blue,
//       'mastery': 'Math Adventurer',
//       'backgroundColor': [Colors.blue[100]!, Colors.blue[300]!],
//       'gradientColors': [
//         Color(0xFFF6B458),
//         Color(0xFFE86E4E)
//       ]
//     },
//     'Hard': {
//       'timer': 10,
//       'questionRange': 100,
//       'operators': ['+', '-', '*', '/', '^'],
//       'complexity': 3,
//       'levelsRequired': 4,
//       'levelUpThreshold': 120,
//       'rocketColor': Colors.red,
//       'mastery': 'Math Champion',
//       'backgroundColor': [Colors.deepOrange[100]!, Colors.deepOrange[300]!],
//       'gradientColors': [
//         Color(0xFF5D3FD3),
//         Color(0xFF9D4EDD)
//       ]
//     }
//   };

//   // Motivational Quotes
//   final List<String> motivationalQuotes = [
//     "Challenge accepted! 💪",
//     "Every problem solved makes you stronger. 🧠",
//     "Keep pushing your limits! 🚀",
//     "Learning is a journey, enjoy the ride! 🌟",
//     "You're becoming a math wizard! ✨"
//   ];

//   // Game State Variables
//   late int score;
//   late String question;
//   late List<int> options;
//   late int correctAnswer;
//   late int timeLeft;
//   late int consecutiveCorrect;
//   late String gameStage;
//   late int currentLevel;
//   late double rocketProgress;
//   late int currentQuestionIndex;
//   late String? explanationText;
//   late AnimationController _animationController;
//   Timer? _questionTimer;

//   // Performance Tracking
//   Map<String, dynamic> gameStats = {
//     'correctAnswers': 0,
//     'wrongAnswers': 0,
//     'totalTimeTaken': 0,
//     'averageResponseTime': 0,
//     'startTime': null,
//   };

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _resetGame();
//   }

//   @override
//   void dispose() {
//     _questionTimer?.cancel();
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _startQuestionTimer() {
//     final config = difficultyConfig[widget.difficulty] ?? difficultyConfig['Easy']!;
//     timeLeft = config['timer'];

//     // Track total game time
//     if (gameStats['startTime'] == null) {
//       gameStats['startTime'] = DateTime.now();
//     }

//     _questionTimer?.cancel();
//     _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         timeLeft--;
//         if (timeLeft <= 0) {
//           timer.cancel();
//           _handleTimeout();
//         }
//       });
//     });
//   }





//   void _handleTimeout() {
//     // Calculate total game time
//     if (gameStats['startTime'] != null) {
//       gameStats['totalTimeTaken'] = DateTime.now().difference(gameStats['startTime']).inSeconds;
//     }

//     setState(() {
//       gameStage = 'gameOver';
//       explanationText = 'Time ran out! Keep practicing.';
//     });
//     _questionTimer?.cancel();

//     if (widget.onGameOver != null) {
//       widget.onGameOver!(score, gameStats);
//     }
//   }

//   void _resetGame() {
//     final config = difficultyConfig[widget.difficulty] ?? difficultyConfig['Easy']!;

//     setState(() {
//       score = 0;
//       consecutiveCorrect = 0;
//       currentLevel = 1;
//       rocketProgress = 0;
//       gameStage = 'playing';
//       currentQuestionIndex = 0;
//       explanationText = null;
//       gameStats = {
//         'correctAnswers': 0,
//         'wrongAnswers': 0,
//         'totalTimeTaken': 0,
//         'averageResponseTime': 0,
//       };
//       _generateQuestion();
//       _startQuestionTimer();
//     });
//   }

//   // Enhanced Question Generation Methods
//   void _generateQuestion() {
//     final config = difficultyConfig[widget.difficulty] ?? difficultyConfig['Easy']!;
//     final random = Random();
//     int complexity = config['complexity'];

//     switch (complexity) {
//       case 1:
//         _generateSimpleQuestion(config['operators'], config['questionRange']);
//         break;
//       case 2:
//         _generateMediumQuestion(config['operators'], config['questionRange']);
//         break;
//       case 3:
//         _generateHardQuestion(config['operators'], config['questionRange']);
//         break;
//     }
//   }


//   void _generateSimpleQuestion(List<String> operators, int range) {
//     final random = Random();
//     int num1 = random.nextInt(range) + 1;
//     int num2 = random.nextInt(range) + 1;
//     String operation = operators[random.nextInt(operators.length)];

//     int answer = _calculateAnswer(num1, num2, operation);

//     setState(() {
//       question = '$num1 $operation $num2 = ?';
//       options = _generateOptions(answer, range);
//       correctAnswer = answer;
//     });
//   }

//   void _generateMediumQuestion(List<String> operators, int range) {
//     final random = Random();
//     int complexity = random.nextInt(2) + 1;

//     if (complexity == 1) {
//       _generateSimpleQuestion(operators, range);
//     } else {
//       int num1 = random.nextInt(range) + 1;
//       int num2 = random.nextInt(range) + 1;
//       int num3 = random.nextInt(range) + 1;

//       String op1 = operators[random.nextInt(operators.length)];
//       String op2 = operators[random.nextInt(operators.length)];

//       int intermediateResult = _calculateAnswer(num1, num2, op1);
//       int answer = _calculateAnswer(intermediateResult, num3, op2);

//       setState(() {
//         question = '$num1 $op1 $num2 $op2 $num3 = ?';
//         options = _generateOptions(answer, range * 2);
//         correctAnswer = answer;
//       });
//     }
//   }

//   void _generateHardQuestion(List<String> operators, int range) {
//     final random = Random();
//     int complexity = random.nextInt(3) + 1;

//     switch (complexity) {
//       case 1:
//         _generateMediumQuestion(operators, range);
//         break;
//       case 2:
//         int a = random.nextInt(range) + 1;
//         int b = random.nextInt(range) + 1;
//         int c = random.nextInt(range) + 1;
//         int d = random.nextInt(range) + 1;

//         String op1 = operators[random.nextInt(operators.length)];
//         String op2 = operators[random.nextInt(operators.length)];
//         String op3 = operators[random.nextInt(operators.length)];

//         int step1 = _calculateAnswer(a, b, op1);
//         int step2 = _calculateAnswer(c, d, op2);
//         int answer = _calculateAnswer(step1, step2, op3);

//         setState(() {
//           question = '($a $op1 $b) $op3 ($c $op2 $d) = ?';
//           options = _generateOptions(answer, range * 3);
//           correctAnswer = answer;
//         });
//         break;
//       case 3:
//         int a = random.nextInt(range) + 1;
//         int b = random.nextInt(range) + 1;
//         int c = random.nextInt(range) + 1;
//         int d = random.nextInt(range) + 1;
//         int e = random.nextInt(range) + 1;

//         String op1 = operators[random.nextInt(operators.length)];
//         String op2 = operators[random.nextInt(operators.length)];
//         String op3 = operators[random.nextInt(operators.length)];
//         String op4 = operators[random.nextInt(operators.length)];

//         int step1 = _calculateAnswer(a, b, op1);
//         int step2 = _calculateAnswer(c, d, op2);
//         int step3 = _calculateAnswer(step1, step2, op3);
//         int answer = _calculateAnswer(step3, e, op4);

//         setState(() {
//           question = '(($a $op1 $b) $op3 ($c $op2 $d)) $op4 $e = ?';
//           options = _generateOptions(answer, range * 4);
//           correctAnswer = answer;
//         });
//         break;
//     }
//   }

//   int _calculateAnswer(int num1, int num2, String operation) {
//     switch (operation) {
//       case '+':
//         return num1 + num2;
//       case '-':
//         return num1 - num2;
//       case '*':
//         return num1 * num2;
//       case '/':
//         if (num2 == 0) return num1; // Avoid division by zero
//         return (num1 / num2).truncate();
//       default:
//         return num1 + num2;
//     }
//   }

//   List<int> _generateOptions(int correctAnswer, int range) {
//     final optionsSet = <int>{correctAnswer};
//     final random = Random();

//     while (optionsSet.length < 4) {
//       final randomOption = random.nextInt(range * 2) - range;
//       optionsSet.add(randomOption);
//     }

//     return optionsSet.toList()..shuffle();
//   }







//   void _evaluateAnswer(int selectedAnswer) {
//     final config = difficultyConfig[widget.difficulty] ?? difficultyConfig['Easy']!;
//     _questionTimer?.cancel();

//     if (selectedAnswer == correctAnswer) {
//       setState(() {
//         // Bonus points for faster answers
//         score += timeLeft > 0 ? 10 + (timeLeft * 2) : 10;
//         consecutiveCorrect++;
//         rocketProgress += 10;
//         currentQuestionIndex++;
//         gameStats['correctAnswers']++;
//         explanationText = null;

//         if (currentQuestionIndex >= widget.totalQuestions) {
//           gameStage = 'gameOver';
//           if (widget.onGameOver != null) {
//             widget.onGameOver!(score, gameStats);
//           }
//           return;
//         }

//         if (rocketProgress >= config['levelUpThreshold']) {
//           currentLevel++;
//           if (currentLevel > config['levelsRequired']) {
//             gameStage = 'sectionComplete';
//           } else {
//             gameStage = 'levelUp';
//           }
//           rocketProgress = 0;
//         } else {
//           _generateQuestion();
//           _startQuestionTimer();
//         }
//       });
//     } else {
//       setState(() {
//         gameStage = 'wrongAnswer';
//         gameStats['wrongAnswers']++;
//         explanationText = motivationalQuotes[Random().nextInt(motivationalQuotes.length)];
//       });
//     }
//   }

//   // Enhanced UI Rendering Methods
//   Widget _renderGameStage() {
//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 300),
//       switchInCurve: Curves.easeInOut,
//       switchOutCurve: Curves.easeInOut,
//       child: _getStageWidget(),
//     );
//   }
//     Widget _getStageWidget() {
//     switch (gameStage) {
//       case 'playing':
//         return _buildPlayingStage();
//       case 'levelUp':
//         return _buildLevelUpStage();
//       case 'sectionComplete':
//         return _buildSectionCompletedStage();
//       case 'wrongAnswer':
//         return _buildWrongAnswerStage();
//       case 'gameOver':
//         return _buildGameOverStage();
//       default:
//         return Container();
//     }
//   }

//   Widget _buildWrongAnswerStage() {
//     return Column(
//       children: [
//         const Icon(
//           Icons.error_outline,
//           color: Colors.red,
//           size: 64,
//         ),
//         const SizedBox(height: 16),
//         Text(
//           'Correct Answer: $correctAnswer',
//           style: const TextStyle(
//             fontSize: 24,
//             color: Colors.red,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 16),
//         Text(
//           explanationText ?? '',
//           style: const TextStyle(
//             fontSize: 18,
//             color: Colors.black87,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 16),
//         ElevatedButton(
//           onPressed: () => setState(() {
//             gameStage = 'playing';
//             _generateQuestion();
//             _startQuestionTimer();
//           }),
//           child: const Text('Continue'),
//         )
//       ],
//     );
//   }

//   Widget _buildSectionCompletedStage() {
//     final config = difficultyConfig[widget.difficulty] ?? difficultyConfig['Easy']!;
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Icon(
//   Icons.star,
//   color: Colors.amber, // Replace gold with amber
//   size: 64,
// ),

//         const SizedBox(height: 16),
//         Text(
//           'Congratulations!\n${config['mastery']}',
//           style: const TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.green,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 16),
//         ElevatedButton(
//           onPressed: _resetGame,
//           child: const Text('Play Next Section'),
//         )
//       ],
//     );
//   }



//   Widget _buildPlayingStage() {
//     return Column(
//       children: [
//         Card(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               question,
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.purple,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//         GridView.builder(
//           shrinkWrap: true,
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             childAspectRatio: 2,
//             crossAxisSpacing: 10,
//             mainAxisSpacing: 10,
//           ),
//           itemCount: options.length,
//           itemBuilder: (context, index) {
//             return ElevatedButton(
//               onPressed: () => _evaluateAnswer(options[index]),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.purple[100],
//                 foregroundColor: Colors.purple[800],
//                 // Add elevation and animation
//                 elevation: 3,
//                 shadowColor: Colors.purple[200],
//               ),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 curve: Curves.easeInOut,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.purple.withOpacity(0.3),
//                       spreadRadius: 1,
//                       blurRadius: 5,
//                     ),
//                   ],
//                 ),
//                 child: Text(
//                   options[index].toString(),
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildLevelUpStage() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Icon(
//           Icons.emoji_events,
//           color: Colors.green,
//           size: 64,
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           'Level Up! 🚀',
//           style: TextStyle(
//             fontSize: 32,
//             fontWeight: FontWeight.bold,
//             color: Colors.green,
//           ),
//         ),
//         const SizedBox(height: 16),
//         Text(
//           motivationalQuotes[Random().nextInt(motivationalQuotes.length)],
//           style: const TextStyle(
//             fontSize: 20,
//             color: Colors.green,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 16),
//         ElevatedButton(
//           onPressed: () => setState(() {
//             gameStage = 'playing';
//             _generateQuestion();
//           }),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.green,
//             foregroundColor: Colors.white,
//           ),
//           child: const Text('Continue'),
//         ),
//       ],
//     );
//   }

//   Widget _buildGameOverStage() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Icon(
//           Icons.emoji_events,
//           color: Colors.red,
//           size: 64,
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           'Game Over',
//           style: TextStyle(
//             fontSize: 32,
//             fontWeight: FontWeight.bold,
//             color: Colors.red,
//           ),
//         ),
//         const SizedBox(height: 16),
//         Text(
//           'Final Score: $score',
//           style: const TextStyle(
//             fontSize: 20,
//             color: Colors.red,
//           ),
//         ),
//         const SizedBox(height: 16),
//         ElevatedButton(
//           onPressed: _resetGame,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.red,
//             foregroundColor: Colors.white,
//           ),
//           child: const Text('Play Again'),
//         ),
//       ],
//     );
//   }

//   Widget _buildGameHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         _buildStatItem(Icons.bolt, 'Points: $score', Colors.yellow),
//         _buildStatItem(Icons.flag, 'Level: $currentLevel', Colors.purple),
//         _buildStatItem(
//             Icons.arrow_upward, 'Streak: $consecutiveCorrect', Colors.green),
//       ],
//     );
//   }

//   Widget _buildStatItem(IconData icon, String text, Color color) {
//     return Row(
//       children: [
//         Icon(icon, color: color),
//         const SizedBox(width: 4),
//         Text(
//           text,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildRocketProgressBar() {
//     final config =
//         difficultyConfig[widget.difficulty] ?? difficultyConfig['Easy']!;

//     return LinearProgressIndicator(
//       value: rocketProgress / 100,
//       backgroundColor: Colors.grey[300],
//       valueColor: AlwaysStoppedAnimation<Color>(config['rocketColor']),
//     );
//   }

//   Widget _buildTimerWidget() {
//     return Text(
//       'Time Left: $timeLeft s',
//       style: TextStyle(
//         color: timeLeft <= 3 ? Colors.red : Colors.black,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final config = difficultyConfig[widget.difficulty] ?? difficultyConfig['Easy']!;
    
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: config['gradientColors'],
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 maxWidth: 500,
//                 maxHeight: MediaQuery.of(context).size.height,
//               ),
//               child: Card(
//                 margin: const EdgeInsets.all(16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 elevation: 12,
//                 shadowColor: Colors.black45,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       _buildEnhancedGameHeader(),
//                       const SizedBox(height: 8),
//                       _buildTimerWidget(),
//                       const SizedBox(height: 12),
//                       _buildRocketProgressBar(),
//                       const SizedBox(height: 16),
//                       Expanded(
//                         child: PageTransitionSwitcher(
//                           transitionBuilder: (child, animation, secondaryAnimation) {
//                             return SharedAxisTransition(
//                               animation: animation,
//                               secondaryAnimation: secondaryAnimation,
//                               transitionType: SharedAxisTransitionType.vertical,
//                               child: child,
//                             );
//                           },
//                           child: _renderGameStage(),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }





// // Enhanced Header with better stats visualization
//   Widget _buildEnhancedGameHeader() {
//     final config = difficultyConfig[widget.difficulty] ?? difficultyConfig['Easy']!;
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         _buildAnimatedStatChip(
//           icon: Icons.stars,
//           label: 'Score',
//           value: score.toString(),
//           color: config['gradientColors'][0],
//         ),
//         _buildAnimatedStatChip(
//           icon: Icons.rocket_launch,
//           label: 'Level',
//           value: currentLevel.toString(),
//           color: config['gradientColors'][1],
//         ),
//         _buildAnimatedStatChip(
//           icon: Icons.bolt,
//           label: 'Streak',
//           value: consecutiveCorrect.toString(),
//           color: Colors.amber,
//         ),
//       ],
//     );
//   }

//   Widget _buildAnimatedStatChip({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//   }) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         gradient: LinearGradient(
//           colors: [color.withOpacity(0.7), color],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.4),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           )
//         ],
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.white, size: 20),
//           const SizedBox(width: 8),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: GoogleFonts.montserrat(
//                   color: Colors.white70,
//                   fontSize: 10,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Text(
//                 value,
//                 style: GoogleFonts.montserrat(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
