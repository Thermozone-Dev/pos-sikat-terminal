class TransactionResponse {
  final TransactionDetails transactionDetails;
  final List<TransactionBasketItem> items;
  final List<DiscountedTransactionBasketItem> discountedItems;

  TransactionResponse({
    required this.transactionDetails,
    required this.items,
    required this.discountedItems,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      transactionDetails: TransactionDetails.fromJson(
        json['transaction_details'],
      ),
      items:
          (json['items'] as List)
              .map((e) => TransactionBasketItem.fromJson(e))
              .toList(),
      discountedItems:
          (json['discounted_items'] as List)
              .map((e) => DiscountedTransactionBasketItem.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_details': transactionDetails.toJson(),
      'items': items.map((e) => e.toJson()).toList(),
      'discounted_items': discountedItems.map((e) => e.toJson()).toList(),
    };
  }
}

class TransactionDetails {
  final int id;
  final String processedBy;
  final String siNo;
  final String date;
  final String time;
  final String paymentMethod;
  final bool is_sc;
  final bool is_pwd;
  final bool is_nac;
  final bool is_soloparent;
  final double grossSales;
  final double cashTendered;
  final double vatableSales;
  final double change;
  final double vat;
  final double vatExemptSales;
  final double zeroRatedSales;
  final double totalSales;

  TransactionDetails({
    required this.id,
    required this.processedBy,
    required this.siNo,
    required this.date,
    required this.time,
    required this.paymentMethod,
    required this.is_sc,
    required this.is_pwd,
    required this.is_nac,
    required this.is_soloparent,
    required this.grossSales,
    required this.cashTendered,
    required this.vatableSales,
    required this.change,
    required this.vat,
    required this.vatExemptSales,
    required this.zeroRatedSales,
    required this.totalSales,
  });

  factory TransactionDetails.fromJson(Map<String, dynamic> json) {
    return TransactionDetails(
      id: json['id'],
      processedBy: json['processed_by'],
      siNo: json['si_no'],
      date: json['date'],
      time: json['time'],
      paymentMethod: json['payment_method'],
      is_sc: json['is_sc'],
      is_pwd: json['is_pwd'],
      is_nac: json['is_nac'],
      is_soloparent: json['is_soloparent'],
      grossSales: double.tryParse(json['gross_sales'].toString()) ?? 0,
      cashTendered: double.tryParse(json['cash_tendered'].toString()) ?? 0,
      vatableSales: double.tryParse(json['vatable_sales'].toString()) ?? 0,
      change: double.tryParse(json['change'].toString()) ?? 0,
      vat: double.tryParse(json['vat'].toString()) ?? 0,
      vatExemptSales: double.tryParse(json['vat_exempt_sales'].toString()) ?? 0,
      zeroRatedSales: double.tryParse(json['zero_rated_sales'].toString()) ?? 0,
      totalSales: double.tryParse(json['total_sales'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "processed_by": processedBy,
      "si_no": siNo,
      "date": date,
      "time": time,
      "payment_method": paymentMethod,
      "is_sc": is_sc,
      "is_pwd": is_pwd,
      "is_nac": is_nac,
      "is_soloparent": is_soloparent,
      "grossSales": grossSales,
      "cash_tendered": cashTendered,
      "vatable_sales": vatableSales,
      "change": change,
      "vat": vat,
      "vat_exempt_sales": vatExemptSales,
      "zero_rated_sales": zeroRatedSales,
      "total_sales": totalSales,
    };
  }
}

class TransactionBasketItem {
  final int id;
  final String type;
  final String name;
  final int quantity;
  final double price;

  TransactionBasketItem({
    required this.id,
    required this.type,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory TransactionBasketItem.fromJson(Map<String, dynamic> json) {
    return TransactionBasketItem(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      quantity: json['quantity'],
      price: double.tryParse(json['price'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type,
      "name": name,
      "quantity": quantity,
      "price": price,
    };
  }
}

class DiscountedTransactionBasketItem {
  final int id;
  final String type;
  final String name;
  final int quantity;
  final double price;
  final double discountValue;

  DiscountedTransactionBasketItem({
    required this.id,
    required this.type,
    required this.name,
    required this.quantity,
    required this.price,
    required this.discountValue,
  });

  factory DiscountedTransactionBasketItem.fromJson(Map<String, dynamic> json) {
    return DiscountedTransactionBasketItem(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      quantity: json['quantity'],
      price: double.tryParse(json['price'].toString()) ?? 0,
      discountValue: double.tryParse(json['discount_value'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type,
      "name": name,
      "quantity": quantity,
      "price": price,
      "discountValue": discountValue,
    };
  }
}
