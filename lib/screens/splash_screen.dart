import 'package:flutter/material.dart';
import 'dart:async';
import '../navigation/main_navigation_screen.dart';

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
    
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigationScreen()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          ),
        ),
        child: FadeTransition(
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
                  child: const Center(
                    child: Icon(Icons.mosque, size: 80, color: Color(0xFF2E7D32)),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'نور',
                  style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
                ),
                const SizedBox(height: 10),
                const Text(
                  'NOOR',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300, color: Colors.white70, letterSpacing: 8),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Islamic Companion',
                  style: TextStyle(fontSize: 16, color: Colors.white60, letterSpacing: 2),
                ),
                const SizedBox(height: 60),
                const CircularProgressIndicator(color: Colors.white70, strokeWidth: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
