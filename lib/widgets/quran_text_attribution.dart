import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class QuranTextAttribution extends StatelessWidget {
  const QuranTextAttribution({super.key});

  static final _sourceUri = Uri.parse('https://tanzil.net/');

  Future<void> _openSource() async {
    final opened = await launchUrl(
      _sourceUri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      debugPrint('Could not open the Tanzil Quran text source.');
    }
  }

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: _openSource,
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          textStyle: Theme.of(context).textTheme.labelSmall,
        ),
        child: const Text(
          'Quran text: Tanzil Project · CC BY 3.0',
          textAlign: TextAlign.center,
        ),
      );
}
