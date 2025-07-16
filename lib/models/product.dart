import 'dart:convert';

class Product {
  final int id;
  final String name;
  final double price;
  final double pax;
  final String image;
  final int productID;

  Product({
    required this.id,
    required this.productID,
    required this.name,
    required this.price,
    required this.pax,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      productID: json['product_id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      pax: double.parse(json['pax'].toString()),
      image: json['image_url'],
    );
  }

  static Map<String, dynamic> toMap(Product product) {
    return {
      'id': product.id,
      'product_id': product.productID,
      'name': product.name,
      'price': product.price,
      'pax': product.pax,
      'image_url': product.image,
    };
  }

  static String encode(Product product) {
    return json.encode(Product.toMap(product));
  }

  static String encodeList(List<Product> product) {
    return json.encode(
      product.map((product) => Product.toMap(product)).toList(),
    );
  }

  static Product decode(String product) {
    return Product.fromJson(json.decode(product) as Map<String, dynamic>);
  }

  static List<Product> decodeList(String product) {
    return (json.decode(product) as List<dynamic>)
        .map((product) => Product.fromJson(product as Map<String, dynamic>))
        .toList();
  }
}
