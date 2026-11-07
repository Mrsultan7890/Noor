import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../navigation/main_navigation_screen.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_noor_logo.dart';
import '../widgets/arabic_text.dart';
import 'onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.68, curve: Curves.easeIn),
    );
    _controller.forward();

    Timer(const Duration(seconds: 3), _continueFromSplash);
  }

  Future<void> _continueFromSplash() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

    if (!mounted) return;
    if (onboardingComplete) {
      try {
        await Provider.of<UserProvider>(context, listen: false)
            .restoreSession()
            .timeout(const Duration(seconds: 5));
      } catch (error, stackTrace) {
        debugPrint('Could not restore the user session at startup: $error\n$stackTrace');
      }
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
    final palette =
        AppTheme.palettes[Provider.of<ThemeProvider>(context).selectedTheme]!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 180,
                height: 180,
                child: AnimatedNoorLogo(
                  progress: _controller,
                  palette: palette,
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
