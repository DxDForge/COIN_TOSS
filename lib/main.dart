import 'package:coin_toss/controllers/coin_slection_state_controller.dart';
import 'package:coin_toss/views/Screens/coin_selection_page.dart';
import 'package:coin_toss/views/Screens/difficulty_selection_page.dart';
import 'package:coin_toss/views/Screens/homepage.dart';
import 'package:coin_toss/views/Screens/quiz_page.dart';
import 'package:coin_toss/views/Screens/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CoinStateController(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      title: 'Coin Toss Game',
      initialRoute: '/',
      routes: {
        '/': (context) =>const CoinFlipHomePage(),
        '/settings': (context) => SettingsPage(),
        '/coinSelection': (context) =>  CoinSelectionPage(),
        '/playGames': (context) =>const DifficultyProgressScreen(), // Updated route
        '/quiz': (context) => QuizPage(),
      },
    );
  }
}
