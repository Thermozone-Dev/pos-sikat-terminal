import 'dart:convert';

import 'package:bir_pos/services/discount_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For dev env variables

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
          data['transaction_discounts'].map((discount) => discount).toList();
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
            'discount_value': item['data']['discount_value'],
            'total_value': item['data']['total_value'],
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

  static Future<int?> saveTransactionData(dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
    final String apiUri = dotenv.env['POS_API_URL'] ?? "";
    final url = Uri.parse('$apiUri/api/v1/transactions');

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
        // print('Transaction saved successfully: $data');
        return data['transaction details']['id'];
      } else {
        final errorData = jsonDecode(response.body);
        final message = errorData ?? 'Transaction failed';
        print('Error: $message');
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Map<String, dynamic> processCalculations(
    Map<String, dynamic> transactionData,
  ) {
    final vatValue = 0.12;
    double totalSales = 0.0;
    double grossSales = 0.0;
    double vatableSales = 0.0;
    double vat = 0.0;
    double vatExemptSales = 0.0;
    double vatAdjustSales = 0.0;
    double zeroRatedSales = 0.0;

    for (var item in transactionData['items']) {
      double initialValue = 0.0;
      double totalValue = 0.0;
      double discountValue = 0.0;

      initialValue = item['data']['price'] * item['quantity'];

      //Remove VAT from initial sales
      totalValue = initialValue / (1 + vatValue);
      double initialVat = totalValue - (totalValue * vatValue);

      //Add Checking for Vat Inclusive and Exclusive Sales
      grossSales += initialValue / (1 + vatValue);

      if (item['data']['item_discounts'] != null &&
          !(item['data']['item_discounts'].entries.isEmpty)) {
        //Calculate Discount Values
        final discount = item['data']['item_discounts'];
        if (discount['is_percentage']) {
          discountValue += totalValue * (discount['value'] / 100);
        } else {
          discountValue += discount['value'];
        }
        totalValue -= discountValue;
      }

      item['data']['discount_value'] = discountValue;
      item['data']['total_value'] = totalValue;

      vatableSales += totalValue;

      double exemptCalc = vatableSales - initialValue;
      double adjustCalc = initialVat - (discountValue * vatValue);

      vatAdjustSales += adjustCalc;
    }

    if (transactionData['transaction_discounts'] != null &&
        !(transactionData['transaction_discounts'].entries.isEmpty)) {
      double totalValue = 0.0;
      double initialValue = vatableSales;
      double discountValue = 0.0;

      //Remove VAT from initial sales
      totalValue = initialValue;

      double initialVat = totalValue - (totalValue * vatValue);

      //Calculate Discount Values
      final discount = transactionData['transaction_discounts'];
      if (discount['is_percentage']) {
        discountValue += totalValue * (discount['value'] / 100);
      } else {
        discountValue += discount['value'];
      }
      vatableSales = totalValue - discountValue;

      double exemptCalc = vatableSales - initialValue;
      double adjustCalc = initialVat - (discountValue * vatValue);

      vatAdjustSales += adjustCalc;
    }

    vat = vatableSales * vatValue;
    totalSales += vatableSales + vat + vatExemptSales + zeroRatedSales;

    transactionData['cash_tendered'] =
        transactionData['transaction_is_digital']
            ? totalSales
            : transactionData['cash_tendered'];

    transactionData['change'] =
        transactionData['transaction_is_digital']
            ? 0.00
            : totalSales - transactionData['cash_tendered'];

    transactionData['total_sales'] = totalSales;
    transactionData['gross_sales'] = grossSales;
    transactionData['vatable_sales'] = vatableSales;
    transactionData['vat'] = vat;
    transactionData['vat_exempt_sales'] = vatExemptSales;
    transactionData['vat_adjust_sales'] = vatAdjustSales;
    transactionData['zero_rated_sales'] = zeroRatedSales;

    return transactionData;
  }
}
