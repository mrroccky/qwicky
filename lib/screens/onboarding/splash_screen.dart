import 'package:flutter/material.dart';
import 'dart:async';

import 'package:qwicky/screens/onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _qSizeAnimation;
  late Animation<Offset> _qPositionAnimation;
  late Animation<double> _wickyOpacityAnimation;
  late Animation<double> _logoOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Animation for "Q" size (big to small)
    _qSizeAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    // Animation for "Q" position (center to very slightly left for tight spacing)
    _qPositionAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(
        -0.02,
        0.0,
      ), // Minimal left movement for "Qwicky" cohesion
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeInOut),
      ),
    );

    // Animation for "wicky" opacity (hidden to visible)
    _wickyOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 0.8, curve: Curves.easeIn),
      ),
    );

    // Animation for logo opacity (hidden to visible)
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animation and navigate after completion
    _animationController.forward().then((_) {
      Timer(const Duration(milliseconds: 500), () {
        navigateToOnboarding();
      });
    });
  }

  void navigateToOnboarding() {
    // Navigate to onboarding screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Logo (circle) above text
                Positioned(
                  top: screenHeight * 0.18,
                  child: FadeTransition(
                    opacity: _logoOpacityAnimation,
                    child: Container(
                      width: 160, // Increased size to show border
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white, // White border color
                          width: 0.5, // Border thickness
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo.png',
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Text with animations
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Keeps Row tight
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated "Q"
                      Transform.translate(
                        offset:
                            _qPositionAnimation.value *
                            MediaQuery.of(context).size.width,
                        child: Transform.scale(
                          scale:
                              1.0 +
                              _qSizeAnimation.value *
                                  2.0, // Big Q becoming smaller
                          child:Text(
                            "Q",
                            style: TextStyle(
                              fontSize: screenHeight*0.07,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Minimal spacing
                      const SizedBox(width: 4),
                      // appears after Q animation
                      FadeTransition(
                        opacity: _wickyOpacityAnimation,
                        child: Text(
                          "wicky",
                          style: TextStyle(
                            fontSize: screenHeight*0.07,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
