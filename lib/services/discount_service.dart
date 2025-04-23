import 'package:bir_pos/models/discount.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DiscountService {
  static Future<List<Discount>> getDiscounts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token not found');
    }

    final url = Uri.parse('http://bir-pos.test/api/v1/discounts');
    final response = await http
        .get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
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
}
