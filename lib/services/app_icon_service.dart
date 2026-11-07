import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class AppIconService {
  static const _channel = MethodChannel('com.noor.app/launcher_icon');

  static Future<void> setForTheme(NoorTheme theme) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    await _channel.invokeMethod<void>(
      'setThemeIcon',
      {'theme': theme.name},
    );
  }
}
