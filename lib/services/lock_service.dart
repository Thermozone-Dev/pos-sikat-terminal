import 'package:shared_preferences/shared_preferences.dart';

class LockService {
  static const String _lockKey = "lock_until";

  static Future<void> lockUntilNextDay() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    await prefs.setString(_lockKey, tomorrow.toIso8601String());
  }

  static Future<bool> isLocked() async {
    final prefs = await SharedPreferences.getInstance();
    final lockDateStr = prefs.getString(_lockKey);

    if (lockDateStr == null) return false;

    final lockDate = DateTime.parse(lockDateStr);
    final now = DateTime.now();

    return now.isBefore(lockDate);
  }
}
