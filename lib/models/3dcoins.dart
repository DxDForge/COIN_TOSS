// import 'package:flutter/material.dart';
// import 'dart:math' as math;

// class CoinType {
//   final String name;
//   final Color primaryColor;
//   final Color secondaryColor;
//   final String symbol;

//   const CoinType({
//     required this.name, 
//     required this.primaryColor, 
//     required this.secondaryColor,
//     required this.symbol,
//   });
// }

// class Coin3D extends StatefulWidget {
//   final CoinType coinType;
//   final double size;
//   final bool isSpinning;
//   final VoidCallback? onTap;

//   const Coin3D({
//     Key? key,
//     required this.coinType,
//     this.size = 200,
//     this.isSpinning = false,
//     this.onTap,
//   }) : super(key: key);

//   @override
//   _Coin3DState createState() => _Coin3DState();
// }

// class _Coin3DState extends State<Coin3D> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _rotationAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimation();
//   }

//   void _initializeAnimation() {
//     _controller = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     )..repeat();

//     _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.linear,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: AnimatedBuilder(
//         animation: _rotationAnimation,
//         builder: (context, child) {
//           return Transform(
//             alignment: Alignment.center,
//             transform: Matrix4.identity()
//               ..rotateY(widget.isSpinning ? _rotationAnimation.value : 0)
//               ..rotateX(0.2), // Slight tilt for 3D effect
//             child: Container(
//               width: widget.size,
//               height: widget.size,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: LinearGradient(
//                   colors: [
//                     widget.coinType.primaryColor,
//                     widget.coinType.secondaryColor,
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.3),
//                     blurRadius: 15,
//                     spreadRadius: 3,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       widget.coinType.symbol,
//                       style: TextStyle(
//                         fontSize: widget.size * 0.3,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         shadows: [
//                           Shadow(
//                             blurRadius: 10.0,
//                             color: Colors.black.withOpacity(0.5),
//                             offset: const Offset(2, 2),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Text(
//                       widget.coinType.name,
//                       style: TextStyle(
//                         fontSize: widget.size * 0.1,
//                         color: Colors.white70,
//                         fontWeight: FontWeight.w300,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }

// // Predefined Coin Types
// class CoinTypes {
//   static final List<CoinType> availableCoins = [
//     const CoinType(
//       name: 'Bitcoin', 
//       primaryColor: Color(0xFFFF9800),
//       secondaryColor: Color(0xFFF57C00),
//       symbol: '₿',
//     ),
//     const CoinType(
//       name: 'Ethereum', 
//       primaryColor: Color(0xFF2196F3),
//       secondaryColor: Color(0xFF1976D2),
//       symbol: 'Ξ',
//     ),
//     const CoinType(
//       name: 'Litecoin', 
//       primaryColor: Color(0xFFA0A0A0),
//       secondaryColor: Color(0xFF707070),
//       symbol: 'Ł',
//     ),
//     const CoinType(
//       name: 'Cardano', 
//       primaryColor: Color(0xFF3C3C3D),
//       secondaryColor: Color(0xFF212121),
//       symbol: '₳',
//     ),
//     const CoinType(
//       name: 'Ripple', 
//       primaryColor: Color(0xFF4CAF50),
//       secondaryColor: Color(0xFF388E3C),
//       symbol: '✕',
//     ),
//     const CoinType(
//       name: 'Default', 
//       primaryColor: Color(0xFF9C27B0),
//       secondaryColor: Color(0xFF7B1FA2),
//       symbol: '◎',
//     ),
//   ];

//   static CoinType getDefaultCoin() {
//     return availableCoins.last;
//   }
// }

import 'package:flutter/material.dart';
import 'dart:math' as math;

class CoinType {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final String symbol;
  final String headImagePath;
  final String tailImagePath;
  final String countryOfOrigin;

  const CoinType({
    required this.name, 
    required this.primaryColor, 
    required this.secondaryColor,
    required this.symbol,
    this.headImagePath = '',
    this.tailImagePath = '',
    this.countryOfOrigin = '',
  });
}

class Coin3D extends StatefulWidget {
  final CoinType coinType;
  final double size;
  final bool isSpinning;
  final VoidCallback? onTap;
  final bool showTail;

  const Coin3D({
    Key? key,
    required this.coinType,
    this.size = 200,
    this.isSpinning = false,
    this.onTap,
    this.showTail = false,
  }) : super(key: key);

  @override
  _Coin3DState createState() => _Coin3DState();
}

class _Coin3DState extends State<Coin3D> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  Widget _buildCoinFace(bool isTail) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            widget.coinType.primaryColor,
            widget.coinType.secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: isTail 
          ? _buildTailSide() 
          : _buildHeadSide(),
      ),
    );
  }

  Widget _buildHeadSide() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.coinType.symbol,
          style: TextStyle(
            fontSize: widget.size * 0.3,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(2, 2),
              ),
            ],
          ),
        ),
        Text(
          widget.coinType.name,
          style: TextStyle(
            fontSize: widget.size * 0.1,
            color: Colors.white70,
            fontWeight: FontWeight.w300,
          ),
        ),
        if (widget.coinType.countryOfOrigin.isNotEmpty)
          Text(
            widget.coinType.countryOfOrigin,
            style: TextStyle(
              fontSize: widget.size * 0.08,
              color: Colors.white54,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildTailSide() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'COIN VALUE',
          style: TextStyle(
            fontSize: widget.size * 0.15,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          '1 UNIT',
          style: TextStyle(
            fontSize: widget.size * 0.2,
            color: Colors.white70,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateY(widget.isSpinning ? _rotationAnimation.value : 
                (widget.showTail ? math.pi : 0))
              ..rotateX(0.2), // Slight tilt for 3D effect
            child: _buildCoinFace(widget.showTail),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Predefined Coin Types
class CoinTypes {
  static final List<CoinType> availableCoins = [
    const CoinType(
      name: 'Bitcoin', 
      primaryColor: Color(0xFFFF9800),
      secondaryColor: Color(0xFFF57C00),
      symbol: '₿',
      countryOfOrigin: 'Crypto Realm',
    ),
    const CoinType(
      name: 'Ethereum', 
      primaryColor: Color(0xFF2196F3),
      secondaryColor: Color(0xFF1976D2),
      symbol: 'Ξ',
      countryOfOrigin: 'Blockchain Nation',
    ),
    const CoinType(
      name: 'Litecoin', 
      primaryColor: Color(0xFFA0A0A0),
      secondaryColor: Color(0xFF707070),
      symbol: 'Ł',
      countryOfOrigin: 'Digital Territory',
    ),
    const CoinType(
      name: 'Cardano', 
      primaryColor: Color(0xFF3C3C3D),
      secondaryColor: Color(0xFF212121),
      symbol: '₳',
      countryOfOrigin: 'Smart Contract State',
    ),
    const CoinType(
      name: 'Ripple', 
      primaryColor: Color(0xFF4CAF50),
      secondaryColor: Color(0xFF388E3C),
      symbol: '✕',
      countryOfOrigin: 'Global Transfer Empire',
    ),
    const CoinType(
      name: 'Default', 
      primaryColor: Color(0xFF9C27B0),
      secondaryColor: Color(0xFF7B1FA2),
      symbol: '◎',
      countryOfOrigin: 'Coin Toss Kingdom',
    ),
  ];

  static CoinType getDefaultCoin() {
    return availableCoins.last;
  }
}