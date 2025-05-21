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
  final String apiUri = dotenv.env['POS_API_URL'] ?? "";
  final url = Uri.parse('$apiUri/api/v1/shift/start');

  if (token == null || token.isEmpty) {
    return ShiftServiceResult(success: false, error: 'No token found');
  }

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Pos-Secret-Key': apiSecret,
      },
    );

    if (response.statusCode == 201) {
      final shiftId = response.body.replaceAll('"', '');
      await prefs.setString('shift_id', shiftId);
      print('Shift started with ID: $shiftId');
      return ShiftServiceResult(success: true);
    } else {
      print('Failed to start shift: ${response.body}');
      return ShiftServiceResult(success: false, error: response.body);
    }
  } catch (e) {
    print('Error: $e');
    return ShiftServiceResult(success: false, error: e.toString());
  }
}

Future<void> endShift() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final shiftId = prefs.getString('shift_id');
  final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";

  if (shiftId == null) {
    print('No shift ID found in preferences.');
    return;
  }
  final url = Uri.parse('apiUri/api/v1/shift/end/$shiftId');

  try {
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Pos-Secret-Key': apiSecret,
      },
    );

    if (response.statusCode == 200) {
      print('Shift ended: ${response.body}');
      await prefs.remove('shift_id');
    } else {
      print('Failed to end shift: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
