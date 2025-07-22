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
    if (data['items']['item_discounts'] != null) {
      itemDiscounts = data['items']['item_discounts'].map(
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
          final itemParsed = {
            'item_id': item['data']['id'],
            'item_quantity': item['quantity'],
            'item_discounts': item['data']['item_discounts'],
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
      'vat_deduction': data['vat_deduction'] ?? 0.00,
      'vat_adjustment': data['vat_adjustment'] ?? 0.00,
      'zero_rated_sales': data['zero_rated_sales'] ?? 0.00,
      'transaction_discounts':
          encodedDiscounts.isEmpty ? null : encodedDiscounts,
      'gov_discount_details': data['gov_discount_details'],
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
    double vatDeduction = 0.0;
    double vatAdjustment = 0.0;
    double zeroRatedSales = 0.0;
    double totalDiscount = 0.0;

    // Per Item Processing
    for (var item in transactionData['items']) {
      double initialPrice = 0.0;
      double grossValue = 0.0;
      double vatTotal = 0.0;

      double itemTotal = 0.0;
      double itemVat = 0.0;
      double itemAdjust = 0.0;
      double itemExempt = 0.0;
      double itemDeduct = 0.0;
      double itemVatableSales = 0.0;
      double itemDiscountValue = 0.0;

      double paxAmount = 0.0;

      print('Processing item: ${item['data']['name']}');
      if (item['data']['pax'] <= 1.00) {
        paxAmount = 1;
      } else {
        paxAmount = item['data']['pax'];
      }

      initialPrice = item['data']['price'] * item['quantity'];

      //Remove VAT from initial sales and get vat value
      grossValue = initialPrice / (1 + vatValue);
      vatTotal = grossValue * vatValue;

      //!!!Add Checking for Vat Inclusive and Exclusive Sales
      grossSales += grossValue;

      double initialVat = vatValue;

      double paxVat = vatTotal / paxAmount;
      double paxTotal = grossValue / paxAmount;
      double salesTotal = grossValue - paxTotal;

      double paxDiscount = 0.0;
      double newVat = 0.0;

      if (item['data']['item_discounts'] != null &&
          !(item['data']['item_discounts'].entries.isEmpty)) {
        itemTotal -= paxTotal;
        //Calculate Discount Values
        final discount = item['data']['item_discounts'];

        if (discount['is_percentage']) {
          paxDiscount = paxTotal * (discount['value'] / 100);
          itemDiscountValue += paxDiscount;
          paxTotal -= paxDiscount;
        } else {
          itemDiscountValue += discount['value'];
          paxDiscount = itemDiscountValue / paxAmount;

          paxTotal -= paxDiscount;
          salesTotal -= itemDiscountValue - paxDiscount;
        }

        if (discount['is_government_discount'] && item['data']['vat_exempt']) {
          itemAdjust = paxVat;
          itemExempt = paxTotal;
        } else {
          newVat = (salesTotal + paxTotal) * vatValue;
          itemAdjust = initialVat - newVat;
        }
      }

      itemVatableSales = (salesTotal + paxTotal) - itemExempt;
      itemVat = vatTotal - itemAdjust;
      itemDeduct = itemExempt + itemAdjust;
      itemTotal = itemVatableSales + itemVat + itemExempt;

      // print(
      //   'Item: ${item['data']['name']}, '
      //   'Initial Price: $initialPrice, '
      //   'Gross Value: $grossValue, '
      //   'VAT Total: $vatTotal, ',
      // );

      // print(
      //   'Pax Amount: $paxAmount, '
      //   'Pax Total: $paxTotal, '
      //   'Pax Discount: $paxDiscount, '
      //   'Sales Total: $salesTotal, ',
      // );

      // print(
      //   'Item Total: $itemTotal, '
      //   'Item VAT: $itemVat, '
      //   'Item Adjust: $itemAdjust, '
      //   'Item Exempt: $itemExempt, '
      //   'Item Deduct: $itemDeduct',
      // );

      item['data']['discount_value'] = itemDiscountValue;
      item['data']['total_value'] = itemTotal;

      vatAdjustment += itemAdjust;
      vatExemptSales += itemExempt;
      vatDeduction += itemDeduct;

      vat += itemVat;
      vatableSales += itemVatableSales;
      totalSales += itemTotal;
    }

    transactionData['cash_tendered'] =
        transactionData['transaction_is_digital']
            ? totalSales
            : transactionData['cash_tendered'];

    if (!transactionData['transaction_is_digital']) {
      final change = transactionData['cash_tendered'] - totalSales;
      transactionData['change'] =
          change < 0 ? 0.00 : change; // Ensure change is not negative
    } else {
      transactionData['change'] = 0.00;
    }

    transactionData['total_sales'] = totalSales;
    transactionData['gross_sales'] = grossSales;
    transactionData['vatable_sales'] = vatableSales;
    transactionData['vat'] = vat;
    transactionData['vat_exempt_sales'] = vatExemptSales;
    transactionData['vat_deduction'] = vatDeduction;
    transactionData['vat_adjustment'] = vatAdjustment;
    transactionData['zero_rated_sales'] = zeroRatedSales;
    transactionData['discount_value'] = totalDiscount;

    print(transactionData);

    return transactionData;
  }
}
