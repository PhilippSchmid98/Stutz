import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class TransactionMonth {
  const TransactionMonth._();

  static const timezoneName = 'Europe/Zurich';
  static bool _isInitialized = false;

  static void initialize() {
    if (_isInitialized) return;

    tzdata.initializeTimeZones();
    _isInitialized = true;
  }

  static DateTime current() => fromDateTime(DateTime.now());

  static DateTime fromDateTime(DateTime dateTime) {
    initialize();
    final zurichDate = tz.TZDateTime.from(
      dateTime,
      tz.getLocation(timezoneName),
    );
    return DateTime(zurichDate.year, zurichDate.month);
  }

  static String keyFromDateTime(DateTime dateTime) =>
      key(fromDateTime(dateTime));

  static String key(DateTime month) {
    final monthNumber = month.month.toString().padLeft(2, '0');
    return '${month.year}-$monthNumber';
  }

  static DateTime fromKey(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(value);
    if (match == null) {
      throw FormatException('Invalid transaction month key: $value');
    }

    final month = DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
    );
    if (month.month != int.parse(match.group(2)!)) {
      throw FormatException('Invalid transaction month key: $value');
    }
    return month;
  }
}
