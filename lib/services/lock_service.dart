import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LockService {
  Timer? _timer;

  void startPolling(Function(bool) onLockStatusChanged) {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final isLocked = await checkLock();
      print("Lock status checked: ${isLocked ? "LOCKED" : "UNLOCKED"}");
      onLockStatusChanged(isLocked);
    });
  }

  void stopPolling() {
    _timer?.cancel();
  }

  Future<bool> checkLock() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
    final String apiUri = dotenv.env['POS_API_URL'] ?? "";
    final url = Uri.parse('$apiUri/api/v1/check-lock');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Pos-Secret-key': apiSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['is_locked'] == true;
    }
    return false;
  }

  Future<void> lockSystem() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
    final String apiUri = dotenv.env['POS_API_URL'] ?? "";
    final url = Uri.parse('$apiUri/api/v1/lock-system');

    await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Pos-Secret-key': apiSecret,
      },
    );
  }
}
