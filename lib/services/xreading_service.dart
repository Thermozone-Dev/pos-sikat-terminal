import 'dart:convert';
import 'package:bir_pos/models/xreading.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class XReadingService {
  Future<XReading?> fetchXReading(double currentCash) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
    final String apiUri = dotenv.env['POS_API_URL'] ?? "";
    final url = Uri.parse('$apiUri/api/v1/xreading');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Pos-Secret-Key': apiSecret,
      },
      body: json.encode({'currentCash': currentCash}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return XReading.fromJson(data);
    } else {
      print('Failed to load X Reading: ${response.body}');
      return null;
    }
  }
}
