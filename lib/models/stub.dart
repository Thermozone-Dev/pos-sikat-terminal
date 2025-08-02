class Stub {
  final String date;
  final String time;
  final String processedBy;
  final String transactionNo;
  final String stubNo;
  final List<String> packageQuantities;
  final List<String> packageNames;
  final List<String> packagePrices;
  final List<String> inclusionName;
  final List<String> inclusionQuantity;

  Stub({
    required this.date,
    required this.time,
    required this.processedBy,
    required this.transactionNo,
    required this.stubNo,
    required this.packageQuantities,
    required this.packageNames,
    required this.packagePrices,
    required this.inclusionName,
    required this.inclusionQuantity,
  });

  factory Stub.fromJson(Map<String, dynamic> json) {
    return Stub(
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      processedBy: json['processedBy'] ?? '',
      transactionNo: json['transactionNo'] ?? '',
      stubNo: json['stubNo'] ?? '',
      packageQuantities: List<String>.from(json['packageQuantities'] ?? []),
      packageNames: List<String>.from(json['packageNames'] ?? []),
      packagePrices: List<String>.from(json['packagePrices'] ?? []),
      inclusionName: List<String>.from(json['inclusionName'] ?? []),
      inclusionQuantity: List<String>.from(json['inclusionQuantity'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time': time,
      'processedBy': processedBy,
      'transactionNo': transactionNo,
      'stubNo': stubNo,
      'packageQuantities': packageQuantities,
      'packageNames': packageNames,
      'packagePrices': packagePrices,
      'inclusionName': inclusionName,
      'inclusionQuantity': inclusionQuantity,
    };
  }
}
