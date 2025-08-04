// lib/services/claim_stub_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<Map<String, dynamic>?> claimStub(String stubNo) async {
  final String apiSecret = dotenv.env['STUB_API_SECRET'] ?? "";
  final String apiUri = dotenv.env['STUB_API_URL'] ?? "";
  final url = Uri.parse('$apiUri/api/verify-claim-stub');
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'stub_no': stubNo}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      try {
        final body = json.decode(response.body);
        final error = body['error'] ?? 'No error message provided.';
        throw Exception('Server responded with error: $error');
      } catch (e) {
        throw Exception('Unexpected response: ${response.body}');
      }
    }
  } catch (e) {
    print('claimStub error: $e');
    return null;
  }
}
