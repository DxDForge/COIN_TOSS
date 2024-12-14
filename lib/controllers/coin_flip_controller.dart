// controllers/coin_flip_controller.dart
import 'dart:math';
import 'package:coin_toss/models/3dcoins.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CoinFlipController {
  // Game State
  CoinType currentCoin;
  bool isFlipping = false;
  String currentResult = '?';
  int currentStreak = 0;
  int totalCoins = 0;
  String currentScenario;
  Color currentBackground;
  String currentPrompt;

  // Dependencies
  final AudioPlayer audioPlayer;
  final SharedPreferences preferences;

  CoinFlipController({
    required this.audioPlayer,
    required this.preferences,
    required this.currentCoin,
    required this.currentScenario,
    required this.currentBackground,
    required this.currentPrompt,
  });

  Future<void> loadSelectedCoin() async {
    final savedCoinName = preferences.getString('selectedCoin');
    if (savedCoinName != null) {
      currentCoin = CoinTypes.availableCoins.firstWhere(
        (coin) => coin.name == savedCoinName,
        orElse: () => CoinTypes.getDefaultCoin()
      );
    }
  }

  Future<void> saveSelectedCoin(CoinType coin) async {
    await preferences.setString('selectedCoin', coin.name);
  }

  void flipCoin() {
    if (isFlipping) return;

    HapticFeedback.heavyImpact();
    playSound('assets/sounds/coin_flip.mp3');

    isFlipping = true;
    currentResult = '?';
    
    // Randomize background and prompt
    currentBackground = _getRandomBackground();
    currentPrompt = _getRandomPrompt();

    // Simulate coin flip
    Future.delayed(Duration(milliseconds: 1500), () {
      final result = Random().nextBool() ? 'Heads' : 'Tails';
      playSound('assets/sounds/coin_land.mp3');

      currentResult = result;
      isFlipping = false;
      totalCoins++;
      
      // Update streak logic
      currentStreak = (currentResult == 'Heads') ? currentStreak + 1 : 0;
    });
  }

  void playSound(String path) async {
    try {
      await audioPlayer.play(AssetSource(path));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  // Helper methods for randomization
  Color _getRandomBackground() {
    final backgroundGradients = [
      const Color(0xFF6A11CB),
      const Color(0xFF2575FC),
      const Color(0xFF0F3460)
    ];
    return backgroundGradients[Random().nextInt(backgroundGradients.length)];
  }

  String _getRandomPrompt() {
    final funPrompts = [
      'Heads for Coffee, Tails for Tea?',
      'Who Pays the Bill?',
      'First Pick or Last Pick?'
    ];
    return funPrompts[Random().nextInt(funPrompts.length)];
  }

  // Scenario management
  void changeScenario(String scenario) {
    currentScenario = scenario;
    currentResult = '?';
  }
}