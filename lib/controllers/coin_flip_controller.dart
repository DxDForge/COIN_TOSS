import 'dart:math';
import 'package:coin_toss/models/3dcoins.dart';
import 'package:coin_toss/models/Scenario.dart';
import 'package:coin_toss/models/coin_flip_model.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart'; // Added for Color

class CoinFlipResult {
  final String result;
  final Color newBackground;
  final String newPrompt;
  final String? winnerName;
  final String? loserName;
  final String? scenarioOutcome;

  CoinFlipResult({
    required this.result,
    required this.newBackground,
    required this.newPrompt,
    this.winnerName,
    this.loserName,
    this.scenarioOutcome,
  });
}

class CoinFlipController {
  final AudioPlayer audioPlayer;
  CoinType currentCoin;
  CoinFlipGameState gameState;
  final List<String> funPrompts;
  final List<Color> backgroundGradients;
  Scenario? currentScenario;
  String? player1Name;
  String? player1Side;
  String? player2Name;
  String? player2Side;

  CoinFlipController({
    AudioPlayer? audioPlayer,
    required this.currentCoin,
    CoinFlipGameState? gameState,
    List<String>? funPrompts,
    List<Color>? backgroundGradients,
  })  : audioPlayer = audioPlayer ?? AudioPlayer(),
        gameState = gameState ?? CoinFlipGameState(),
        funPrompts = funPrompts ??
            [
              'Heads for Coffee, Tails for Tea?',
              'Who Pays the Bill?',
              'First Pick or Last Pick?',
              'Adventure or Relaxation?',
              'Your Fate Awaits!',
            ],
        backgroundGradients = backgroundGradients ??
            [
              const Color(0xFF6A11CB),
              const Color(0xFF2575FC),
              const Color(0xFFFF5E62),
              const Color(0xFF42E695),
              const Color(0xFF3BB78F),
            ];

  Future<void> loadSelectedCoin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCoinName = prefs.getString('selectedCoin');

    if (savedCoinName != null) {
      currentCoin = CoinTypes.availableCoins.firstWhere(
        (coin) => coin.name == savedCoinName,
        orElse: () => CoinTypes.getDefaultCoin(),
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

  String _getScenarioOutcome(String scenarioTitle, String winnerName, String loserName) {
    switch (scenarioTitle) {
      case 'Who Pays the Bill?':
        return '$winnerName wins! $loserName will pay the bill.';
      case 'Cricket Toss':
        return '$winnerName wins the toss and gets to choose batting or fielding.';
      case 'First Pick or Last Pick':
        return '$winnerName gets to choose first or last.';
      case 'Random Decision':
        return '$winnerName gets to make the final decision.';
      case 'Adventure or Relaxation':
        return '$winnerName chooses between adventure or relaxation.';
      default:
        return '$winnerName wins the $scenarioTitle!';
    }
  }

  CoinFlipResult flipCoin({bool isScenarioMode = false}) {
    HapticFeedback.heavyImpact();
    playSound('sounds/coin_flip.mp3');

    // Randomize result
    final result = Random().nextBool() ? 'Heads' : 'Tails';

    // Update game state
    gameState = gameState.copyWith(
      totalCoins: gameState.totalCoins + 1,
      currentStreak: result == 'Heads' ? gameState.currentStreak + 1 : 0,
      currentResult: result,
    );
    playSound('sounds/coin_land.mp3');

    if (isScenarioMode && currentScenario != null) {
      bool player1Wins = (result == player1Side);
      String winnerName = player1Wins ? player1Name! : player2Name!;
      String loserName = player1Wins ? player2Name! : player1Name!;
      String newPrompt = _getScenarioOutcome(currentScenario!.title, winnerName, loserName);

      return CoinFlipResult(
        result: result,
        newBackground: backgroundGradients[Random().nextInt(backgroundGradients.length)],
        newPrompt: newPrompt,
        winnerName: winnerName,
        loserName: loserName,
        scenarioOutcome: newPrompt,
      );
    }

    // Default non-scenario result
    return CoinFlipResult(
      result: result,
      newBackground: backgroundGradients[Random().nextInt(backgroundGradients.length)],
      newPrompt: funPrompts[Random().nextInt(funPrompts.length)],
    );
  }

  void setScenario(Scenario scenario, String player1, String player1SideInput, String player2, String player2SideInput) {
    currentScenario = scenario;
    player1Name = player1;
    player1Side = player1SideInput;
    player2Name = player2;
    player2Side = player2SideInput;
  }

  void dispose() {
    audioPlayer.dispose();
  }
}