import 'package:coin_toss/models/3dcoins.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinSelectionPage extends StatefulWidget {
  final Function(CoinType)? onCoinSelected;

  const CoinSelectionPage({Key? key, this.onCoinSelected}) : super(key: key);

  @override
  _CoinSelectionPageState createState() => _CoinSelectionPageState();
}

class _CoinSelectionPageState extends State<CoinSelectionPage> {
  CoinType? selectedCoin;
  String searchQuery = "";

  void _handleCoinTapped(CoinType coin) {
    setState(() {
      selectedCoin = coin;
    });
  }

  void _saveSelectedCoin() {
    if (selectedCoin == null) {
      _showWarningDialog();
      return;
    }

    // Save coin to SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('selectedCoin', selectedCoin!.name);
    });

    // Call the onCoinSelected callback if provided
    if (widget.onCoinSelected != null) {
      widget.onCoinSelected!(selectedCoin!);
    }

    // Navigate back to the previous screen and pass the selected coin
    Navigator.of(context).pop(selectedCoin);
  }

  @override
  Widget build(BuildContext context) {
    final filteredCoins = CoinTypes.availableCoins
        .where((coin) => coin.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.deepPurple[800],
      appBar: AppBar(
        title: Text(
          "Select Your Coin",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[900],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: "Search Coins",
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredCoins.length,
              itemBuilder: (context, index) {
                final coin = filteredCoins[index];
                return GestureDetector(
                  onTap: () => _handleCoinTapped(coin),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: selectedCoin?.name == coin.name 
                          ? Colors.deepPurple[700] 
                          : Colors.deepPurple[600],
                      borderRadius: BorderRadius.circular(15),
                      border: selectedCoin?.name == coin.name
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
Coin3D(
  coinType: coin,
  size: 120,
  isSpinning: selectedCoin?.name == coin.name,
  showTail: false, // Shows the head side by default
),
                        const SizedBox(height: 10),
                        Text(
                          coin.name,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: selectedCoin?.name == coin.name 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _saveSelectedCoin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Select Coin',
                style: GoogleFonts.poppins(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Warning",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Please select a coin first.",
            style: GoogleFonts.roboto(),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "OK",
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        );
      },
    );
  }
}