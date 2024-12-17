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

enum SpinIntensity {
  slow,
  medium,
  fast,
}

class CoinType {
  final String name;
  final CoinMaterial material;
  final Color primaryColor;
  final Color secondaryColor;
  final Color tailPrimaryColor;
  final Color tailSecondaryColor;
  final String symbol;
  final String countryOfOrigin;
  final List<Color> reflectionGradient;
  final CoinRotationStyle rotationStyle;
  final CoinDesignStyle designStyle;

   CoinType({
    required this.name,
    this.material = CoinMaterial.silver,
    required this.primaryColor,
    required this.secondaryColor,
    Color? tailPrimaryColor,
    Color? tailSecondaryColor,
    required this.symbol,
    this.countryOfOrigin = 'Blockchain Realm',
    this.reflectionGradient = const [
      Color(0xFFE0E0E0),
      Color(0xFFF5F5F5),
      Color(0xFFBDBDBD),
    ],
    this.rotationStyle = CoinRotationStyle.standard,
    this.designStyle = CoinDesignStyle.classic,
  }) : tailPrimaryColor = tailPrimaryColor ?? primaryColor.withOpacity(0.7),
       tailSecondaryColor = tailSecondaryColor ?? secondaryColor.withOpacity(0.7);
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

    _specialRotationAnimation = _createSpecialRotationAnimation();
  }

  Animation<Offset> _createSpecialRotationAnimation() {
    switch (widget.coinType.rotationStyle) {
      case CoinRotationStyle.standard:
        return AlwaysStoppedAnimation(Offset.zero);
      case CoinRotationStyle.diagonal:
        return TweenSequence<Offset>([
          TweenSequenceItem(tween: Tween(begin: Offset.zero, end: Offset(0.1, 0.1)), weight: 1),
          TweenSequenceItem(tween: Tween(begin: Offset(0.1, 0.1), end: Offset(-0.1, -0.1)), weight: 1),
          TweenSequenceItem(tween: Tween(begin: Offset(-0.1, -0.1), end: Offset.zero), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
      case CoinRotationStyle.verticalWave:
        return TweenSequence<Offset>([
          TweenSequenceItem(tween: Tween(begin: Offset.zero, end: Offset(0, 0.2)), weight: 1),
          TweenSequenceItem(tween: Tween(begin: Offset(0, 0.2), end: Offset(0, -0.2)), weight: 1),
          TweenSequenceItem(tween: Tween(begin: Offset(0, -0.2), end: Offset.zero), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
      case CoinRotationStyle.horizontalWave:
        return TweenSequence<Offset>([
          TweenSequenceItem(tween: Tween(begin: Offset.zero, end: Offset(0.2, 0)), weight: 1),
          TweenSequenceItem(tween: Tween(begin: Offset(0.2, 0), end: Offset(-0.2, 0)), weight: 1),
          TweenSequenceItem(tween: Tween(begin: Offset(-0.2, 0), end: Offset.zero), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
      case CoinRotationStyle.elliptical:
        return TweenSequence<Offset>([
          TweenSequenceItem(tween: Tween(begin: Offset.zero, end: Offset(0.1, 0.05)), weight: 1),
          TweenSequenceItem(tween: Tween(begin: Offset(0.1, 0.05), end: Offset(-0.1, -0.05)), weight: 1),
          TweenSequenceItem(tween: Tween(begin: Offset(-0.1, -0.05), end: Offset.zero), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
      case CoinRotationStyle.zigzag:
        return TweenSequence<Offset>([
          TweenSequenceItem(tween: Tween(begin: Offset.zero, end: Offset(0.15, 0.1)), weight: 1),
          TweenSequenceItem(tween: Tween(begin: Offset(0.15, 0.1), end: Offset(-0.15, -0.1)), weight: 1),
          TweenSequenceItem(tween: Tween(begin: Offset(-0.15, -0.1), end: Offset.zero), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
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

  RadialGradient _createCoinGradient(bool isTail) {
    Color primaryColor = isTail ? widget.coinType.tailPrimaryColor : widget.coinType.primaryColor;
    Color secondaryColor = isTail ? widget.coinType.tailSecondaryColor : widget.coinType.secondaryColor;

    return RadialGradient(
      colors: [
        primaryColor,
        secondaryColor,
        isTail ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.6),
      ],
      radius: 1.5,
      center: const Alignment(-0.4, -0.4),
    );
  }

  Widget _buildCoinSurface(bool isTail) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _createCoinGradient(isTail),
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

class CoinTypes {
  static List<CoinType> availableCoins = [
    CoinType(
      name: 'Bitcoin',
      primaryColor: Color(0xFFFFA726),
      secondaryColor: Color(0xFFFF9800),
      tailPrimaryColor: Color(0xFF424242),
      tailSecondaryColor: Color(0xFF212121),
      symbol: '₿',
      countryOfOrigin: 'Crypto Realm',
      rotationStyle: CoinRotationStyle.diagonal,
    ),
    CoinType(
      name: 'Ethereum',
      primaryColor: Color(0xFF42A5F5),
      secondaryColor: Color(0xFF2196F3),
      tailPrimaryColor: Color(0xFFE0E0E0),
      tailSecondaryColor: Color(0xFFF5F5F5),
      symbol: 'Ξ',
      countryOfOrigin: 'Blockchain Nation',
      rotationStyle: CoinRotationStyle.verticalWave,
    ),
    CoinType(
      name: 'Litecoin',
      primaryColor: Color(0xFFA0A0A0),
      secondaryColor: Color(0xFF707070),
      tailPrimaryColor: Color(0xFFFFFFFF),
      tailSecondaryColor: Color(0xFFF0F0F0),
      symbol: 'Ł',
      countryOfOrigin: 'Digital Territory',
      rotationStyle: CoinRotationStyle.horizontalWave,
    ),
    CoinType(
      name: 'Cardano',
      primaryColor: Color(0xFF3C3C3D),
      secondaryColor: Color(0xFF212121),
      tailPrimaryColor: Color(0xFFF5F5F5),
      tailSecondaryColor: Color(0xFFE0E0E0),
      symbol: '₳',
      countryOfOrigin: 'Smart Contract State',
      rotationStyle: CoinRotationStyle.elliptical,
    ),
    CoinType(
      name: 'Ripple',
      primaryColor: Color(0xFF4CAF50),
      secondaryColor: Color(0xFF388E3C),
      tailPrimaryColor: Color(0xFFFFFFFF),
      tailSecondaryColor: Color(0xFFF0F0F0),
      symbol: '✕',
      countryOfOrigin: 'Global Transfer Empire',
      rotationStyle: CoinRotationStyle.diagonal,
    ),
    CoinType(
      name: 'Default',
      primaryColor: Color(0xFF9C27B0),
      secondaryColor: Color(0xFF7B1FA2),
      tailPrimaryColor: Color(0xFFE0E0E0),
      tailSecondaryColor: Color(0xFFF5F5F5),
      symbol: '◎',
      countryOfOrigin: 'Coin Toss Kingdom',
      rotationStyle: CoinRotationStyle.zigzag,
    ),
  ];

  static CoinType getDefaultCoin() {
    return availableCoins.first;
  }
}