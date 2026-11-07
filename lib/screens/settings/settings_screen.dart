import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';
import '../../services/daily_reminder_service.dart';
import '../../services/app_icon_service.dart';
import '../../services/notification_service.dart';
import '../../services/prayer_notification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/arabic_text.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _reminderEnabled = false;
  bool _prayerNotificationsEnabled = true;
  bool _isLoading = true;
  bool _isSavingReminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _reminderEnabled = prefs.getBool('daily_reminder_enabled') ?? false;
        _prayerNotificationsEnabled =
            prefs.getBool('prayer_notifications_enabled') ?? true;
        final hour = prefs.getInt('daily_reminder_hour') ?? 9;
        final minute = prefs.getInt('daily_reminder_minute') ?? 0;
        _reminderTime = TimeOfDay(hour: hour, minute: minute);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Could not load settings: $error');
    }
  }

  Future<void> _setReminderEnabled(bool enabled) async {
    setState(() => _isSavingReminder = true);
    try {
      if (enabled) {
        await DailyReminderService.enableReminder(
          _reminderTime.hour,
          _reminderTime.minute,
        );
      } else {
        await DailyReminderService.disableReminder();
      }
      if (!mounted) return;
      setState(() {
        _reminderEnabled = enabled;
        _isSavingReminder = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSavingReminder = false);
      _showError('Could not update the daily reminder: $error');
    }
  }

  Future<void> _selectReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (time == null || !mounted) return;
    try {
      if (_reminderEnabled) {
        await DailyReminderService.enableReminder(time.hour, time.minute);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('daily_reminder_hour', time.hour);
        await prefs.setInt('daily_reminder_minute', time.minute);
      }
      if (!mounted) return;
      setState(() => _reminderTime = time);
    } catch (error) {
      if (mounted) _showError('Could not save the reminder time: $error');
    }
  }

  Future<void> _setPrayerNotificationsEnabled(bool enabled) async {
    try {
      if (enabled && !await NotificationService().requestPermissions()) {
        throw StateError('Notification or exact-alarm permission was denied.');
      }
      final prefs = await SharedPreferences.getInstance();
      if (!enabled) {
        await PrayerNotificationService.cancelPrayerNotifications();
      }
      await prefs.setBool('prayer_notifications_enabled', enabled);
      if (enabled) {
        await PrayerNotificationService.refreshFromSavedLocation();
      }
      if (!mounted) return;
      setState(() => _prayerNotificationsEnabled = enabled);
    } catch (error) {
      if (mounted) {
        _showError('Could not update prayer notifications: $error');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const ArabicLabel('Settings - ترتیبات')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _sectionTitle(context, 'Appearance', Icons.palette_outlined),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose a color theme',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        for (final theme in NoorTheme.values)
                          _ThemeChoice(
                            theme: theme,
                            onSelected: () async {
                              try {
                                await context.read<ThemeProvider>().setTheme(theme);
                                await AppIconService.setForTheme(theme);
                              } catch (error) {
                                if (context.mounted) {
                                  _showError('Could not save theme: $error');
                                }
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) => SwitchListTile(
                      title: const Text('Dark appearance'),
                      subtitle: const Text(
                        'Switch between the palette gradient and its light variant',
                      ),
                      secondary: const Icon(Icons.dark_mode_outlined),
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (_) async {
                        try {
                          await themeProvider.toggleTheme();
                        } catch (error) {
                          if (context.mounted) {
                            _showError('Could not save appearance: $error');
                          }
                        }
                      },
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.text_fields),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Arabic text size',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Text('${(themeProvider.arabicFontScale * 100).round()}%'),
                            ],
                          ),
                          Slider(
                            min: 0.8,
                            max: 1.6,
                            divisions: 8,
                            value: themeProvider.arabicFontScale,
                            label:
                                '${(themeProvider.arabicFontScale * 100).round()}%',
                            onChanged: (value) async {
                              try {
                                await themeProvider.setArabicFontScale(value);
                              } catch (error) {
                                if (context.mounted) {
                                  _showError('Could not save Arabic text size: $error');
                                }
                              }
                            },
                          ),
                          const ArabicText(
                            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _sectionTitle(context, 'Notifications', Icons.notifications_outlined),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Daily Reminder'),
                        subtitle:
                            const Text('Get daily hadith/dua notifications'),
                        value: _reminderEnabled,
                        secondary: const Icon(Icons.notifications_active),
                        onChanged: _isSavingReminder ? null : _setReminderEnabled,
                      ),
                      if (_isSavingReminder)
                        const LinearProgressIndicator(),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('Reminder Time'),
                        subtitle: Text(_reminderTime.format(context)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _selectReminderTime,
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Prayer time reminders'),
                        subtitle: const Text(
                          'Schedule after loading Prayer Times',
                        ),
                        secondary: const Icon(Icons.access_time),
                        value: _prayerNotificationsEnabled,
                        onChanged: _setPrayerNotificationsEnabled,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({required this.theme, required this.onSelected});

  final NoorTheme theme;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = AppTheme.palettes[theme]!;
    final selected = context.watch<ThemeProvider>().selectedTheme == theme;
    return Card(
      margin: const EdgeInsets.only(top: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onSelected,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: palette.gradientColors),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: palette.accent, width: 2),
                ),
                child: Icon(Icons.auto_awesome, color: palette.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      palette.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(palette.description),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
