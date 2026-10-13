String toIsoDateTime(DateTime value) => value.toUtc().toIso8601String();

DateTime? parseDateTime(Object? value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value.toString())?.toLocal();
}

String formatShortDate(DateTime date) {
  final local = date.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/${local.year}';
}

bool isSameCalendarDay(DateTime a, DateTime b) {
  final localA = a.toLocal();
  final localB = b.toLocal();
  return localA.year == localB.year &&
      localA.month == localB.month &&
      localA.day == localB.day;
}

DateTime dateOnly(DateTime value) {
  final local = value.toLocal();
  return DateTime(local.year, local.month, local.day);
}
