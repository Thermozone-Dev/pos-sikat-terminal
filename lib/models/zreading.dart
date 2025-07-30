class ZReading {
  final String reportDate;
  final String reportTime;
  final String startTime;
  final String endTime;
  final String beginningOR;
  final String endingOR;
  final String beginningVoid;
  final String endingVoid;
  final String beginningReturn;
  final String endingReturn;
  final int resetCounter;
  final String zCounter;
  final String presentAccumulated;
  final String previousAccumulated;
  final String salesForTheDay;
  final String vatableSales;
  final String vatAmount;
  final String vatExemptSales;
  final String zeroRatedSales;
  final String grossAmount;
  final String lessDiscounts;
  final String lessReturns;
  final String lessVoids;
  final String lessVATAdjustments;
  final String netAmount;
  final String scDiscounts;
  final String pwdDiscounts;
  final String nacDiscounts;
  final String soloparentDiscounts;
  final String otherDiscounts;
  final String totalVoids;
  final String totalReturns;
  final String scTransactionsVATAdjust;
  final String pwdTransactionsVATAdjust;
  final String regDiscountsVATAdjust;
  final String zeroRatedVATAdjust;
  final String returnVATAdjust;
  final String otherVATAdjust;
  final String cashInDrawer;
  final String digitalPayments;
  final String creditPayments;
  final String openingBalance;
  final String withdrawal;
  final String lessWithdrawal;
  final String totalPayments;
  final String shortOrOver;

  ZReading({
    required this.reportDate,
    required this.reportTime,
    required this.startTime,
    required this.endTime,
    required this.beginningOR,
    required this.endingOR,
    required this.beginningVoid,
    required this.endingVoid,
    required this.beginningReturn,
    required this.endingReturn,
    required this.resetCounter,
    required this.zCounter,
    required this.presentAccumulated,
    required this.previousAccumulated,
    required this.salesForTheDay,
    required this.vatableSales,
    required this.vatAmount,
    required this.vatExemptSales,
    required this.zeroRatedSales,
    required this.grossAmount,
    required this.lessDiscounts,
    required this.lessReturns,
    required this.lessVoids,
    required this.lessVATAdjustments,
    required this.netAmount,
    required this.scDiscounts,
    required this.pwdDiscounts,
    required this.nacDiscounts,
    required this.soloparentDiscounts,
    required this.otherDiscounts,
    required this.totalVoids,
    required this.totalReturns,
    required this.scTransactionsVATAdjust,
    required this.pwdTransactionsVATAdjust,
    required this.regDiscountsVATAdjust,
    required this.zeroRatedVATAdjust,
    required this.returnVATAdjust,
    required this.otherVATAdjust,
    required this.cashInDrawer,
    required this.digitalPayments,
    required this.creditPayments,
    required this.openingBalance,
    required this.withdrawal,
    required this.lessWithdrawal,
    required this.totalPayments,
    required this.shortOrOver,
  });

  factory ZReading.fromJson(Map<String, dynamic> json) {
    return ZReading(
      reportDate: json['reportDate'],
      reportTime: json['reportTime'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      beginningOR: json['beginningOR'],
      endingOR: json['endingOR'],
      beginningVoid: json['beginningVoid'],
      endingVoid: json['endingVoid'],
      beginningReturn: json['beginningReturn'],
      endingReturn: json['endingReturn'],
      resetCounter: json['resetCounter'],
      zCounter: json['zCounter'],
      presentAccumulated: json['presentAccumulated'],
      previousAccumulated: json['previousAccumulated'],
      salesForTheDay: json['salesForTheDay'],
      vatableSales: json['vatableSales'],
      vatAmount: json['vatAmount'],
      vatExemptSales: json['vatExemptSales'],
      zeroRatedSales: json['zeroRatedSales'],
      grossAmount: json['grossAmount'],
      lessDiscounts: json['lessDiscounts'],
      lessReturns: json['lessReturns'],
      lessVoids: json['lessVoids'],
      lessVATAdjustments: json['lessVATAdjustments'],
      netAmount: json['netAmount'],
      scDiscounts: json['scDiscounts'],
      pwdDiscounts: json['pwdDiscounts'],
      nacDiscounts: json['nacDiscounts'],
      soloparentDiscounts: json['soloparentDiscounts'],
      otherDiscounts: json['otherDiscounts'],
      totalVoids: json['totalVoids'],
      totalReturns: json['totalReturns'],
      scTransactionsVATAdjust: json['scTransactionsVATAdjust'],
      pwdTransactionsVATAdjust: json['pwdTransactionsVATAdjust'],
      regDiscountsVATAdjust: json['regDiscountsVATAdjust'],
      zeroRatedVATAdjust: json['zeroRatedVATAdjust'],
      returnVATAdjust: json['returnVATAdjust'],
      otherVATAdjust: json['otherVATAdjust'],
      cashInDrawer: json['cashInDrawer'],
      digitalPayments: json['digitalPayments'],
      creditPayments: json['creditPayments'],
      openingBalance: json['openingBalance'],
      withdrawal: json['withdrawal'],
      lessWithdrawal: json['lessWithdrawal'],
      totalPayments: json['totalPayments'],
      shortOrOver: json['shortOrOver'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportDate': reportDate,
      'reportTime': reportTime,
      'startTime': startTime,
      'endTime': endTime,
      'beginningOR': beginningOR,
      'endingOR': endingOR,
      'beginningVoid': beginningVoid,
      'endingVoid': endingVoid,
      'beginningReturn': beginningReturn,
      'endingReturn': endingReturn,
      'resetCounter': resetCounter,
      'zCounter': zCounter,
      'presentAccumulated': presentAccumulated,
      'previousAccumulated': previousAccumulated,
      'salesForTheDay': salesForTheDay,
      'vatableSales': vatableSales,
      'vatAmount': vatAmount,
      'vatExemptSales': vatExemptSales,
      'zeroRatedSales': zeroRatedSales,
      'grossAmount': grossAmount,
      'lessDiscounts': lessDiscounts,
      'lessReturns': lessReturns,
      'lessVoids': lessVoids,
      'lessVATAdjustments': lessVATAdjustments,
      'netAmount': netAmount,
      'scDiscounts': scDiscounts,
      'pwdDiscounts': pwdDiscounts,
      'nacDiscounts': nacDiscounts,
      'soloparentDiscounts': soloparentDiscounts,
      'otherDiscounts': otherDiscounts,
      'totalVoids': totalVoids,
      'totalReturns': totalReturns,
      'scTransactionsVATAdjust': scTransactionsVATAdjust,
      'pwdTransactionsVATAdjust': pwdTransactionsVATAdjust,
      'regDiscountsVATAdjust': regDiscountsVATAdjust,
      'zeroRatedVATAdjust': zeroRatedVATAdjust,
      'returnVATAdjust': returnVATAdjust,
      'otherVATAdjust': otherVATAdjust,
      'cashInDrawer': cashInDrawer,
      'digitalPayments': digitalPayments,
      'creditPayments': creditPayments,
      'openingBalance': openingBalance,
      'withdrawal': withdrawal,
      'lessWithdrawal': lessWithdrawal,
      'totalPayments': totalPayments,
      'shortOrOver': shortOrOver,
    };
  }
}
