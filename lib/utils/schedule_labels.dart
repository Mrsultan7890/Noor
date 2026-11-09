String scheduleLabel(bool isUrdu, String english, String urdu) =>
    isUrdu ? urdu : english;

String scheduleWeekdayLabel(int weekday, {required bool isUrdu}) {
  const english = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const urdu = ['پیر', 'منگل', 'بدھ', 'جمعرات', 'جمعہ', 'ہفتہ', 'اتوار'];
  if (weekday < DateTime.monday || weekday > DateTime.sunday) {
    throw ArgumentError.value(weekday, 'weekday');
  }
  return (isUrdu ? urdu : english)[weekday - 1];
}
