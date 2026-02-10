class ZReadingReprint {
  final int id;
  final String startTime;
  final String endTime;
  final String beginningSi;
  final String endingSi;
  final String beginningVoid;
  final String endingVoid;
  final String reportDate;
  final String reportTime;
  final int counter;
  final int resetCounter;
  final double presentAccumulatedSales;
  final double previousAccumulatedSales;
  final double salesForTheDay;
  final double vatableSales;
  final double vat;
  final double vatExemptSales;
  final double zeroRatedSales;
  final double grossAmount;
  final double totalDiscounts;
  final double totalVatAdjustments;
  final double lessDiscount;
  final double lessVoid;
  final double lessVatAdjust;
  final double netAmount;
  final double scDiscounts;
  final double pwdDiscounts;
  final double naacDiscounts;
  final double spDiscounts;
  final double otherDiscounts;
  final double voidAmount;
  final double returns;
  final double scAdjustments;
  final double pwdAdjustments;
  final double regDiscountAdjustments;
  final double zeroRatedAdjustments;
  final double vatOnReturn;
  final double otherVatAdjustments;
  final double cashInDrawer;
  final double gcashPayments;
  final double mayaPayments;
  final double debitPayments;
  final double creditPayments;
  final double openingFund;
  final double withdrawal;
  final double lessWithdrawal;
  final double paymentsReceived;
  final double shortOver;
  final double accumulatedSales;
  final String createdAt;
  final String updatedAt;

  ZReadingReprint({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.beginningSi,
    required this.endingSi,
    required this.beginningVoid,
    required this.endingVoid,
    required this.reportDate,
    required this.reportTime,
    required this.counter,
    required this.resetCounter,
    required this.presentAccumulatedSales,
    required this.previousAccumulatedSales,
    required this.salesForTheDay,
    required this.vatableSales,
    required this.vat,
    required this.vatExemptSales,
    required this.zeroRatedSales,
    required this.grossAmount,
    required this.totalDiscounts,
    required this.totalVatAdjustments,
    required this.lessDiscount,
    required this.lessVoid,
    required this.lessVatAdjust,
    required this.netAmount,
    required this.scDiscounts,
    required this.pwdDiscounts,
    required this.naacDiscounts,
    required this.spDiscounts,
    required this.otherDiscounts,
    required this.voidAmount,
    required this.returns,
    required this.scAdjustments,
    required this.pwdAdjustments,
    required this.regDiscountAdjustments,
    required this.zeroRatedAdjustments,
    required this.vatOnReturn,
    required this.otherVatAdjustments,
    required this.cashInDrawer,
    required this.gcashPayments,
    required this.mayaPayments,
    required this.debitPayments,
    required this.creditPayments,
    required this.openingFund,
    required this.withdrawal,
    required this.lessWithdrawal,
    required this.paymentsReceived,
    required this.shortOver,
    required this.accumulatedSales,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ZReadingReprint.fromJson(Map<String, dynamic> json) {
    return ZReadingReprint(
      id: json['id'],
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      beginningSi: json['beginning_si'] ?? '',
      endingSi: json['ending_si'] ?? '',
      beginningVoid: json['beginning_void'] ?? '',
      endingVoid: json['ending_void'] ?? '',
      reportDate: json['report_date'] ?? '',
      reportTime: json['report_time'] ?? '',
      counter: json['counter'] ?? 0,
      resetCounter: json['reset_counter'] ?? 0,
      presentAccumulatedSales:
          (json['present_accumulated_sales'] ?? 0).toDouble(),
      previousAccumulatedSales:
          (json['previous_accumulated_sales'] ?? 0).toDouble(),
      salesForTheDay: (json['sales_for_the_day'] ?? 0).toDouble(),
      vatableSales: (json['vatable_sales'] ?? 0).toDouble(),
      vat: (json['vat'] ?? 0).toDouble(),
      vatExemptSales: (json['vat_exempt_sales'] ?? 0).toDouble(),
      zeroRatedSales: (json['zero_rated_sales'] ?? 0).toDouble(),
      grossAmount: (json['gross_amount'] ?? 0).toDouble(),
      totalDiscounts: (json['total_discounts'] ?? 0).toDouble(),
      totalVatAdjustments: (json['total_vat_adjusts'] ?? 0).toDouble(),
      lessDiscount: (json['less_discount'] ?? 0).toDouble(),
      lessVoid: (json['less_void'] ?? 0).toDouble(),
      lessVatAdjust: (json['less_vat_adjust'] ?? 0).toDouble(),
      netAmount: (json['net_amount'] ?? 0).toDouble(),
      scDiscounts: (json['sc_discounts'] ?? 0).toDouble(),
      pwdDiscounts: (json['pwd_discounts'] ?? 0).toDouble(),
      naacDiscounts: (json['naac_discounts'] ?? 0).toDouble(),
      spDiscounts: (json['sp_discounts'] ?? 0).toDouble(),
      otherDiscounts: (json['other_discounts'] ?? 0).toDouble(),
      voidAmount: (json['void'] ?? 0).toDouble(),
      returns: (json['returns'] ?? 0).toDouble(),
      scAdjustments: (json['sc_adjustments'] ?? 0).toDouble(),
      pwdAdjustments: (json['pwd_adjustments'] ?? 0).toDouble(),
      regDiscountAdjustments:
          (json['reg_discount_adjustments'] ?? 0).toDouble(),
      zeroRatedAdjustments: (json['zero_rated_adjustments'] ?? 0).toDouble(),
      vatOnReturn: (json['vat_on_return'] ?? 0).toDouble(),
      otherVatAdjustments: (json['other_vat_adjustments'] ?? 0).toDouble(),
      cashInDrawer: (json['cash_in_drawer'] ?? 0).toDouble(),
      gcashPayments: (json['gcash_payments'] ?? 0).toDouble(),
      mayaPayments: (json['maya_payments'] ?? 0).toDouble(),
      debitPayments: (json['debit_payments'] ?? 0).toDouble(),
      creditPayments: (json['credit_payments'] ?? 0).toDouble(),
      openingFund: (json['opening_fund'] ?? 0).toDouble(),
      withdrawal: (json['withdrawal'] ?? 0).toDouble(),
      lessWithdrawal: (json['less_withdrawal'] ?? 0).toDouble(),
      paymentsReceived: (json['payments_received'] ?? 0).toDouble(),
      shortOver: (json['short_over'] ?? 0).toDouble(),
      accumulatedSales: (json['accumulated_sales'] ?? 0).toDouble(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
