import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/splash_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/quran_provider.dart';
import 'providers/tasbih_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/user_provider.dart';
import 'services/notification_bootstrap.dart';
import 'services/prayer_notification_service.dart';
import 'services/app_icon_service.dart';
import 'models/schedule_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = await ThemeProvider.load();
  
  await Hive.initFlutter();
  Hive.registerAdapter(ScheduleAdapter());
  
  runApp(NoorApp(themeProvider: themeProvider));
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(
      AppIconService.setForTheme(themeProvider.selectedTheme).catchError(
        (Object error, StackTrace stackTrace) {
          debugPrint('Could not apply the selected launcher icon: $error\n$stackTrace');
        },
      ),
    );
    unawaited(
      NotificationBootstrap.initialize().catchError(
        (Object error, StackTrace stackTrace) {
          debugPrint('Could not initialize notifications: $error\n$stackTrace');
        },
      ),
    );
  });
}

class NoorApp extends StatefulWidget {
  const NoorApp({super.key, required this.themeProvider});

  final ThemeProvider themeProvider;

  @override
  State<NoorApp> createState() => _NoorAppState();
}

class _NoorAppState extends State<NoorApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshPrayerNotifications());
    }
  }

  Future<void> _refreshPrayerNotifications() async {
    try {
      await PrayerNotificationService.refreshFromSavedLocation();
    } catch (error, stackTrace) {
      debugPrint('Could not refresh prayer notifications: $error\n$stackTrace');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.themeProvider),
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => TasbihProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Noor - نور',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            builder: (context, child) => DecoratedBox(
              decoration: BoxDecoration(
                gradient: themeProvider.backgroundGradient,
              ),
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}
