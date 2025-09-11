import 'dart:convert';
import 'package:bir_pos/models/zreading_reprint.dart';
import 'package:bir_pos/models/zreading_summary.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZReadingReprintService {
  Future<ZReadingReprint?> fetchReprint(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
    final String apiUri = dotenv.env['POS_API_URL'] ?? "";
    final url = Uri.parse('$apiUri/api/v1/zreading/reprint');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Pos-Secret-key': apiSecret,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'date': date}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ZReadingReprint.fromJson(data);
    } else {
      throw Exception('Failed to fetch ZReadingReprint: ${response.body}');
    }
  }

  Future<ZReadingSummary?> fetchSummary(
    String startDate,
    String endDate,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
    final String apiUri = dotenv.env['POS_API_URL'] ?? "";
    final url = Uri.parse('$apiUri/api/v1/zreading/summary');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Pos-Secret-key': apiSecret,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'date_from': startDate, 'date_to': endDate}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ZReadingSummary.fromJson(data);
    } else {
      throw Exception('Failed to fetch ZReading Summary: ${response.body}');
    }
  }
}
