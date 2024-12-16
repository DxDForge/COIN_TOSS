import 'package:flutter/material.dart';

// Coin Type Model
class CoinType_FlipModel {
  final String name;
  final String imagePath;
  final Color color;

  const CoinType_FlipModel({
    required this.name, 
    required this.imagePath, 
    required this.color
  });
}

class CoinTypesss {
  static  List<CoinType_FlipModel> availableCoins = [
    const CoinType_FlipModel(
      name: 'US Quarter',
      imagePath: 'assets/coins/us_quarter.png',
      color: Colors.blue,
    ),
    const CoinType_FlipModel(
      name: 'Euro Coin',
      imagePath: 'assets/coins/euro_coin.png',
      color: Colors.green,
    ),
    // Add more coin types as needed
  ];

  static CoinType_FlipModel getDefaultCoin() {
    return availableCoins.first;
  }
}

// Scenario Model
class TossScenario {
  final String name;
  final String description;
  final IconData icon;
  final Color backgroundColor;
  final List<String> details;

  const TossScenario({
    required this.name,
    required this.description,
    required this.icon,
    required this.backgroundColor,
    required this.details,
  });
}

class ScenarioRepository {
  static final Map<String, TossScenario> scenarios = {
    'Cricket Toss': const TossScenario(
      name: 'Cricket Toss',
      description: 'Determine who bats or bowls first',
      icon: Icons.sports_cricket,
      backgroundColor: Color(0xFF2C5E1A),
      details: [
        'Winner chooses: Bat or Bowl',
        'Critical decision in match strategy',
        'Luck plays a crucial role'
      ],
    ),
    'Bill Splitter': const TossScenario(
      name: 'Bill Splitter',
      description: 'Decide who pays the restaurant bill',
      icon: Icons.restaurant,
      backgroundColor: Color(0xFF4A4A4A),
      details: [
        'Fair way to split expenses',
        'No hard feelings',
        'Quick decision maker'
      ],
    ),
  };

  static TossScenario getScenarioByName(String name) {
    return scenarios[name] ?? scenarios.values.first;
  }
}

// Game State Model
class CoinFlipGameState {
  int totalCoins;
  int currentStreak;
  String currentResult;

  CoinFlipGameState({
    this.totalCoins = 0,
    this.currentStreak = 0,
    this.currentResult = '?',
  });

  CoinFlipGameState copyWith({
    int? totalCoins,
    int? currentStreak,
    String? currentResult,
  }) {
    return CoinFlipGameState(
      totalCoins: totalCoins ?? this.totalCoins,
      currentStreak: currentStreak ?? this.currentStreak,
      currentResult: currentResult ?? this.currentResult,
    );
  }
}