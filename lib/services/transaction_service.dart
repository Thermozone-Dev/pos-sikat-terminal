import 'dart:convert';

class TransactionService {
  static Map<String, dynamic> decodeTransactionData(String data) {
    return json.decode(data);
  }

  static String encodeTransactionData(Map<String, dynamic> data) {
    return json.encode(data);
  }
}
