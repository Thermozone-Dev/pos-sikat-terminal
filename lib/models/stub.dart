class Stub {
  final int id;
  final int transactionId;
  final int packageInclusiveId;
  final String stubNo;
  final int status;

  Stub({
    required this.id,
    required this.transactionId,
    required this.packageInclusiveId,
    required this.stubNo,
    required this.status,
  });

  factory Stub.fromJson(Map<String, dynamic> json) {
    return Stub(
      id: json['id'],
      transactionId: json['transaction_id'],
      packageInclusiveId: json['package_inclusive_id'],
      stubNo: json['stub_no'],
      status: json['status'],
    );
  }
}
