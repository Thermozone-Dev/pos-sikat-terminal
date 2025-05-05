import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For jsonEncode & jsonDecode
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For dev env variables
import 'package:device_info_plus/device_info_plus.dart'; // For Device Info
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Secure Storage

class TransactionService {
  static Map<String, dynamic> decodeTransactionData(String data) {
    return json.decode(data);
  }

  static String encodeTransactionData(Map<String, dynamic> data) {
    return json.encode(data);
  }

  static List formatTransactionItemDiscounts(Map<String, dynamic> data) {
    var itemDiscounts = [];
    if (data['items']['discounts'] != null) {
      itemDiscounts = data['items']['discounts'].map(
        (discount) => discount['id'],
      );
    }
    return itemDiscounts;
  }

  static List formatTransactionDiscounts(Map<String, dynamic> data) {
    var discounts = [];
    if (data['transactions_discounts'] != null) {
      discounts =
          data['transaction_discounts']
              .map((discount) => discount['id'])
              .toList();
    }
    return discounts;
  }

  static Map<String, dynamic> formatTransactionData(Map<String, dynamic> data) {
    final mappedItems =
        data['items'].map((item) {
          var itemDiscounts = [];
          if (item['discounts'] != null) {
            itemDiscounts = item['discounts'].map((discount) => discount['id']);
          }
          final discountList = itemDiscounts;

          final itemParsed = {
            'item_id': item['data']['id'],
            'item_quantity': item['quantity'],
            'item_discounts': discountList.isEmpty ? null : discountList,
            'discount_value': 0.00,
            'total_value': item['data']['price'] * item['quantity'],
          };
          return itemParsed;
        }).toList();

    final encodedItems = mappedItems;
    final encodedDiscounts = formatTransactionDiscounts(data);

    var encodedData = {'items': encodedItems};

    encodedData.addAll({
      'transaction_method': data['transaction_method'],
      'transaction_fee': data['transaction_fee'] ?? 0.00,
      'cash_tendered': data['cash_tendered'] ?? 0.00,
      'change': data['change'] ?? 0.00,
      'total_sales': data['total_sales'] ?? 0.00,
      'gross_sales': data['gross_sales'] ?? 0.00,
      'vatable_sales': data['vatable_sales'] ?? 0.00,
      'vat': data['vat'] ?? 0.00,
      'vat_exempt_sales': data['vat_exempt_sales'] ?? 0.00,
      'zero_rated_sales': data['zero_rated_sales'] ?? 0.00,
      'transaction_discounts':
          encodedDiscounts.isEmpty ? null : encodedDiscounts,
      'gov_discount_details': {},
    });

    return encodedData;
  }

  static void saveTransactionData(dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
    final String apiUri = dotenv.env['POS_API_URL'] ?? "";
    final url = Uri.parse('$apiUri/api/v1/transactions');

    print(json.encode(data));

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Pos-Secret-key': apiSecret,
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Transaction saved successfully: $data');
      } else {
        final errorData = jsonDecode(response.body);
        final message = errorData ?? 'Transaction failed';
        print('Error: $message');
      }
    } catch (e) {
      print(e);
    }
  }

  static Map<String, dynamic> processCalculations(
    Map<String, dynamic> transactionData,
  ) {
    double totalSales = 0.0;
    double grossSales = 0.0;
    double vatableSales = 0.0;
    double vat = 0.0;
    double vatExemptSales = 0.0;
    double zeroRatedSales = 0.0;

    // for (var item in transactionData['items']) {
    //   totalSales += item['data']['price'] * item['quantity'];
    //   grossSales += item['data']['price'] * item['quantity'];
    //   if (item['data']['vatable']) {
    //     vatableSales += item['data']['price'] * item['quantity'];
    //     vat +=
    //         (item['data']['price'] * item['quantity']) *
    //         0.12; // Assuming 12% VAT
    //   } else if (item['data']['vat_exempt']) {
    //     vatExemptSales += item['data']['price'] * item['quantity'];
    //   } else if (item['data']['zero_rated']) {
    //     zeroRatedSales += item['data']['price'] * item['quantity'];
    //   }
    // }

    transactionData['total_sales'] = totalSales;
    transactionData['gross_sales'] = grossSales;
    transactionData['vatable_sales'] = vatableSales;
    transactionData['vat'] = vat;
    transactionData['vat_exempt_sales'] = vatExemptSales;
    transactionData['zero_rated_sales'] = zeroRatedSales;

    return transactionData;
  }
}
