class XReading {
  final String reportDate;
  final String reportTime;
  final String timeIn;
  final String timeOut;
  final String user;
  final String beginningOR;
  final String endingOR;
  final double openingFund;
  final double totalCashPayment;
  final double totalDigitalPayment;
  final double totalCreditPayment;
  final double totalPayments;
  final double voidValue;
  final double refundValue;
  final double endingFund;

  XReading({
    required this.reportDate,
    required this.reportTime,
    required this.timeIn,
    required this.timeOut,
    required this.user,
    required this.beginningOR,
    required this.endingOR,
    required this.openingFund,
    required this.totalCashPayment,
    required this.totalDigitalPayment,
    required this.totalCreditPayment,
    required this.totalPayments,
    required this.voidValue,
    required this.refundValue,
    required this.endingFund,
  });

  factory XReading.fromJson(Map<String, dynamic> json) {
    return XReading(
      reportDate: json['report_date'] ?? '',
      reportTime: json['report_time'] ?? '',
      timeIn: json['time_in'] ?? '',
      timeOut: json['time_out'] ?? '',
      user: json['user'] ?? '',
      beginningOR: json['beginning_or'] ?? '',
      endingOR: json['ending_or'] ?? '',
      openingFund: (json['opening_fund'] ?? 0).toDouble(),
      totalCashPayment: (json['total_cash_payment'] ?? 0).toDouble(),
      totalDigitalPayment: (json['total_digital_payment'] ?? 0).toDouble(),
      totalCreditPayment: (json['total_credit_payment'] ?? 0).toDouble(),
      totalPayments: (json['total_payments'] ?? 0).toDouble(),
      voidValue: (json['void_value'] ?? 0).toDouble(),
      refundValue: (json['refund_value'] ?? 0).toDouble(),
      endingFund: (json['ending_fund'] ?? 0).toDouble(),
    );
  }
}
