import 'package:bir_pos/models/discount.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For dev env variables

class DiscountService {
  static Future<List<Discount>> getDiscounts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
    final String apiUri = dotenv.env['POS_API_URL'] ?? "";
    final url = Uri.parse('$apiUri/api/v1/discounts');

    final response = await http
        .get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Pos-Secret-key': apiSecret,
          },
        )
        .timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> data =
          jsonResponse is List ? jsonResponse : jsonResponse['data'];
      return data.map((json) => Discount.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load discounts');
    }
  }

  static Future<Discount> getDiscount(id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
    final String apiUri = dotenv.env['POS_API_URL'] ?? "";
    final url = Uri.parse('$apiUri/api/v1/discounts/$id');

    final response = await http
        .get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Pos-Secret-key': apiSecret,
          },
        )
        .timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return Discount.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load discount');
    }
  }
}
