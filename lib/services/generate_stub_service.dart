import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GenerateStubService {
  Future<List<Map<String, dynamic>>> generateStub(int transactionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
      final String apiUri = dotenv.env['POS_API_URL'] ?? "";
      final url = Uri.parse('$apiUri/api/v1/generate_stub/$transactionId');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Pos-Secret-key': apiSecret,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> rawList = json.decode(response.body);
        return rawList.cast<Map<String, dynamic>>();
      } else {
        print('Failed to generate stub: ${response.body}');
      }
    } catch (e) {
      print('Error generating stub: $e');
    }

    return [];
  }
}
