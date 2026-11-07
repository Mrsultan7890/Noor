import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../navigation/main_navigation_screen.dart';
import 'onboarding/onboarding_screen.dart';
import '../providers/user_provider.dart';
import '../widgets/arabic_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
    
    Timer(const Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

      if (!mounted) return;
      if (onboardingComplete) {
        await Provider.of<UserProvider>(context, listen: false).restoreSession();
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => onboardingComplete
              ? const MainNavigationScreen()
              : const OnboardingScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onSurface;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 5)],
                  ),
                  child: Center(
                      child: Icon(
                        Icons.mosque,
                        size: 80,
                        color: theme.brightness == Brightness.dark
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                      ),
                    ),
                ),
                const SizedBox(height: 30),
                ArabicLabel(
                  'نور',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: foreground,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'NOOR',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: foreground.withOpacity(0.75),
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Islamic Companion',
                  style: TextStyle(
                    fontSize: 16,
                    color: foreground.withOpacity(0.6),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 60),
                CircularProgressIndicator(
                  color: foreground.withOpacity(0.75),
                  strokeWidth: 2,
                ),
              ],
            ),
          ),
        ),
    );
  }
}
