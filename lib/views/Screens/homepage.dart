import 'dart:math';
import 'package:coin_toss/models/3dcoins.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import pages
import 'coin_selection_page.dart';
import 'difficulty_selection_page.dart';
import 'settings_page.dart';

class CoinFlipHomePage extends StatefulWidget {
  const CoinFlipHomePage({Key? key}) : super(key: key);

  @override
  _CoinFlipHomePageState createState() => _CoinFlipHomePageState();
}

class _CoinFlipHomePageState extends State<CoinFlipHomePage>
    with SingleTickerProviderStateMixin {
  // Coin Selection
  CoinType _currentCoin = CoinTypes.getDefaultCoin();

  // Animation and Game State Controllers
  late AnimationController _flipAnimationController;
  late Animation<double> _flipAnimation;
  late ConfettiController _confettiController;

  // Audio and Game State
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isFlipping = false;
  String _currentResult = '?';
  int _currentStreak = 0;
  int _totalCoins = 0;

  // Scenario Management
  final Map<String, Map<String, dynamic>> _tossScenarios = {
    'Cricket Toss': {
      'description': 'Determine who bats or bowls first',
      'icon': Icons.sports_cricket,
      'background': Color(0xFF2C5E1A),
      'details': [
        'Winner chooses: Bat or Bowl',
        'Critical decision in match strategy',
        'Luck plays a crucial role'
      ]
    },
    'Bill Splitter': {
      'description': 'Decide who pays the restaurant bill',
      'icon': Icons.restaurant,
      'background': Color(0xFF4A4A4A),
      'details': [
        'Fair way to split expenses',
        'No hard feelings',
        'Quick decision maker'
      ]
    },
  };

  String _currentScenario = 'Cricket Toss';

  // Dynamic UI Elements
  final List<Color> _backgroundGradients = [
    const Color(0xFF6A11CB),
    const Color(0xFF2575FC),
    const Color(0xFFFF5E62),
    const Color(0xFF42E695),
    const Color(0xFF3BB78F)
  ];

  final List<String> _funPrompts = [
    'Heads for Coffee, Tails for Tea?',
    'Who Pays the Bill?',
    'First Pick or Last Pick?',
    'Adventure or Relaxation?',
    'Your Fate Awaits!'
  ];

  late Color _currentBackground;
  late String _currentPrompt;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _loadSelectedCoin();
  }

   Future<void> _loadSelectedCoin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCoinName = prefs.getString('selectedCoin');

    if (savedCoinName != null) {
      setState(() {
        _currentCoin = CoinTypes.availableCoins.firstWhere(
          (coin) => coin.name == savedCoinName,
          orElse: () => CoinTypes.getDefaultCoin()
        );
      });
    }
  }

  void _navigateToCoinSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoinSelectionPage(
          onCoinSelected: (CoinType selectedCoin) {
            setState(() {
              _currentCoin = selectedCoin;
            });
          },
        ),
      ),
    );

    if (result != null && result is CoinType) {
      setState(() {
        _currentCoin = result;
      });

      // Save selected coin to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedCoin', _currentCoin.name);
    }
  }

  void _initializeGame() {
    _initializeAnimations();
    _preloadSounds();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    // Set initial dynamic elements
    _currentPrompt = _funPrompts[Random().nextInt(_funPrompts.length)];
    _currentBackground = _backgroundGradients[Random().nextInt(_backgroundGradients.length)];
  }

  void _initializeAnimations() {
    _flipAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _flipAnimationController,
        curve: Curves.easeInOutQuart,
      ),
    );
  }

  void _preloadSounds() async {
    await _audioPlayer.play(AssetSource('sounds/coin_flip.mp3'));
    await _audioPlayer.play(AssetSource('sounds/coin_land.mp3'));
  }
  void _flipCoin() {
    if (_isFlipping) return;

    // Enhanced haptic and audio feedback
    HapticFeedback.heavyImpact();
    _playSound('assets/sounds/coin_flip.mp3');

    setState(() {
      _isFlipping = true;
      _currentResult = '?';
      // Change background and prompt on each toss
      _currentBackground = _backgroundGradients[Random().nextInt(_backgroundGradients.length)];
      _currentPrompt = _funPrompts[Random().nextInt(_funPrompts.length)];
    });

    _flipAnimationController.forward(from: 0.0);

    Future.delayed(const Duration(milliseconds: 1500), () {
      final result = Random().nextBool() ? 'Heads' : 'Tails';
      _playSound('assets/sounds/coin_land.mp3');

      setState(() {
        _currentResult = result;
        _isFlipping = false;
        _totalCoins++; 
        
        // Update streak logic
        _currentStreak = (_currentResult == 'Heads') ? _currentStreak + 1 : 0;
      });

      // Show result in a more engaging way
      _showResultDialog(result);

      // Trigger celebration for the result
      _confettiController.play();
    });
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  result == 'Heads' ? Colors.blue : Colors.red,
                  result == 'Heads' ? Colors.lightBlue : Colors.redAccent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Text(
                  'You Got',
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  result,
                  style: GoogleFonts.orbitron(
                    fontSize: 64,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(3.0, 3.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _playSound(String path) async {
    try {
      await _audioPlayer.play(AssetSource(path));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  // Custom Drawer Method
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
          
          // Scenario Selection
          _buildSectionHeader('Scenarios'),
          ..._tossScenarios.keys.map((scenario) => ListTile(
            leading: Icon(_tossScenarios[scenario]!['icon'], color: Colors.white),
            title: Text(
              scenario,
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              setState(() {
                _currentScenario = scenario;
                _currentResult = '?';
              });
              Navigator.pop(context);
            },
            tileColor: _currentScenario == scenario
              ? Colors.white.withOpacity(0.1)
              : null,
          )).toList(),

          // Navigation Section
          _buildSectionHeader('Navigation'),
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

  // Helper methods for drawer
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.roboto(
          color: Colors.white54,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

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
// UI Building Methods for CoinFlipHomePage

// Animated AppBar
PreferredSizeWidget _buildAnimatedAppBar() {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    title: AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          _currentScenario,
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
        onPressed: () {
          // Show scenario details
          _showScenarioDetails();
        },
      ),
    ],
  );
}

// Animated Background
Widget _buildAnimatedBackground() {
  return AnimatedContainer(
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
  );
}

// Dynamic Header
Widget _buildDynamicHeader() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(
      children: [
        Text(
          _currentPrompt,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Total Flips: $_totalCoins | Current Streak: $_currentStreak',
          style: GoogleFonts.roboto(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}
// Coin Flip Section
  Widget _buildCoinFlipSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _flipCoin,
            child: Coin3D(
              coinType: _currentCoin,
              size: 250,
              isSpinning: _isFlipping,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _currentResult,
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

// Footer Section
Widget _buildFooterSection() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Coin Selection Button
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
        
        // Scenario Details Button
        ElevatedButton.icon(
          onPressed: _showScenarioDetails,
          icon: const Icon(Icons.description, color: Colors.white),
          label: Text(
            'Scenario Details',
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
  );
}

// Show Scenario Details Method
void _showScenarioDetails() {
  final scenario = _tossScenarios[_currentScenario];
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: scenario?['background'] ?? Colors.grey[800],
        title: Text(
          _currentScenario,
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              scenario?['description'] ?? 'No description available',
              style: GoogleFonts.roboto(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 10),
            ...?scenario?['details']?.map((detail) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    detail,
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: _buildCustomDrawer(),
      appBar: _buildAnimatedAppBar(),
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                _buildDynamicHeader(),
                Expanded(child: _buildCoinFlipSection()),
                _buildFooterSection(),
              ],
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

  // Other UI building methods (AppBar, Header, Coin Flip Section, Footer)
  // These remain mostly the same as in the previous implementation
  
  @override
  void dispose() {
    _flipAnimationController.dispose();
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}















// import 'package:audioplayers/audioplayers.dart';
// import 'package:coin_toss/controllers/coin_flip_controller.dart';
// import 'package:coin_toss/models/3dcoins.dart';
// import 'package:coin_toss/views/Screens/coin_selection_page.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:shared_preferences/shared_preferences.dart';


// class CoinFlipHomePage extends StatefulWidget {
//   const CoinFlipHomePage({Key? key}) : super(key: key);

//   @override
//   _CoinFlipHomePageState createState() => _CoinFlipHomePageState();
// }

// class _CoinFlipHomePageState extends State<CoinFlipHomePage> 
//     with SingleTickerProviderStateMixin {
//   // Controller instance
//   late CoinFlipController _controller;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize controller with required dependencies
//     _controller = CoinFlipController(
//       audioPlayer: AudioPlayer(),
//       preferences: SharedPreferences.getInstance(),
//       currentCoin: CoinTypes.getDefaultCoin(),
//       currentScenario: 'Cricket Toss',
//       currentBackground: const Color(0xFF6A11CB),
//       currentPrompt: 'Your Fate Awaits!',
//     );

//     // Load selected coin
//     _controller.loadSelectedCoin();
//   }

//   // Navigation method for coin selection
//   void _navigateToCoinSelection() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CoinSelectionPage(
//           onCoinSelected: (CoinType selectedCoin) {
//             setState(() {
//               _controller.currentCoin = selectedCoin;
//             });
//             _controller.saveSelectedCoin(selectedCoin);
//           },
//         ),
//       ),
//     );
//   }

//   // Scenario details dialog
//   void _showScenarioDetails() {
//     final scenarios = {
//       'Cricket Toss': {
//         'description': 'Determine who bats or bowls first',
//         'icon': Icons.sports_cricket,
//         'background': const Color(0xFF2C5E1A),
//         'details': [
//           'Winner chooses: Bat or Bowl',
//           'Critical decision in match strategy',
//           'Luck plays a crucial role'
//         ]
//       },
//       // Add other scenarios here
//     };

//     final scenario = scenarios[_controller.currentScenario];
    
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: scenario?['background'] ?? Colors.grey[800],
//           title: Text(
//             _controller.currentScenario,
//             style: GoogleFonts.orbitron(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 scenario?['description'] ?? 'No description available',
//                 style: GoogleFonts.roboto(
//                   color: Colors.white70,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               ...?scenario?['details']?.map((detail) => Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 4.0),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.check_circle, color: Colors.white, size: 16),
//                     const SizedBox(width: 8),
//                     Text(
//                       detail,
//                       style: GoogleFonts.roboto(
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               )).toList(),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text(
//                 'Close',
//                 style: GoogleFonts.poppins(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Animated AppBar
//   PreferredSizeWidget _buildAnimatedAppBar() {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       title: AnimatedTextKit(
//         animatedTexts: [
//           TypewriterAnimatedText(
//             _controller.currentScenario,
//             textStyle: GoogleFonts.orbitron(
//               color: Colors.white,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//             speed: const Duration(milliseconds: 100),
//           ),
//         ],
//         totalRepeatCount: 1,
//         pause: const Duration(milliseconds: 1000),
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.info_outline, color: Colors.white),
//           onPressed: _showScenarioDetails,
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       drawer: CustomDrawer(
//         onCoinSelection: _navigateToCoinSelection,
//         onDifficultyGame: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => DifficultyProgressScreen()),
//         ),
//         onSettings: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => SettingsPage()),
//         ),
//       ),
//       appBar: _buildAnimatedAppBar(),
//       body: Stack(
//         children: [
//           AnimatedBackground(backgroundColor: _controller.currentBackground),
//           SafeArea(
//             child: Column(
//               children: [
//                 DynamicHeader(
//                   prompt: _controller.currentPrompt,
//                   totalCoins: _controller.totalCoins,
//                   currentStreak: _controller.currentStreak,
//                 ),
//                 Expanded(
//                   child: CoinFlipSection(
//                     currentCoin: _controller.currentCoin,
//                     isFlipping: _controller.isFlipping,
//                     currentResult: _controller.currentResult,
//                     onFlip: () => setState(_controller.flipCoin),
//                   ),
//                 ),
//                 FooterSection(
//                   onCoinSelect: _navigateToCoinSelection,
//                   onScenarioDetails: _showScenarioDetails,
//                 ),
//               ],
//             ),
//           ),
//           ConfettiOverlay(),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.audioPlayer.dispose();
//     super.dispose();
//   }
// }