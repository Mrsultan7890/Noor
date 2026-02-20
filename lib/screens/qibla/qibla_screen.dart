import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'dart:math';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Qibla Direction - قبلہ')),
      body: FutureBuilder(
        future: FlutterQiblah.androidDeviceSensorSupport(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == false) {
            return const Center(child: Text('Device not supported'));
          }
          return StreamBuilder(
            stream: FlutterQiblah.qiblahStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final qiblahDirection = snapshot.data;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.rotate(
                      angle: (qiblahDirection!.qiblah * (pi / 180) * -1),
                      child: Icon(Icons.navigation, size: 200, color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(height: 32),
                    Text('${qiblahDirection.direction.toInt()}°', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
