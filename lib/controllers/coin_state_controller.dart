// import 'package:coin_toss/models/coin.dart';
// import 'package:flutter/material.dart';

// class CoinState with ChangeNotifier {
//   Coin _selectedCoin = Coin(name: "Default Coin", imagePath: "assets/default.png");

//   Coin get selectedCoin => _selectedCoin;

//   void updateSelectedCoin(Coin coin) {
//     _selectedCoin = coin;
//     notifyListeners(); // Notify all listeners about the change
//   }
// }





// import 'package:flutter/foundation.dart';

// class CoinStateController extends ChangeNotifier {
//   String _selectedCoin = "Default Coin"; // Default value

//   String get selectedCoin => _selectedCoin;

//   void setSelectedCoin(String coin) {
//     _selectedCoin = coin;
//     notifyListeners(); // Notify listeners about the change
//   }
// }
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinStateController with ChangeNotifier {
  String _selectedCoin = 'Bitcoin'; // Default coin

  String get selectedCoin => _selectedCoin;

  CoinStateController() {
    // Load the saved coin when the controller is created
    _loadSelectedCoin();
  }

  void _loadSelectedCoin() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCoin = prefs.getString('selectedCoin') ?? 'Bitcoin';
    notifyListeners();
  }

  void selectCoin(String coin) async {
    _selectedCoin = coin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCoin', coin);
    notifyListeners();
  }
}

