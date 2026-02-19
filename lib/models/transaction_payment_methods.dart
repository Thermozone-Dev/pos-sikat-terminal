class TransactionPaymentMethod {
  final int transactionId;
  final String paymentMethodName;
  final double cashTendered;
  final double transactionFee;
  final String referenceNumber;

  TransactionPaymentMethod({
    required this.transactionId,
    required this.paymentMethodName,
    required this.cashTendered,
    required this.transactionFee,
    required this.referenceNumber,
  });

  factory TransactionPaymentMethod.fromJson(Map<String, dynamic> json) {
    return TransactionPaymentMethod(
      transactionId: json['transaction_id'],
      paymentMethodName: json['payment_method_name'],
      cashTendered: double.tryParse(json['cash_tendered'].toString()) ?? 0,
      transactionFee: double.tryParse(json['transaction_fee'].toString()) ?? 0,
      referenceNumber: json['reference_number'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "transaction_id": transactionId,
      "payment_method_id": paymentMethodName,
      "cash_tendered": cashTendered,
      "transaction_fee": transactionFee,
      "reference_number": referenceNumber,
    };
  }
}
