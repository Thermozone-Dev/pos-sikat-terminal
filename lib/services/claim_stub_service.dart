import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> claimStub(String stubNo) async {
  final url = Uri.parse('http://bir-pos.test/api/v1/claim_stub');

  try {
    final response = await http.post(url, body: {'stub_no': stubNo});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else if (response.statusCode == 404) {
      final error = json.decode(response.body)['error'];
      print('Stub not found: $error');
    } else {
      print('Unexpected error: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }

  return null;
}
