import 'dart:math';
import 'package:coin_toss/models/3dcoins.dart';
import 'package:coin_toss/models/coin_flip_model.dart';

import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CoinFlipController {
  final AudioPlayer audioPlayer;
  CoinType currentCoin;
  CoinFlipGameState gameState;
  final List<String> funPrompts;
  final List<Color> backgroundGradients;

  CoinFlipController({
    AudioPlayer? audioPlayer,
    required this.currentCoin,
    CoinFlipGameState? gameState,
    List<String>? funPrompts,
    List<Color>? backgroundGradients,
  }) : 
    audioPlayer = audioPlayer ?? AudioPlayer(),
    gameState = gameState ?? CoinFlipGameState(),
    funPrompts = funPrompts ?? [
      'Heads for Coffee, Tails for Tea?',
      'Who Pays the Bill?',
      'First Pick or Last Pick?',
      'Adventure or Relaxation?',
      'Your Fate Awaits!'
    ],
    backgroundGradients = backgroundGradients ?? [
      const Color(0xFF6A11CB),
      const Color(0xFF2575FC),
      const Color(0xFFFF5E62),
      const Color(0xFF42E695),
      const Color(0xFF3BB78F)
    ];

Future<void> loadSelectedCoin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCoinName = prefs.getString('selectedCoin');

    if (savedCoinName != null) {
      currentCoin = CoinTypes.availableCoins.firstWhere(
        (coin) => coin.name == savedCoinName,
        orElse: () => CoinTypes.getDefaultCoin()
      );
    }
  }

  Future<void> saveCoinSelection(CoinType coin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCoin', coin.name);
    currentCoin = coin;
  }

  void playSound(String path) async {
    try {
      await audioPlayer.play(AssetSource(path));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  CoinFlipResult flipCoin() {
    // Enhanced haptic feedback
    HapticFeedback.heavyImpact();
    playSound('assets/sounds/coin_flip.mp3');

    // Randomize result
    final result = Random().nextBool() ? 'Heads' : 'Tails';
    
    // Update game state
    gameState = gameState.copyWith(
      totalCoins: gameState.totalCoins + 1,
      currentStreak: result == 'Heads' ? gameState.currentStreak + 1 : 0,
      currentResult: result
    );

    playSound('assets/sounds/coin_land.mp3');

    return CoinFlipResult(
      result: result,
      newBackground: backgroundGradients[Random().nextInt(backgroundGradients.length)],
      newPrompt: funPrompts[Random().nextInt(funPrompts.length)]
    );
  }

  void dispose() {
    audioPlayer.dispose();
  }
}

class CoinFlipResult {
  final String result;
  final Color newBackground;
  final String newPrompt;

  CoinFlipResult({
    required this.result,
    required this.newBackground,
    required this.newPrompt
  });
}