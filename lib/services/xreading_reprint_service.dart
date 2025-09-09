import 'dart:convert';
import 'package:bir_pos/models/xreading_reprint.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class XReadingReprintService {
  Future<XReadingReprint> fetchXReadingReprint({
    required int userId,
    required String date,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
    final String apiUri = dotenv.env['POS_API_URL'] ?? "";
    final url = Uri.parse('$apiUri/api/v1/xreading/reprint');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Pos-Secret-Key': apiSecret,
      },
      body: jsonEncode({'user_id': userId, 'date': date}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return XReadingReprint.fromJson(data);
    } else {
      throw Exception('Failed to fetch X Reading Reprint: ${response.body}');
    }
  }
}
