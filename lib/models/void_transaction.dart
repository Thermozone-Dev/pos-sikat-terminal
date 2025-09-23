class VoidTransactionResponse {
  final String message;
  final TransactionDetails transactionDetails;
  final List<Item> items;
  final List<DiscountedItem> discountedItems;

  VoidTransactionResponse({
    required this.message,
    required this.transactionDetails,
    required this.items,
    required this.discountedItems,
  });

  factory VoidTransactionResponse.fromJson(Map<String, dynamic> json) {
    return VoidTransactionResponse(
      message: json['message'] ?? '',
      transactionDetails: TransactionDetails.fromJson(
        json['transaction_details'],
      ),
      items: (json['items'] as List).map((e) => Item.fromJson(e)).toList(),
      discountedItems:
          (json['discounted_items'] as List)
              .map((e) => DiscountedItem.fromJson(e))
              .toList(),
    );
  }
}

class TransactionDetails {
  final int id;
  final String voidId;
  final String voidDate;
  final String voidTime;
  final String processedBy;
  final String siNo;
  final String date;
  final String time;
  final String paymentMethod;
  final bool isSc;
  final bool isPwd;
  final bool isNac;
  final bool isSoloParent;
  final String grossSales;
  final String cashTendered;
  final String vatableSales;
  final String change;
  final String vat;
  final String vatExemptSales;
  final String zeroRatedSales;
  final String totalSales;

  TransactionDetails({
    required this.id,
    required this.voidId,
    required this.voidDate,
    required this.voidTime,
    required this.processedBy,
    required this.siNo,
    required this.date,
    required this.time,
    required this.paymentMethod,
    required this.isSc,
    required this.isPwd,
    required this.isNac,
    required this.isSoloParent,
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
      voidId: json['void_id'] ?? '',
      voidDate: json['void_date'] ?? '',
      voidTime: json['void_time'] ?? '',
      processedBy: json['processed_by'] ?? '',
      siNo: json['si_no'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      isSc: json['is_sc'] ?? false,
      isPwd: json['is_pwd'] ?? false,
      isNac: json['is_nac'] ?? false,
      isSoloParent: json['is_soloparent'] ?? false,
      grossSales: json['gross_sales'] ?? '0.00',
      cashTendered: json['cash_tendered'] ?? '0.00',
      vatableSales: json['vatable_sales'] ?? '0.00',
      change: json['change'] ?? '0.00',
      vat: json['vat'] ?? '0.00',
      vatExemptSales: json['vat_exempt_sales'] ?? '0.00',
      zeroRatedSales: json['zero_rated_sales'] ?? '0.00',
      totalSales: json['total_sales'] ?? '0.00',
    );
  }
}

class Item {
  final int id;
  final String type;
  final String name;
  final int quantity;
  final double price;

  Item({
    required this.id,
    required this.type,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num).toDouble(),
    );
  }
}

class DiscountedItem extends Item {
  final String discountValue;

  DiscountedItem({
    required int id,
    required String type,
    required String name,
    required int quantity,
    required double price,
    required this.discountValue,
  }) : super(id: id, type: type, name: name, quantity: quantity, price: price);

  factory DiscountedItem.fromJson(Map<String, dynamic> json) {
    return DiscountedItem(
      id: json['id'],
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num).toDouble(),
      discountValue: json['discount_value'] ?? '0.00',
    );
  }
}
