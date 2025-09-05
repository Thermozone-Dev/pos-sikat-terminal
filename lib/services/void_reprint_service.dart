import 'dart:convert';
import 'package:bir_pos/models/reprint_void_transaction.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VoidReprintService {
  static Future<ReprintVoidTransactionResponse> fetchTransaction(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
    final String apiUri = dotenv.env['POS_API_URL'] ?? "";
    final url = Uri.parse('$apiUri/api/v1/void-print/$id');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Pos-Secret-key': apiSecret,
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ReprintVoidTransactionResponse.fromJson(data);
    } else {
      throw Exception(
        "Failed to load void transaction: ${response.statusCode}",
      );
    }
  }
}
