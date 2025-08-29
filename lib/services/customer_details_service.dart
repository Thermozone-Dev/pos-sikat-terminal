import 'dart:convert';
import 'package:bir_pos/models/customer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CustomerDetailsService {
  Future<Customer?> fetchCustomerDetails(int transaction_id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
    final String apiUri = dotenv.env['POS_API_URL'] ?? "";
    final url = Uri.parse('$apiUri/api/v1/customerDetails');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Pos-Secret-Key': apiSecret,
      },
      body: json.encode({'transaction_id': transaction_id}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Customer.fromJson(data);
    } else {
      print('Failed to load Customer Details: ${response.body}');
      return null;
    }
  }
}
