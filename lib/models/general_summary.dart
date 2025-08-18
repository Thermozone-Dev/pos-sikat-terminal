import 'dart:convert';

class GeneralSummary {
  final String name;
  final double price;
  final double quantity;
  final double total;

  GeneralSummary({
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
  });

  factory GeneralSummary.fromJson(Map<String, dynamic> json) {
    return GeneralSummary(
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      quantity: (json['qty'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }

  // Make this instance method
  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price, 'qty': quantity, 'total': total};
  }

  static String encode(GeneralSummary product) {
    return json.encode(product.toMap());
  }

  static String encodeList(List<GeneralSummary> products) {
    return json.encode(products.map((product) => product.toMap()).toList());
  }

  static GeneralSummary decode(String product) {
    return GeneralSummary.fromJson(
      json.decode(product) as Map<String, dynamic>,
    );
  }

  static List<GeneralSummary> decodeList(String products) {
    return (json.decode(products) as List<dynamic>)
        .map((item) => GeneralSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
