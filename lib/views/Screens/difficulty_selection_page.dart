import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:coin_toss/views/Screens/game_screen.dart';

class DifficultyProgressScreen extends StatefulWidget {
  const DifficultyProgressScreen({Key? key}) : super(key: key);

  @override
  _DifficultyProgressScreenState createState() => _DifficultyProgressScreenState();
}

class _DifficultyProgressScreenState extends State<DifficultyProgressScreen> 
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _difficultyLevels = [
    {
      'difficulty': 'Easy',
      'color': const Color(0xFF4CAF50),
      'icon': FontAwesomeIcons.seedling,
      'description': 'Gentle introduction to math challenges',
      'reward': '100 Coins & Starter Badge',
      'gradient': [
        Color(0xFF81C784),
        Color(0xFF4CAF50),
      ]
    },
    {
      'difficulty': 'Medium',
      'color': const Color(0xFFFFA726),
      'icon': FontAwesomeIcons.fire,
      'description': 'Moderate problems to test your skills',
      'reward': '250 Coins & Progress Badge',
      'gradient': [
        Color(0xFFFFB74D),
        Color(0xFFFFA726),
      ]
    },
    {
      'difficulty': 'Hard',
      'color': const Color(0xFFFF5722),
      'icon': FontAwesomeIcons.bolt,
      'description': 'Challenging problems for math champions',
      'reward': '500 Coins & Master Badge',
      'gradient': [
        Color(0xFFFF7043),
        Color(0xFFFF5722),
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Gradient Background
              _buildGradientBackground(),

              // Main Content
              SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildHeader(constraints),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _buildDifficultyCard(
                              context, 
                              _difficultyLevels[index],
                              index
                            );
                          },
                          childCount: _difficultyLevels.length,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildFooter(),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepPurple[200]!,
            Colors.deepPurple[400]!,
            Colors.deepPurple[600]!,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Math Superhero Challenge',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: constraints.maxWidth * 0.07,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ).animate()
            .fadeIn(duration: 600.ms)
            .shimmer(duration: 1500.ms),
          
          const SizedBox(height: 8),
          
          Text(
            'Unlock Your Mathematical Potential!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: constraints.maxWidth * 0.04,
              fontWeight: FontWeight.w300,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ).animate()
            .fadeIn(delay: 300.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard(BuildContext context, Map<String, dynamic> difficulty, int index) {
    return GestureDetector(
      onTap: () => _startGame(difficulty['difficulty']),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: difficulty['gradient'],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: difficulty['color'].withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ]
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Animated Icon
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: FaIcon(
                  difficulty['icon'],
                  color: Colors.white,
                  size: 30,
                ),
              ).animate()
                .shake(delay: 200.ms * index)
                .scale(duration: 500.ms),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      difficulty['difficulty'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      difficulty['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reward: ${difficulty['reward']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow[200],
                      ),
                    ),
                  ],
                ),
              ),

              // Play Icon
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ).animate()
                .fade(delay: 300.ms * index)
                .scale(duration: 500.ms),
            ],
          ),
        ),
      ).animate()
        .fadeIn(delay: 300.ms * index)
        .slideX(begin: 0.1, end: 0, duration: 500.ms),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Center(
        child: Text(
          'Every Problem Solved is a Step Towards Greatness! 🚀🌟',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ).animate()
          .fadeIn(delay: 1000.ms)
          .shimmer(duration: 1500.ms),
      ),
    );
  }

  void _startGame(String difficulty) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => 
            GameScreen(difficulty: difficulty),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.easeInOutQuart;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}