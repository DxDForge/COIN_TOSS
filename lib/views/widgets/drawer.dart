import 'package:coin_toss/views/Screens/coin_selection_page.dart';
import 'package:coin_toss/views/Screens/difficulty_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: const Color(0xFF1E1E2C),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF2C2C3E)),
              child: Center(
                child: Text(
                  'Coin Flip App',
                  style:
                      GoogleFonts.orbitron(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.select_all, color: Colors.white),
              title: const Text('Custom Coin',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoinSelectionPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.games, color: Colors.white),
              title: const Text('Game', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DifficultyProgressScreen(),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title:
                  const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ));
  }
}
