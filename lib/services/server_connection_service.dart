import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerConnectionService {
  Timer? _timer;
  bool _isConnected = true;

  void startPolling(Function(bool) onConnectionChanged) {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final connected = await checkConnection();

      if (connected != _isConnected) {
        _isConnected = connected;
        print(
          "Server connection changed: ${connected ? "CONNECTED" : "DISCONNECTED"}",
        );
        onConnectionChanged(connected);
      }
    });
  }

  /// Stops polling
  void stopPolling() {
    _timer?.cancel();
  }

  /// Checks if the server is reachable.
  Future<bool> checkConnection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
      final String apiUri = dotenv.env['POS_API_URL'] ?? "";
      final url = Uri.parse('$apiUri/api/v1/ping');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Pos-Secret-key': apiSecret,
        },
      );

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print("Server connection check failed: $e");
    }

    return false;
  }
}
