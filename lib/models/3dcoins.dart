import 'package:flutter/material.dart';
import 'dart:math' as math;

enum CoinMaterial {
  gold,
  silver,
  bronze,
  crystal,
  holographic,
  custom,
}

class CoinType {
  final String name;
  final CoinMaterial material;
  final Color primaryColor;
  final Color secondaryColor;
  final String symbol;
  final String countryOfOrigin;
  final List<Color> reflectionGradient;
  final CoinRotationStyle rotationStyle;
  final CoinDesignStyle designStyle;

  const CoinType({
    required this.name,
    this.material = CoinMaterial.silver,
    required this.primaryColor,
    required this.secondaryColor,
    required this.symbol,
    this.countryOfOrigin = 'Blockchain Realm',
    this.reflectionGradient = const [
      Color(0xFFE0E0E0),
      Color(0xFFF5F5F5),
      Color(0xFFBDBDBD),
    ],
    this.rotationStyle = CoinRotationStyle.standard,
    this.designStyle = CoinDesignStyle.classic,
  });
}

enum CoinRotationStyle {
  standard,
  diagonal,
  verticalWave,
  horizontalWave,
  elliptical,
  zigzag,
}

enum CoinDesignStyle {
  classic,
  modern,
  futuristic,
  ancient,
  minimalist,
  ornate,
}

class Coin3D extends StatefulWidget {
  final CoinType coinType;
  final double size;
  final bool isSpinning;
  final SpinIntensity spinIntensity;
  final VoidCallback? onTap;
  final bool showTail;

  const Coin3D({
    Key? key,
    required this.coinType,
    this.size = 250,
    this.isSpinning = false,
    this.spinIntensity = SpinIntensity.medium,
    this.onTap,
    this.showTail = false,
  }) : super(key: key);

  @override
  _Coin3DState createState() => _Coin3DState();
}

enum SpinIntensity {
  slow,
  medium,
  fast,
}

class _Coin3DState extends State<Coin3D> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _specialRotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: Duration(seconds: _getSpinDuration(widget.spinIntensity)),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    // Unique rotation styles
    switch (widget.coinType.rotationStyle) {
      case CoinRotationStyle.standard:
        _specialRotationAnimation = AlwaysStoppedAnimation(Offset.zero);
        break;
      case CoinRotationStyle.diagonal:
        _specialRotationAnimation = TweenSequence<Offset>([
          TweenSequenceItem(
            tween: Tween(begin: Offset.zero, end: Offset(0.1, 0.1)),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(begin: Offset(0.1, 0.1), end: Offset(-0.1, -0.1)),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(begin: Offset(-0.1, -0.1), end: Offset.zero),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
          ),
        );
        break;
      case CoinRotationStyle.verticalWave:
        _specialRotationAnimation = TweenSequence<Offset>([
          TweenSequenceItem(
            tween: Tween(begin: Offset.zero, end: Offset(0, 0.2)),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(begin: Offset(0, 0.2), end: Offset(0, -0.2)),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(begin: Offset(0, -0.2), end: Offset.zero),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
          ),
        );
        break;
      case CoinRotationStyle.horizontalWave:
        _specialRotationAnimation = TweenSequence<Offset>([
          TweenSequenceItem(
            tween: Tween(begin: Offset.zero, end: Offset(0.2, 0)),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(begin: Offset(0.2, 0), end: Offset(-0.2, 0)),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(begin: Offset(-0.2, 0), end: Offset.zero),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
          ),
        );
        break;
      case CoinRotationStyle.elliptical:
        _specialRotationAnimation = TweenSequence<Offset>([
          TweenSequenceItem(
            tween: Tween(begin: Offset.zero, end: Offset(0.1, 0.05)),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(begin: Offset(0.1, 0.05), end: Offset(-0.1, -0.05)),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(begin: Offset(-0.1, -0.05), end: Offset.zero),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
          ),
        );
        break;
      case CoinRotationStyle.zigzag:
        _specialRotationAnimation = TweenSequence<Offset>([
          TweenSequenceItem(
            tween: Tween(begin: Offset.zero, end: Offset(0.15, 0.1)),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(begin: Offset(0.15, 0.1), end: Offset(-0.15, -0.1)),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(begin: Offset(-0.15, -0.1), end: Offset.zero),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
          ),
        );
        break;
    }
  }

  int _getSpinDuration(SpinIntensity intensity) {
    switch (intensity) {
      case SpinIntensity.slow:
        return 5;
      case SpinIntensity.medium:
        return 3;
      case SpinIntensity.fast:
        return 1;
    }
  }

  Widget _buildCoinSurface(bool isTail) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _getGradientByDesignStyle(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Center(
        child: isTail ? _buildReverseSide() : _buildObverseSide(),
      ),
    );
  }

  RadialGradient _getGradientByDesignStyle() {
    switch (widget.coinType.designStyle) {
      case CoinDesignStyle.classic:
        return RadialGradient(
          colors: [
            widget.coinType.primaryColor,
            widget.coinType.secondaryColor,
            Colors.black.withOpacity(0.6),
          ],
          radius: 1.5,
          center: const Alignment(-0.4, -0.4),
        );
      case CoinDesignStyle.modern:
        return RadialGradient(
          colors: [
            widget.coinType.primaryColor.withOpacity(0.8),
            widget.coinType.secondaryColor,
            Colors.white.withOpacity(0.3),
          ],
          stops: [0.3, 0.7, 1],
          radius: 1.2,
          center: const Alignment(0, 0),
        );
      case CoinDesignStyle.futuristic:
        return RadialGradient(
          colors: [
            widget.coinType.primaryColor,
            widget.coinType.secondaryColor,
            Colors.white.withOpacity(0.5),
          ],
          stops: [0.2, 0.6, 1],
          radius: 1.8,
          center: const Alignment(0.6, 0.6),
        );
      case CoinDesignStyle.ancient:
        return RadialGradient(
          colors: [
            widget.coinType.primaryColor.withOpacity(0.7),
            widget.coinType.secondaryColor.withOpacity(0.9),
            Colors.brown.withOpacity(0.4),
          ],
          radius: 1.3,
          center: const Alignment(-0.2, -0.2),
        );
      case CoinDesignStyle.minimalist:
        return RadialGradient(
          colors: [
            widget.coinType.primaryColor,
            widget.coinType.primaryColor.withOpacity(0.7),
            widget.coinType.primaryColor.withOpacity(0.4),
          ],
          radius: 1.0,
          center: const Alignment(0, 0),
        );
      case CoinDesignStyle.ornate:
        return RadialGradient(
          colors: [
            widget.coinType.primaryColor,
            widget.coinType.secondaryColor,
            Colors.white.withOpacity(0.4),
          ],
          stops: [0.3, 0.7, 1],
          radius: 1.6,
          center: const Alignment(-0.3, -0.3),
        );
    }
  }

  Widget _buildObverseSide() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.coinType.symbol,
          style: TextStyle(
            fontSize: widget.size * 0.35,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [Colors.white, Colors.yellow],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(Rect.fromLTWH(0, 0, widget.size, widget.size)),
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(3, 3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.coinType.name,
          style: TextStyle(
            fontSize: widget.size * 0.12,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 6,
                offset: const Offset(2, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReverseSide() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'VALUE',
          style: TextStyle(
            fontSize: widget.size * 0.12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(3, 3),
              ),
            ],
          ),
        ),
        Text(
          '1 UNIT',
          style: TextStyle(
            fontSize: widget.size * 0.18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
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
              ..rotateY(widget.isSpinning ? _rotationAnimation.value : 0)
              ..translate(
                _specialRotationAnimation.value.dx * widget.size,
                _specialRotationAnimation.value.dy * widget.size,
              ),
            child: _buildCoinSurface(widget.showTail),
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
  static List<CoinType> availableCoins = [
    const CoinType(
      name: 'Bitcoin',
      primaryColor: Color(0xFFFFA726),
      secondaryColor: Color(0xFFFF9800),
      symbol: '₿',
      countryOfOrigin: 'Crypto Realm',
      rotationStyle: CoinRotationStyle.diagonal,
      designStyle: CoinDesignStyle.futuristic,
    ),
    const CoinType(
      name: 'Ethereum',
      primaryColor: Color(0xFF42A5F5),
      secondaryColor: Color(0xFF2196F3),
      symbol: 'Ξ',
      countryOfOrigin: 'Blockchain Nation',
      rotationStyle: CoinRotationStyle.verticalWave,
      designStyle: CoinDesignStyle.modern,
    ),
    const CoinType(
      name: 'Litecoin',
      primaryColor: Color(0xFFA0A0A0),
      secondaryColor: Color(0xFF707070),
      symbol: 'Ł',
      countryOfOrigin: 'Digital Territory',
      rotationStyle: CoinRotationStyle.horizontalWave,
      designStyle: CoinDesignStyle.minimalist,
    ),
    const CoinType(
      name: 'Cardano',
      primaryColor: Color(0xFF3C3C3D),
      secondaryColor: Color(0xFF212121),
      symbol: '₳',
      countryOfOrigin: 'Smart Contract State',
      rotationStyle: CoinRotationStyle.elliptical,
      designStyle: CoinDesignStyle.minimalist,
    ),
  
    const CoinType(
      name: 'Ripple',
      primaryColor: Color(0xFF4CAF50),
      secondaryColor: Color(0xFF388E3C),
      symbol: '✕',
      countryOfOrigin: 'Global Transfer Empire',
      rotationStyle: CoinRotationStyle.diagonal,
      designStyle: CoinDesignStyle.ancient,
    ),
    const CoinType(
      name: 'Default',
      primaryColor: Color(0xFF9C27B0),
      secondaryColor: Color(0xFF7B1FA2),
      symbol: '◎',
      countryOfOrigin: 'Coin Toss Kingdom',
      rotationStyle: CoinRotationStyle.zigzag,
      designStyle: CoinDesignStyle.ornate,
    ),
  ];

  static CoinType getDefaultCoin() {
    return availableCoins.first;
  }
}