import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/schedule_model.dart';
import '../../providers/schedule_provider.dart';
import '../../utils/schedule_labels.dart';
import '../../utils/user_friendly_error.dart';
import '../../providers/app_language_provider.dart';
import 'schedule_builder_screen.dart';

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  bool _isUrdu = false;

  String _label(String english, String urdu) =>
      _isUrdu ? urdu : context.tr(english);

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _isUrdu = preferences.getString('selected_language') == 'Urdu';
      });
    } catch (error, stackTrace) {
      debugPrint('Could not load the schedule language: $error\n$stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_label('My schedule', 'میرا شیڈول')),
        actions: [
          IconButton(
            tooltip: _label('Statistics', 'اعداد و شمار'),
            icon: const Icon(Icons.bar_chart),
            onPressed: () => _showStats(context),
          ),
        ],
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, child) => Directionality(
          textDirection: context.watch<AppLanguageProvider>().textDirection,
          child: _buildContent(context, provider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBuilder(context),
        icon: const Icon(Icons.add),
        label: Text(_label('Add schedule', 'شیڈول شامل کریں')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ScheduleProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 56),
              const SizedBox(height: 12),
              Text(
                _label(
                  'Your schedules could not be loaded.',
                  'شیڈول لوڈ نہیں ہو سکے۔',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: provider.loadSchedules,
                icon: const Icon(Icons.refresh),
                label: Text(_label('Try again', 'دوبارہ کوشش کریں')),
              ),
            ],
          ),
        ),
      );
    }
    if (provider.schedules.isEmpty) {
      return _buildEmptyState(context);
    }

    final todaySchedules = provider.schedules
        .where((schedule) => schedule.isRecurringToday)
        .toList();
    final otherDaySchedules = provider.schedules
        .where((schedule) => !schedule.isRecurringToday)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        _buildSectionTitle(
          _label('Today', 'آج'),
          '${todaySchedules.length}',
        ),
        if (todaySchedules.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              _label(
                'No repeating routines are planned for today.',
                'آج کے لیے کوئی دہرایا جانے والا معمول نہیں۔',
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        for (final schedule in todaySchedules)
          _buildScheduleCard(context, provider, schedule),
        if (otherDaySchedules.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionTitle(
            _label('Other days', 'دوسرے دن'),
            '${otherDaySchedules.length}',
          ),
          for (final schedule in otherDaySchedules)
            _buildScheduleCard(context, provider, schedule),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_note,
              size: 76,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.65),
            ),
            const SizedBox(height: 16),
            Text(
              _label('Build a routine that works for you',
                  'اپنے لیے ایک معمول بنائیں'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _label(
                'Add a reminder for Quran, dhikr, or another daily activity.',
                'قرآن، ذکر یا کسی روزانہ سرگرمی کے لیے یاد دہانی شامل کریں۔',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _openBuilder(context),
              icon: const Icon(Icons.add),
              label: Text(
                  _label('Create your first schedule', 'پہلا شیڈول بنائیں')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String count) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          Chip(label: Text(count)),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    ScheduleProvider provider,
    Schedule schedule,
  ) {
    final index = provider.schedules.indexOf(schedule);
    final completed = schedule.isRecurring
        ? schedule.wasCompletedToday
        : schedule.isCompleted;
    final typeColor = _colorForType(schedule.type, context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 8, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: typeColor.withOpacity(0.16),
              foregroundColor: typeColor,
              child: Icon(_iconForType(schedule.type)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          schedule.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            decoration:
                                completed ? TextDecoration.lineThrough : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (schedule.hasAlarm)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 6),
                          child: Icon(
                            Icons.notifications_active_outlined,
                            size: 18,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                    ],
                  ),
                  if (schedule.description.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      schedule.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        TimeOfDay.fromDateTime(schedule.time).format(context),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (schedule.isRecurring)
                        Text(
                          schedule.recurringDays
                              .map((day) => scheduleWeekdayLabel(
                                    day,
                                    isUrdu: _isUrdu,
                                  ))
                              .join(' · '),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      if (schedule.completionCount > 0)
                        Text(
                          _label(
                            'Done ${schedule.completionCount} times',
                            '${schedule.completionCount} مرتبہ مکمل',
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: completed,
                  onChanged: (value) => _toggleSchedule(
                    context,
                    provider,
                    index,
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: _label('Schedule actions', 'شیڈول کے اختیارات'),
                  onSelected: (action) {
                    if (action == 'edit') {
                      _editSchedule(context, schedule, index);
                    } else if (action == 'delete') {
                      _confirmDelete(context, provider, index);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(_label('Edit', 'ترمیم')),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(_label('Delete', 'حذف کریں')),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleSchedule(
    BuildContext context,
    ScheduleProvider provider,
    int index,
  ) async {
    try {
      await provider.toggleComplete(index);
    } catch (error, stackTrace) {
      debugPrint('Could not update schedule completion: $error\n$stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_label(
              'Could not update this schedule. Please try again.',
              'شیڈول اپ ڈیٹ نہیں ہو سکا۔ دوبارہ کوشش کریں۔',
            )),
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ScheduleProvider provider,
    int index,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_label('Delete schedule?', 'شیڈول حذف کریں؟')),
        content: Text(_label(
          'This schedule and its reminders will be removed.',
          'یہ شیڈول اور اس کی یاد دہانیاں حذف ہو جائیں گی۔',
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(_label('Cancel', 'منسوخ')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(_label('Delete', 'حذف کریں')),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !context.mounted) return;
    try {
      await provider.deleteSchedule(index);
    } catch (error, stackTrace) {
      debugPrint('Could not delete schedule: $error\n$stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(UserFriendlyError.deleteSchedule(error)),
          ),
        );
      }
    }
  }

  Future<void> _openBuilder(BuildContext context) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const ScheduleBuilderScreen(),
      ),
    );
  }

  Future<void> _editSchedule(
    BuildContext context,
    Schedule schedule,
    int index,
  ) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ScheduleBuilderScreen(
          schedule: schedule,
          index: index,
        ),
      ),
    );
  }

  Color _colorForType(String type, BuildContext context) {
    switch (type) {
      case 'quran':
        return Colors.green;
      case 'tasbih':
        return Colors.teal;
      case 'dua':
        return Colors.pink;
      case 'hadith':
        return Colors.brown;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'quran':
        return Icons.menu_book;
      case 'tasbih':
        return Icons.circle_outlined;
      case 'dua':
        return Icons.favorite;
      case 'hadith':
        return Icons.book;
      default:
        return Icons.event;
    }
  }

  void _showStats(BuildContext context) {
    final provider = context.read<ScheduleProvider>();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_label('Your progress', 'آپ کی پیش رفت')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statRow(
              _label('Total schedules', 'کل شیڈول'),
              provider.totalSchedules.toString(),
              Icons.event_note,
            ),
            const Divider(),
            _statRow(
              _label('Completed today', 'آج مکمل'),
              provider.completedToday.toString(),
              Icons.check_circle,
            ),
            const Divider(),
            _statRow(
              _label('Total completions', 'کل تکمیل'),
              provider.totalCompletions.toString(),
              Icons.emoji_events,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_label('Close', 'بند کریں')),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
