import 'dart:convert';
import 'package:bir_pos/models/xreading.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class XReadingService {
  final String baseUrl;
  final String token;

  XReadingService({required this.baseUrl, required this.token});

  Future<XReading?> fetchXReading() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('$baseUrl/api/v1/xreading');
    final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Pos-Secret-Key': apiSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return XReading.fromJson(data);
    } else {
      print('Failed to load X Reading: ${response.statusCode}');
      return null;
    }
  }
}
