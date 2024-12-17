/* 

T H I S     I S    M Y   C  O  D  E

*/





import 'package:coin_toss/models/user_progress_model.dart';
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
  late UserProgress _userProgress;

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
    _userProgress = UserProgress(); // Initialize _userProgress
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

    // Update user progress before game over
    _userProgress.updateProgress(
      difficulty: widget.difficulty, 
      gameScore: _gameController.currentModel.score, 
      consecutiveAnswers: _gameController.currentModel.consecutiveCorrect
    );

    setState(() {
      _gameController.currentModel.gameStage = 'gameOver';
      _gameController.currentModel.explanationText = 'Time ran out! Keep practicing.';
    });
    _questionTimer?.cancel();

    if (widget.onGameOver != null) {
      widget.onGameOver!(
        _gameController.currentModel.score, 
        _gameController.currentModel.gameStats,
        
      );
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
          // Update progress for level up
          _userProgress.updateProgress(
            difficulty: widget.difficulty, 
            gameScore: _gameController.currentModel.score, 
            consecutiveAnswers: _gameController.currentModel.consecutiveCorrect
          );
          break;
        case 'sectionComplete':
          // Update progress for section complete
          _userProgress.updateProgress(
            difficulty: widget.difficulty, 
            gameScore: _gameController.currentModel.score, 
            consecutiveAnswers: _gameController.currentModel.consecutiveCorrect
          );
          break;
        case 'wrongAnswer':
          // Update progress for wrong answer
          _userProgress.updateProgress(
            difficulty: widget.difficulty, 
            gameScore: _gameController.currentModel.score, 
            consecutiveAnswers: 0
          );
          break;
        case 'gameOver':
          _userProgress.updateProgress(
            difficulty: widget.difficulty, 
            gameScore: _gameController.currentModel.score, 
            consecutiveAnswers: _gameController.currentModel.consecutiveCorrect
          );
          if (widget.onGameOver != null) {
            widget.onGameOver!(
              _gameController.currentModel.score, 
              _gameController.currentModel.gameStats,
              
            );
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

  // Widget _buildGameOverStage() {
  //     // Get overall rank from user progress
  // String overallRank = _userProgress.getOverallRank();
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       const Icon(
  //         Icons.sentiment_very_dissatisfied,
  //         size: 100,
  //         color: Colors.red,
  //       ),
  //       const SizedBox(height: 20),
  //       Text(
  //         'Game Over',
  //         style: GoogleFonts.montserrat(
  //           fontSize: 28,
  //           fontWeight: FontWeight.bold,
  //           color: Colors.red,
  //         ),
  //       ),
  //       const SizedBox(height: 10),
  //       Text(
  //         'Final Score: ${_gameController.currentModel.score}',
  //         textAlign: TextAlign.center,
  //         style: GoogleFonts.montserrat(
  //           fontSize: 22,
  //           fontWeight: FontWeight.w600,
  //         ),
  //       ),
  //       const SizedBox(height: 20),
  //       ElevatedButton(
  //         onPressed: _resetGame,
  //         child: Text(
  //           'Play Again',
  //           style: GoogleFonts.montserrat(
  //             fontSize: 18,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

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


Widget _buildGameOverStage() {
    // Get overall rank from user progress
    String overallRank = _userProgress.getOverallRank();

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
        Text(
          'Rank: $overallRank',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        // Display unlocked achievements
        ..._userProgress.unlockedAchievements.map((achievement) => 
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              '🏆 ${achievement.name}',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        ).toList(),
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