import 'dart:convert';

class TransactionResponse {
  final TransactionDetails transactionDetails;
  final List<TransactionBasketItem> transactionBasket;

  TransactionResponse({
    required this.transactionDetails,
    required this.transactionBasket,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      transactionDetails: TransactionDetails.fromJson(
        json['transaction details'],
      ),
      transactionBasket:
          (json['transaction basket'] as List)
              .map((e) => TransactionBasketItem.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction details': transactionDetails.toJson(),
      'transaction basket': transactionBasket.map((e) => e.toJson()).toList(),
    };
  }
}

class TransactionDetails {
  final int id;
  final int processedBy;
  final int transactionBasketId;
  final String barcode;
  final double transactionFee;
  final String referenceNumber;
  final double vatableSales;
  final double cashTendered;
  final double change;
  final double vat;
  final double vatExemptSales;
  final double zeroRatedSales;
  final bool isValid;
  final bool isPwd;
  final bool isSc;
  final bool isNac;
  final bool isSoloparent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double totalSales;
  final double grossSales;
  final int transactionMethodId;
  final bool isZeroRated;
  final String? orNumber;
  final double vatDeduction;
  final double vatAdjustment;
  final Basket basket;

  TransactionDetails({
    required this.id,
    required this.processedBy,
    required this.transactionBasketId,
    required this.barcode,
    required this.transactionFee,
    required this.referenceNumber,
    required this.vatableSales,
    required this.cashTendered,
    required this.change,
    required this.vat,
    required this.vatExemptSales,
    required this.zeroRatedSales,
    required this.isValid,
    required this.isPwd,
    required this.isSc,
    required this.isNac,
    required this.isSoloparent,
    required this.createdAt,
    required this.updatedAt,
    required this.totalSales,
    required this.grossSales,
    required this.transactionMethodId,
    required this.isZeroRated,
    this.orNumber,
    required this.vatDeduction,
    required this.vatAdjustment,
    required this.basket,
  });

  factory TransactionDetails.fromJson(Map<String, dynamic> json) {
    return TransactionDetails(
      id: json['id'],
      processedBy: json['processed_by'],
      transactionBasketId: json['transaction_basket_id'],
      barcode: json['barcode'],
      transactionFee: (json['transaction_fee'] as num).toDouble(),
      referenceNumber: json['reference_number'],
      vatableSales: (json['vatable_sales'] as num).toDouble(),
      cashTendered: (json['cash_tendered'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      vat: (json['vat'] as num).toDouble(),
      vatExemptSales: (json['vat_exempt_sales'] as num).toDouble(),
      zeroRatedSales: (json['zero_rated_sales'] as num).toDouble(),
      isValid: json['is_valid'],
      isPwd: json['is_pwd'],
      isSc: json['is_sc'],
      isNac: json['is_nac'],
      isSoloparent: json['is_soloparent'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      totalSales: (json['total_sales'] as num).toDouble(),
      grossSales: (json['gross_sales'] as num).toDouble(),
      transactionMethodId: json['transaction_method_id'],
      isZeroRated: json['is_zero_rated'],
      orNumber: json['or_number'],
      vatDeduction: (json['vat_deduction'] as num).toDouble(),
      vatAdjustment: (json['vat_adjustment'] as num).toDouble(),
      basket: Basket.fromJson(json['basket']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "processed_by": processedBy,
      "transaction_basket_id": transactionBasketId,
      "barcode": barcode,
      "transaction_fee": transactionFee,
      "reference_number": referenceNumber,
      "vatable_sales": vatableSales,
      "cash_tendered": cashTendered,
      "change": change,
      "vat": vat,
      "vat_exempt_sales": vatExemptSales,
      "zero_rated_sales": zeroRatedSales,
      "is_valid": isValid,
      "is_pwd": isPwd,
      "is_sc": isSc,
      "is_nac": isNac,
      "is_soloparent": isSoloparent,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "total_sales": totalSales,
      "gross_sales": grossSales,
      "transaction_method_id": transactionMethodId,
      "is_zero_rated": isZeroRated,
      "or_number": orNumber,
      "vat_deduction": vatDeduction,
      "vat_adjustment": vatAdjustment,
      "basket": basket.toJson(),
    };
  }
}

class Basket {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TransactionBasketItem> items;

  Basket({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory Basket.fromJson(Map<String, dynamic> json) {
    return Basket(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      items:
          (json['items'] as List)
              .map((e) => TransactionBasketItem.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "items": items.map((e) => e.toJson()).toList(),
    };
  }
}

class TransactionBasketItem {
  final int id;
  final int transactionBasketId;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int itemId;
  final double discountValue;
  final double totalValue;
  final double packageBasePrice;

  TransactionBasketItem({
    required this.id,
    required this.transactionBasketId,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    required this.itemId,
    required this.discountValue,
    required this.totalValue,
    required this.packageBasePrice,
  });

  factory TransactionBasketItem.fromJson(Map<String, dynamic> json) {
    return TransactionBasketItem(
      id: json['id'],
      transactionBasketId: json['transaction_basket_id'],
      quantity: json['quantity'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      itemId: json['item_id'],
      discountValue: (json['discount_value'] as num).toDouble(),
      totalValue: (json['total_value'] as num).toDouble(),
      packageBasePrice: (json['package_base_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "transaction_basket_id": transactionBasketId,
      "quantity": quantity,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "item_id": itemId,
      "discount_value": discountValue,
      "total_value": totalValue,
      "package_base_price": packageBasePrice,
    };
  }
}
