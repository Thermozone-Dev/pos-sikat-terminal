class PaymentMethod {
  final int id;
  final String name;
  final bool isDigital;
  final String? logoUrl;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.isDigital,
    this.logoUrl,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      name: json['name'],
      isDigital: json['is_digital'],
      logoUrl: json['logo_url'],
    );
  }
}
