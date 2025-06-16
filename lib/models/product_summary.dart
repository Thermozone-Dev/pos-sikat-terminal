import 'dart:convert';

class ProductSummary {
  final String name;
  final double price;
  final double quantity;
  final double total;

  ProductSummary({
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
  });

  factory ProductSummary.fromJson(Map<String, dynamic> json) {
    return ProductSummary(
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

  static String encode(ProductSummary product) {
    return json.encode(product.toMap());
  }

  static String encodeList(List<ProductSummary> products) {
    return json.encode(products.map((product) => product.toMap()).toList());
  }

  static ProductSummary decode(String product) {
    return ProductSummary.fromJson(
      json.decode(product) as Map<String, dynamic>,
    );
  }

  static List<ProductSummary> decodeList(String products) {
    return (json.decode(products) as List<dynamic>)
        .map((item) => ProductSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
