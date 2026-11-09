import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/schedule_provider.dart';
import '../../models/schedule_model.dart';
import '../../services/notification_service.dart';
import '../../utils/schedule_labels.dart';
import '../../utils/user_friendly_error.dart';
import '../../providers/app_language_provider.dart';

class ScheduleBuilderScreen extends StatefulWidget {
  final Schedule? schedule;
  final int? index;
  const ScheduleBuilderScreen({super.key, this.schedule, this.index});

  @override
  State<ScheduleBuilderScreen> createState() => _ScheduleBuilderScreenState();
}

class _ScheduleBuilderScreenState extends State<ScheduleBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'quran';
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isRecurring = false;
  bool _hasAlarm = true;
  List<int> _selectedDays = [];
  bool _isUrdu = false;
  bool _isSaving = false;

  String _label(String english, String urdu) =>
      _isUrdu ? urdu : context.tr(english);

  Map<String, String> get _activityTypes => {
        'quran': _label('Quran reading', 'قرآن کی تلاوت'),
        'tasbih': _label('Tasbih', 'تسبیح'),
        'dua': _label('Dua', 'دعا'),
        'hadith': _label('Hadith', 'حدیث'),
        'custom': _label('Custom', 'اپنی سرگرمی'),
      };

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    if (widget.schedule != null) {
      _titleController.text = widget.schedule!.title;
      _descriptionController.text = widget.schedule!.description;
      _selectedType = _activityTypes.containsKey(widget.schedule!.type)
          ? widget.schedule!.type
          : 'custom';
      _selectedTime = TimeOfDay.fromDateTime(widget.schedule!.time);
      _isRecurring = widget.schedule!.isRecurring;
      _hasAlarm = widget.schedule!.hasAlarm;
      _selectedDays = List.from(widget.schedule!.recurringDays);
    }
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
        title: Text(widget.schedule == null
            ? _label('Create schedule', 'شیڈول بنائیں')
            : _label('Edit schedule', 'شیڈول میں ترمیم')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Activity Type
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label('Activity type', 'سرگرمی کی قسم'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _activityTypes.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: _label('Title', 'عنوان'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  maxLength: 60,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return _label('Enter a title.', 'عنوان درج کریں۔');
                    }
                    return null;
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText:
                        _label('Description (optional)', 'تفصیل (اختیاری)'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 3,
                  maxLength: 160,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Time Picker
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(_label('Time', 'وقت')),
                subtitle: Text(_selectedTime.format(context)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (time != null) {
                    setState(() {
                      _selectedTime = time;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 16),

            // Recurring
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                        _label('Repeating schedule', 'دہرایا جانے والا شیڈول')),
                    subtitle: Text(
                        _label('Repeat this schedule', 'اس شیڈول کو دہرائیں')),
                    value: _isRecurring,
                    onChanged: (value) {
                      setState(() {
                        _isRecurring = value;
                        if (!value) _selectedDays.clear();
                      });
                    },
                  ),
                  if (_isRecurring) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _label('Repeat on', 'ان دنوں میں دہرائیں'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(
                              DateTime.daysPerWeek,
                              (index) {
                                final day = index + DateTime.monday;
                                final isSelected = _selectedDays.contains(day);
                                return FilterChip(
                                  label: Text(
                                    context.tr(
                                      scheduleWeekdayLabel(
                                        day,
                                        isUrdu: _isUrdu,
                                      ),
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedDays.add(day);
                                      } else {
                                        _selectedDays.remove(day);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Alarm
            Card(
              child: SwitchListTile(
                title: Text(_label('Reminder', 'یاد دہانی')),
                subtitle: Text(_label(
                  'Notify me at the scheduled time',
                  'مقررہ وقت پر اطلاع دیں',
                )),
                value: _hasAlarm,
                secondary: const Icon(Icons.alarm),
                onChanged: (value) {
                  setState(() => _hasAlarm = value);
                },
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveSchedule,
              icon: const Icon(Icons.save),
              label: Text(_isSaving
                  ? _label('Saving…', 'محفوظ ہو رہا ہے…')
                  : widget.schedule == null
                      ? _label('Save schedule', 'شیڈول محفوظ کریں')
                      : _label('Update schedule', 'شیڈول اپ ڈیٹ کریں')),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      if (_isRecurring && _selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_label(
            'Choose at least one day for a repeating schedule.',
            'دہرائے جانے والے شیڈول کے لیے کم از کم ایک دن منتخب کریں۔',
          ))),
        );
        return;
      }

      setState(() => _isSaving = true);
      final now = DateTime.now();
      final scheduleTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final schedule = Schedule(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        time: scheduleTime,
        type: _selectedType,
        isCompleted: widget.schedule?.isCompleted ?? false,
        isRecurring: _isRecurring,
        recurringDays: _selectedDays,
        hasAlarm: _hasAlarm,
        completionCount: widget.schedule?.completionCount ?? 0,
        completionDate: widget.schedule?.completionDate,
        lastCompletionDate: widget.schedule?.lastCompletionDate,
      );

      final provider = Provider.of<ScheduleProvider>(context, listen: false);
      var scheduleSaved = false;
      try {
        if (_hasAlarm && !await NotificationService().requestPermissions()) {
          throw StateError(
              'Notification or exact-alarm permission was denied.');
        }

        final existingKey = widget.schedule?.key;
        if (widget.schedule == null) {
          await provider.addSchedule(schedule);
        } else {
          final index = widget.index;
          if (index == null) {
            throw StateError('The schedule could not be identified.');
          }
          await provider.updateSchedule(index, schedule);
        }
        scheduleSaved = true;

        final scheduleKey = existingKey ?? schedule.key;
        if (scheduleKey is! int) {
          throw StateError('Could not determine a stable schedule alarm ID.');
        }

        if (_hasAlarm) {
          await NotificationService().scheduleScheduleAlarm(
            scheduleKey: scheduleKey,
            title: schedule.title,
            body: schedule.description,
            scheduledTime: scheduleTime,
            recurring: _isRecurring,
            recurringDays: _selectedDays,
          );
        } else {
          await NotificationService().cancelScheduleAlarms(scheduleKey);
        }
      } catch (error) {
        debugPrint('Could not save schedule or set its reminder: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(UserFriendlyError.schedule(
                error,
                alreadySaved: scheduleSaved,
              )),
            ),
          );
          setState(() => _isSaving = false);
        }
        return;
      }

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.schedule == null
              ? _label('Schedule created.', 'شیڈول بن گیا۔')
              : _label('Schedule updated.', 'شیڈول اپ ڈیٹ ہو گیا۔')),
        ));
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
