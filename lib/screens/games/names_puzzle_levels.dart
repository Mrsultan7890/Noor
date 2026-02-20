import 'package:flutter/material.dart';

class NamesPuzzleLevels extends StatelessWidget {
  const NamesPuzzleLevels({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('99 Names Puzzle'), backgroundColor: Colors.amber),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.amber.shade50, Colors.orange.shade50])),
        child: const Center(child: Text('Coming Soon!\n99 Levels', style: TextStyle(fontSize: 24), textAlign: TextAlign.center)),
      ),
    );
  }
}
