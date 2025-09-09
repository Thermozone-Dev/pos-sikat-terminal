class XReadingReprint {
  final int id;
  final String generatedBy;
  final String reportDate;
  final String reportTime;
  final String startTime;
  final String endTime;
  final String cashierName;
  final String beginningSi;
  final String endingSi;
  final double openingFund;
  final double cashPayments;
  final double gcashPayments;
  final double mayaPayments;
  final double debitPayments;
  final double creditPayments;
  final double totalPayments;
  final double voidAmount;
  final double withdrawal;
  final double cashInDrawer;
  final double lessWithdrawal;
  final double shortOver;
  final DateTime createdAt;
  final DateTime updatedAt;

  XReadingReprint({
    required this.id,
    required this.generatedBy,
    required this.reportDate,
    required this.reportTime,
    required this.startTime,
    required this.endTime,
    required this.cashierName,
    required this.beginningSi,
    required this.endingSi,
    required this.openingFund,
    required this.cashPayments,
    required this.gcashPayments,
    required this.mayaPayments,
    required this.debitPayments,
    required this.creditPayments,
    required this.totalPayments,
    required this.voidAmount,
    required this.withdrawal,
    required this.cashInDrawer,
    required this.lessWithdrawal,
    required this.shortOver,
    required this.createdAt,
    required this.updatedAt,
  });

  factory XReadingReprint.fromJson(Map<String, dynamic> json) {
    return XReadingReprint(
      id: json['id'],
      generatedBy: json['generated_by'],
      reportDate: json['report_date'],
      reportTime: json['report_time'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      cashierName: json['cashier_name'],
      beginningSi: json['beginning_si'],
      endingSi: json['ending_si'],
      openingFund: (json['opening_fund'] as num).toDouble(),
      cashPayments: (json['cash_payments'] as num).toDouble(),
      gcashPayments: (json['gcash_payments'] as num).toDouble(),
      mayaPayments: (json['maya_payments'] as num).toDouble(),
      debitPayments: (json['debit_payments'] as num).toDouble(),
      creditPayments: (json['credit_payments'] as num).toDouble(),
      totalPayments: (json['total_payments'] as num).toDouble(),
      voidAmount: (json['void'] as num).toDouble(),
      withdrawal: (json['withdrawal'] as num).toDouble(),
      cashInDrawer: (json['cash_in_drawer'] as num).toDouble(),
      lessWithdrawal: (json['less_withdrawal'] as num).toDouble(),
      shortOver: (json['short_over'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
