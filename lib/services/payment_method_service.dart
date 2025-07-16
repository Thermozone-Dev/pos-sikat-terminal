import 'package:bir_pos/models/payment_method.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For dev env variables

class PaymentMethodService {
  static Future<List<PaymentMethod>> getMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
    final String apiUri = dotenv.env['POS_API_URL'] ?? "";
    final url = Uri.parse('$apiUri/api/v1/paymentMethods');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Pos-Secret-key': apiSecret,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> data =
          jsonResponse is List ? jsonResponse : jsonResponse['data'];
      return data.map((json) => PaymentMethod.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load transaction methods');
    }
  }
}
