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
      price: double.parse(json['price'].toString()),
      quantity: double.parse(json['qty'].toString()),
      total: double.parse(json['total'].toString()),
    );
  }

  static Map<String, dynamic> toMap(ProductSummary product) {
    return {
      'name': product.name,
      'price': product.price,
      'quantity': product.quantity,
      'total': product.total,
    };
  }

  static String encode(ProductSummary product) {
    return json.encode(ProductSummary.toMap(product));
  }

  static String encodeList(List<ProductSummary> product) {
    return json.encode(
      product.map((product) => ProductSummary.toMap(product)).toList(),
    );
  }

  static ProductSummary decode(String product) {
    return ProductSummary.fromJson(
      json.decode(product) as Map<String, dynamic>,
    );
  }

  static List<ProductSummary> decodeList(String product) {
    return (json.decode(product) as List<dynamic>)
        .map(
          (product) => ProductSummary.fromJson(product as Map<String, dynamic>),
        )
        .toList();
  }
}
