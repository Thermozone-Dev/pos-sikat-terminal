import 'package:bir_pos/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For dev env variables

class TransactionService {
  static Map<String, dynamic> decodeTransactionData(String data) {
    return json.decode(data);
  }

  static String encodeTransactionData(Map<String, dynamic> data) {
    return json.encode(data);
  }
}
