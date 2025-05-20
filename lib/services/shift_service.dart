import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ShiftServiceResult {
  final bool success;
  final String? error;

  ShiftServiceResult({required this.success, this.error});
}

Future<ShiftServiceResult> initializeShift() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";

  try {
    final response = await http.post(
      Uri.parse('http://bir-pos.test/api/v1/shift/start'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Pos-Secret-key': apiSecret,
      },
    );

    if (response.statusCode == 201) {
      return ShiftServiceResult(success: true);
    } else {
      return ShiftServiceResult(
        success: false,
        error: 'Failed to start shift. Code: ${response.statusCode}',
      );
    }
  } catch (e) {
    return ShiftServiceResult(success: false, error: 'Error: $e');
  }
}
