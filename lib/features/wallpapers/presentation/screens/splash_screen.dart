import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;

  late Animation<Offset> _logoOffsetAnimation;
  late Animation<double> _logoOpacityAnimation;

  final String _appName = "Walify";
  final List<Animation<double>> _letterOpacityAnimations = [];
  final List<Animation<Offset>> _letterOffsetAnimations = [];

  @override
  void initState() {
    super.initState();

    // 1. Logo Controller: Drop Down + Bounce
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoOffsetAnimation =
        Tween<Offset>(begin: const Offset(0, -3.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _logoController, curve: Curves.bounceOut),
        );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // 2. Text Controller: Staggered Fade + Slide
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    for (int i = 0; i < _appName.length; i++) {
      double start = 0.1 * i;
      double end = (0.1 * i) + 0.4;

      _letterOpacityAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _textController,
            curve: Interval(
              start.clamp(0.0, 1.0),
              end.clamp(0.0, 1.0),
              curve: Curves.easeIn,
            ),
          ),
        ),
      );

      _letterOffsetAnimations.add(
        Tween<Offset>(begin: const Offset(-0.5, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _textController,
            curve: Interval(
              start.clamp(0.0, 1.0),
              end.clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      );
    }

    // 3. Pulse Glow Controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Sequence start
    _logoController.forward().wellCheckedThen(() {
      _textController.forward().wellCheckedThen(() {
        Timer(const Duration(milliseconds: 1000), _navigateToHome);
      });
    });
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            AnimatedBuilder(
              animation: Listenable.merge([_logoController, _pulseController]),
              builder: (context, child) {
                return SlideTransition(
                  position: _logoOffsetAnimation,
                  child: FadeTransition(
                    opacity: _logoOpacityAnimation,
                    child: _buildGlassLogo(),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // Animated Text
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_appName.length, (index) {
                return AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _letterOpacityAnimations[index].value,
                      child: Transform.translate(
                        offset: _letterOffsetAnimations[index].value * 20,
                        child: Text(
                          _appName[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2,
                            fontFamily:
                                'Outfit', // Fallback to sans-serif if not found
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassLogo() {
    double pulseValue = _pulseController.value;

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.3 * pulseValue),
            blurRadius: 20 + (10 * pulseValue),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.2 * pulseValue),
            blurRadius: 30 + (10 * pulseValue),
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Layers for 3D depth
          _buildLogoLayer(offset: const Offset(4, 4), opacity: 0.1),
          _buildLogoLayer(offset: const Offset(2, 2), opacity: 0.2),

          // Main Glass Layer
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 0.5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
                child: CustomPaint(
                  painter: WLogoPainter(),
                  size: const Size(120, 120),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoLayer({required Offset offset, required double opacity}) {
    return Transform.translate(
      offset: offset,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: CustomPaint(
            painter: WLogoPainter(color: Colors.white),
            size: const Size(100, 100),
          ),
        ),
      ),
    );
  }
}

class WLogoPainter extends CustomPainter {
  final Color? color;
  WLogoPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (color != null) {
      paint.color = color!;
      paint.style = PaintingStyle.fill;
    } else {
      paint.shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.purpleAccent, Colors.blueAccent, Colors.pinkAccent],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    }

    final path = Path()
      ..moveTo(w * 0.2, h * 0.3)
      ..lineTo(w * 0.35, h * 0.7)
      ..lineTo(w * 0.5, h * 0.45)
      ..lineTo(w * 0.65, h * 0.7)
      ..lineTo(w * 0.8, h * 0.3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension on Future<void> {
  void wellCheckedThen(VoidCallback callback) {
    then((_) => callback());
  }
}
