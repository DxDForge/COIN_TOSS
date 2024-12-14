// lib/controllers/preferences_controller.dart
import 'package:coin_toss/models/3dcoins.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesController {
  Future<CoinType> loadSelectedCoin(List<CoinType> availableCoins) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCoinName = prefs.getString('selectedCoin');

    if (savedCoinName != null) {
      return availableCoins.firstWhere(
        (coin) => coin.name == savedCoinName,
        orElse: () => CoinTypes.getDefaultCoin()
      );
    }

    return CoinTypes.getDefaultCoin();
  }

  Future<void> saveSelectedCoin(CoinType coin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCoin', coin.name);
  }
}