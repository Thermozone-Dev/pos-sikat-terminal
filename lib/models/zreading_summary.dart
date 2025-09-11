class ZReadingSummaryRequest {
  final String dateFrom;
  final String dateTo;

  ZReadingSummaryRequest({required this.dateFrom, required this.dateTo});

  Map<String, dynamic> toJson() {
    return {"date_from": dateFrom, "date_to": dateTo};
  }
}

class ZReadingSummary {
  final String startDate;
  final String endDate;
  final String presentAccumulatedSales;
  final String previousAccumulatedSales;
  final String salesForTheDay;
  final String vatableSales;
  final String vat;
  final String vatExemptSales;
  final String zeroRatedSales;
  final String grossAmount;
  final String lessDiscount;
  final String lessVoid;
  final String lessVatAdjust;
  final String netAmount;
  final String scDiscounts;
  final String pwdDiscounts;
  final String naacDiscounts;
  final String spDiscounts;
  final String otherDiscounts;
  final String voidAmount;
  final String returns;
  final String scAdjustments;
  final String pwdAdjustments;
  final String regDiscountAdjustments;
  final String zeroRatedAdjustments;
  final String vatOnReturn;
  final String otherVatAdjustments;
  final String cashInDrawer;
  final String gcashPayments;
  final String mayaPayments;
  final String debitPayments;
  final String creditPayments;
  final String openingFund;
  final String withdrawal;
  final String lessWithdrawal;
  final String paymentsReceived;
  final String shortOver;
  final String accumulatedSales;
  final String beginningOR;
  final String endingOR;
  final String beginningVoid;
  final String endingVoid;
  final String reportDate;
  final String reportTime;
  final int totalInvoices;

  ZReadingSummary({
    required this.startDate,
    required this.endDate,
    required this.presentAccumulatedSales,
    required this.previousAccumulatedSales,
    required this.salesForTheDay,
    required this.vatableSales,
    required this.vat,
    required this.vatExemptSales,
    required this.zeroRatedSales,
    required this.grossAmount,
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
    required this.beginningOR,
    required this.endingOR,
    required this.beginningVoid,
    required this.endingVoid,
    required this.reportDate,
    required this.reportTime,
    required this.totalInvoices,
  });

  factory ZReadingSummary.fromJson(Map<String, dynamic> json) {
    return ZReadingSummary(
      startDate: json["start_date"],
      endDate: json["end_date"],
      presentAccumulatedSales: json["present_accumulated_sales"],
      previousAccumulatedSales: json["previous_accumulated_sales"],
      salesForTheDay: json["sales_for_the_day"],
      vatableSales: json["vatable_sales"],
      vat: json["vat"],
      vatExemptSales: json["vat_exempt_sales"],
      zeroRatedSales: json["zero_rated_sales"],
      grossAmount: json["gross_amount"],
      lessDiscount: json["less_discount"],
      lessVoid: json["less_void"],
      lessVatAdjust: json["less_vat_adjust"],
      netAmount: json["net_amount"],
      scDiscounts: json["sc_discounts"],
      pwdDiscounts: json["pwd_discounts"],
      naacDiscounts: json["naac_discounts"],
      spDiscounts: json["sp_discounts"],
      otherDiscounts: json["other_discounts"],
      voidAmount: json["void"],
      returns: json["returns"],
      scAdjustments: json["sc_adjustments"],
      pwdAdjustments: json["pwd_adjustments"],
      regDiscountAdjustments: json["reg_discount_adjustments"],
      zeroRatedAdjustments: json["zero_rated_adjustments"],
      vatOnReturn: json["vat_on_return"],
      otherVatAdjustments: json["other_vat_adjustments"],
      cashInDrawer: json["cash_in_drawer"],
      gcashPayments: json["gcash_payments"],
      mayaPayments: json["maya_payments"],
      debitPayments: json["debit_payments"],
      creditPayments: json["credit_payments"],
      openingFund: json["opening_fund"],
      withdrawal: json["withdrawal"],
      lessWithdrawal: json["less_withdrawal"],
      paymentsReceived: json["payments_received"],
      shortOver: json["short_over"],
      accumulatedSales: json["accumulated_sales"],
      beginningOR: json["beginningOR"],
      endingOR: json["endingOR"],
      beginningVoid: json["beginningVoid"],
      endingVoid: json["endingVoid"],
      reportDate: json["report_date"],
      reportTime: json["report_time"],
      totalInvoices: json["total_invoices"],
    );
  }
}
