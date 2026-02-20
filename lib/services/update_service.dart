import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  static const String versionUrl = 'https://raw.githubusercontent.com/Mrsultan7890/Noor/main/version.json';

  static Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await http.get(Uri.parse(versionUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['version'];

        if (_isNewerVersion(currentVersion, latestVersion)) {
          return {
            'hasUpdate': true,
            'latestVersion': latestVersion,
            'currentVersion': currentVersion,
            'downloadUrl': data['downloadUrl'],
            'changelog': data['changelog'],
          };
        }
      }
    } catch (e) {
      // Silently fail
    }
    return null;
  }

  static bool _isNewerVersion(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }
}
