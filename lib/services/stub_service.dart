import 'package:bir_pos/models/stub.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StubService {
  static Future<List<Stub>> genStub() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Authorization token is missing');
    }

    final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
    final String apiUri = dotenv.env['POS_API_URL'] ?? "";

    if (apiSecret.isEmpty || apiUri.isEmpty) {
      throw Exception('Missing API configuration');
    }

    final url = Uri.parse('$apiUri/api/v1/stubs');

    try {
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Pos-Secret-key': apiSecret,
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body is List ? body : body['data'] ?? [];
        return data.map((json) => Stub.fromJson(json)).toList();
      } else {
        print('Stub API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load stub details');
      }
    } catch (e) {
      print('Exception in genStub: $e');
      rethrow;
    }
  }
}
