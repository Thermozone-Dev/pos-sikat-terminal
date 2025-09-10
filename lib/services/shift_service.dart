import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // make sure this points to your AuthService

class ShiftServiceResult {
  final bool success;
  final String? error;

  ShiftServiceResult({required this.success, this.error});
}

class ContinueShiftResult {
  final bool success;
  final String? shiftId;
  final String? error;

  ContinueShiftResult({required this.success, this.shiftId, this.error});
}

Future<ShiftServiceResult> initializeShift(
  String openingBalance, {
  required dynamic context,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null || token.isEmpty) {
    return ShiftServiceResult(success: false, error: 'No token found');
  }

  // Get current user ID
  final user = await AuthService.getUser(context);
  final userId = user.id.toString();

  final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
  final String apiUri = dotenv.env['POS_API_URL'] ?? "";
  final url = Uri.parse('$apiUri/api/v1/shift/start');

  final Map<String, dynamic> data = {
    'opening_balance': double.parse(openingBalance),
  };

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Pos-Secret-Key': apiSecret,
      },
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      final shiftId = response.body.replaceAll('"', '');
      await prefs.setString('shift_id_$userId', shiftId); // per-user shift
      print('Shift started with ID: $shiftId for user $userId');
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

Future<void> endShift({
  required dynamic context,
  required String endingBalance,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null || token.isEmpty) {
    print('No token found');
    return;
  }

  // Get current user ID
  final user = await AuthService.getUser(context);
  final userId = user.id.toString();

  final shiftId = prefs.getString('shift_id_$userId');
  if (shiftId == null) {
    print('No shift ID found for this user.');
    return;
  }

  final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
  final String apiUri = dotenv.env['POS_API_URL'] ?? "";
  final url = Uri.parse('$apiUri/api/v1/shift/end');

  final Map<String, dynamic> data = {
    'id': shiftId,
    'ending_balance': double.parse(endingBalance),
  };

  try {
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Pos-Secret-Key': apiSecret,
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print('Shift ended: ${response.body}');
      await prefs.remove('shift_id_$userId'); // remove per-user shift
    } else {
      print('Failed to end shift: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<ContinueShiftResult> continueShift({required dynamic context}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null || token.isEmpty) {
    return ContinueShiftResult(success: false, error: 'No token found');
  }

  // Get current user ID
  final user = await AuthService.getUser(context);
  final userId = user.id.toString();

  final shiftId = prefs.getString('shift_id_$userId');
  if (shiftId == null || shiftId.isEmpty) {
    return ContinueShiftResult(success: false, error: 'No active shift found');
  }

  final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
  final String apiUri = dotenv.env['POS_API_URL'] ?? "";
  final url = Uri.parse('$apiUri/api/v1/shift/$shiftId');

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Pos-Secret-Key': apiSecret,
      },
    );

    if (response.statusCode == 200) {
      print('Continuing shift: $shiftId for user $userId');
      return ContinueShiftResult(success: true, shiftId: shiftId);
    } else {
      print('Failed to continue shift: ${response.body}');
      return ContinueShiftResult(success: false, error: response.body);
    }
  } catch (e) {
    print('Error: $e');
    return ContinueShiftResult(success: false, error: e.toString());
  }
}

Future<bool> isTodayShiftValid({required dynamic context}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null || token.isEmpty) {
    return false;
  }

  // Get current user ID
  final user = await AuthService.getUser(context);
  final userId = user.id.toString();

  final shiftId = prefs.getString('shift_id_$userId');
  if (shiftId == null || shiftId.isEmpty) {
    return false;
  }

  final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
  final String apiUri = dotenv.env['POS_API_URL'] ?? "";
  final url = Uri.parse('$apiUri/api/v1/shift/$shiftId');

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Pos-Secret-Key': apiSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final createdAt = DateTime.parse(data['created_at']);
      final timeOut = data['time_out']; // null if still active
      final now = DateTime.now();

      final isToday =
          createdAt.year == now.year &&
          createdAt.month == now.month &&
          createdAt.day == now.day;

      return isToday && timeOut == null;
    }
  } catch (e) {
    print('Error: $e');
  }

  return false;
}
