class Customer {
  final int transactionID;
  final String name;
  final String id;

  Customer({required this.transactionID, required this.name, required this.id});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      transactionID: json['transaction_id'] ?? 'N/A',
      name: json['name'] ?? 'N/A',
      id: json['id'] ?? 'N/A',
    );
  }
}
