import 'package:coin_toss/controllers/coin_flip_controller.dart';
import 'package:coin_toss/models/3dcoins.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:math';

// Import necessary pages and dependencies
import 'coin_selection_page.dart';
import 'difficulty_selection_page.dart';
import 'settings_page.dart';

class CoinFlipHomePage extends StatefulWidget {
  const CoinFlipHomePage({Key? key}) : super(key: key);

  @override
  _CoinFlipHomePageState createState() => _CoinFlipHomePageState();
}

class _CoinFlipHomePageState extends State<CoinFlipHomePage> 
    with TickerProviderStateMixin {
  
  // Controller and State Management
  late CoinFlipController _controller;
  late ConfettiController _confettiController;
  late AnimationController _flipAnimationController;
  late AnimationController _resultAnimationController;
  
  // State Variables
  CoinType _currentCoin = CoinTypes.getDefaultCoin();
  Color _currentBackground = const Color(0xFF6A11CB);
  String _currentPrompt = 'Your Fate Awaits!';
  bool _isFlipping = false;
  bool _showResultOverlay = false;
  String _currentResult = '';
  String _resultInterpretation = '';
  late Animation<double> _resultAnimation;

  // Psychological Engagement Mechanisms
  final List<String> _dramaticPhrases = [
    'Destiny unfolds...',
    'The universe decides...',
    'Fate is about to speak...',
    'Cosmic winds are turning...',
    'Secrets are revealing...',
  ];

  final Map<String, List<String>> _resultInterpretations = {
    'Heads': [
      'Leadership is calling',
      'Embrace your inner visionary',
      'Your intuition is spot on',
      'Opportunities are aligning',
      'Confidence is your superpower'
    ],
    'Tails': [
      'Reflect and recalibrate',
      'Hidden wisdom awaits',
      'Patience is your strength',
      'Explore alternative paths',
      'Inner peace is your guide'
    ]
  };

  @override
  void initState() {
    super.initState();
    
    // Initialize Controllers
    _controller = CoinFlipController(
      currentCoin: _currentCoin,
    );
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2)
    );
    
    // Initialize Animations
    _flipAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Result Reveal Animation
    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _resultAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _resultAnimationController,
        curve: Curves.elasticOut,
      )
    );

    // Load Selected Coin
    _controller.loadSelectedCoin().then((_) {
      setState(() {
        _currentCoin = _controller.currentCoin;
      });
    });
  }

  // Enhanced Dramatic Result Reveal Method
  void _revealResult(String result) {
    // Select a random dramatic phrase
    final dramaticPhrase = _dramaticPhrases[Random().nextInt(_dramaticPhrases.length)];
    
    // Select a random interpretation for the result
    final interpretations = _resultInterpretations[result] ?? [];
    final interpretation = interpretations.isNotEmpty 
      ? interpretations[Random().nextInt(interpretations.length)] 
      : 'Your moment of truth';

    setState(() {
      _showResultOverlay = true;
      _currentResult = result;
      _resultInterpretation = interpretation;
      _currentBackground = result == 'Heads' 
        ? const Color(0xFF4A90E2)  // Vibrant blue for Heads
        : const Color(0xFFE74C3C); // Energetic red for Tails
    });

    // Trigger result animation
    _resultAnimationController.forward(from: 0.0);

    // Auto-dismiss result after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showResultOverlay = false;
      });
    });
  }

  // Coin Flip Method
  void _flipCoin() {
    if (_isFlipping) return;

    setState(() {
      _isFlipping = true;
      _showResultOverlay = false;
    });

    _flipAnimationController.forward(from: 0.0);

    Future.delayed(const Duration(milliseconds: 1500), () {
      final flipResult = _controller.flipCoin();
      
      setState(() {
        _currentBackground = flipResult.newBackground;
        _currentPrompt = flipResult.newPrompt;
        _isFlipping = false;
      });

      _revealResult(flipResult.result);
      _confettiController.play();
    });
  }

  // Navigation Methods
  void _navigateToCoinSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoinSelectionPage(
          onCoinSelected: (CoinType selectedCoin) {
            _controller.saveCoinSelection(selectedCoin);
            setState(() {
              _currentCoin = selectedCoin;
            });
          },
        ),
      ),
    );
  }

  // Information Dialog
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Coin Toss Mechanics',
            style: GoogleFonts.orbitron(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎲 Each flip is a 50/50 chance\n'
                '🌈 Dynamic backgrounds reflect your luck\n'
                '🪙 Collect and customize your coins\n'
                '📊 Track your flip history and streaks',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Tip: The more you flip, the more exciting it gets!',
                style: GoogleFonts.poppins(
                  fontStyle: FontStyle.italic,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'Got it!', 
                style: GoogleFonts.poppins(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Build Drawer (Keeping the previous implementation)
  Drawer _buildCustomDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF16213E),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF16213E),
                  Color(0xFF0F3460),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Coin Toss App',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Navigate and Explore',
                  style: GoogleFonts.roboto(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation Items (keeping previous implementation)
          _buildDrawerNavItem(
            icon: Icons.home,
            title: 'Home',
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerNavItem(
            icon: Icons.select_all,
            title: 'Custom Coin',
            onTap: () => _navigateToCoinSelection(),
          ),
          _buildDrawerNavItem(
            icon: Icons.games,
            title: 'Coin Toss Game',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DifficultyProgressScreen()),
            ),
          ),
          _buildDrawerNavItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            ),
          ),
        ],
      ),
    );
  }

  // Drawer Navigation Item Helper
  Widget _buildDrawerNavItem({
    required IconData icon, 
    required String title, 
    required VoidCallback onTap
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: GoogleFonts.roboto(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: _buildCustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              'Coin Toss',
              textStyle: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              speed: const Duration(milliseconds: 100),
            ),
          ],
          totalRepeatCount: 1,
          pause: const Duration(milliseconds: 1000),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated Background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _currentBackground,
                  _currentBackground.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Dynamic Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      Text(
                        _isFlipping ? 'Spinning...' : _currentPrompt,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Flips: ${_controller.gameState.totalCoins} | Current Streak: ${_controller.gameState.currentStreak}',
                        style: GoogleFonts.roboto(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Coin Flip Section
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _flipCoin,
                          child: Coin3D(
                            coinType: _currentCoin,
                            size: 250,
                            isSpinning: _isFlipping,
                            spinIntensity: SpinIntensity.medium,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _controller.gameState.currentResult,
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _navigateToCoinSelection,
                        icon: const Icon(Icons.monetization_on, color: Colors.white),
                        label: Text(
                          'Select Coin',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),



          // Result Overlay
if (_showResultOverlay)
            Positioned.fill(
              child: ScaleTransition(
                scale: _resultAnimation,
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Dramatic Prelude
                        Text(
                          'The Moment of Truth',
                          style: GoogleFonts.orbitron(
                            color: Colors.white70,
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Animated Result
                        AnimatedTextKit(
                          animatedTexts: [
                            ScaleAnimatedText(
                              _currentResult,
                              textStyle: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontSize: 72,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(5.0, 5.0),
                                  ),
                                ],
                              ),
                              scalingFactor: 0.5,
                            ),
                          ],
                          totalRepeatCount: 1,
                          pause: const Duration(milliseconds: 500),
                        ),
                        
                        // Inspirational Interpretation
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Text(
                            _resultInterpretation,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Confetti Overlay
          Positioned.fill(
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _flipAnimationController.dispose();
    _resultAnimationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}