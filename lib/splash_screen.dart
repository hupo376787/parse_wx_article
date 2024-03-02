import 'package:flutter/material.dart';
import './helper/splash_screen_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double opacity = 0;

  @override
  Widget build(BuildContext context) {
    return SplashScreenHelper(
      splashType: SplashType.lottieAnimation,
    );
  }
}
