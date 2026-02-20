import 'package:flutter/material.dart';

class WuduGameLevels extends StatelessWidget {
  const WuduGameLevels({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wudu Steps Game'), backgroundColor: Colors.blue),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.cyan.shade50])),
        child: const Center(child: Text('Coming Soon!\n20 Levels', style: TextStyle(fontSize: 24), textAlign: TextAlign.center)),
      ),
    );
  }
}
