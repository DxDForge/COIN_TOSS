import 'package:flutter/material.dart';

class DifficultyConfig {
  static final Map<String, dynamic> config = {
    'Easy': {
      'timer': 20,
      'questionRange': 20,
      'operators': ['+', '-'],
      'complexity': 1,
      'levelsRequired': 4,
      'levelUpThreshold': 40,
      'rocketColor': Colors.green,
      'mastery': 'Math Explorer',
      'backgroundColor': [Colors.lightGreen[100]!, Colors.lightGreen[300]!],
      'gradientColors': [
        Color(0xFF6AB7F5),
        Color(0xFF1D7DD4)
      ]
    },
    'Medium': {
      'timer': 15,
      'questionRange': 50,
      'operators': ['+', '-', '*', '/'],
      'complexity': 2,
      'levelsRequired': 4,
      'levelUpThreshold': 80,
      'rocketColor': Colors.blue,
      'mastery': 'Math Adventurer',
      'backgroundColor': [Colors.blue[100]!, Colors.blue[300]!],
      'gradientColors': [
        Color(0xFFF6B458),
        Color(0xFFE86E4E)
      ]
    },
    'Hard': {
      'timer': 10,
      'questionRange': 100,
      'operators': ['+', '-', '*', '/', '^'],
      'complexity': 3,
      'levelsRequired': 4,
      'levelUpThreshold': 120,
      'rocketColor': Colors.red,
      'mastery': 'Math Champion',
      'backgroundColor': [Colors.deepOrange[100]!, Colors.deepOrange[300]!],
      'gradientColors': [
        Color(0xFF5D3FD3),
        Color(0xFF9D4EDD)
      ]
    }
  };
}