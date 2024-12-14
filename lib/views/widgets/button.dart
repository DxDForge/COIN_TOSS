import 'package:flutter/material.dart';

class GlossyButtonExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Glossy Button Example'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            // Action for the Flip Coin button
            print("Flip Coin button clicked!");
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)], // Gradient colors
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 40.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Adding a glossy effect overlay
                  Opacity(
                    opacity: 0.3,
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      margin: const EdgeInsets.only(top: 3, left: 5, right: 5),
                    ),
                  ),
                  const Text(
                    'Flip Coin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          blurRadius: 3,
                          color: Colors.black38,
                          offset: Offset(1, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: GlossyButtonExample(),
  ));
}
