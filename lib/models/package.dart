import 'dart:convert';

class Package {
  final int id;
  final String name;
  final double price;
  final double pax;
  final String product_tax_category;
  final bool vat_exempt;
  final String image;
  final int packageID;

  Package({
    required this.id,
    required this.packageID,
    required this.name,
    required this.price,
    required this.pax,
    required this.product_tax_category,
    required this.vat_exempt,
    required this.image,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'],
      packageID: json['package_id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      pax: double.parse(json['pax'].toString()),
      product_tax_category: json['product_tax_category'],
      vat_exempt: json['vat_exempt'],
      image: json['image_url'],
    );
  }

  static Map<String, dynamic> toMap(Package package) {
    return {
      'id': package.id,
      'package_id': package.packageID,
      'name': package.name,
      'price': package.price,
      'pax': package.pax,
      'product_tax_category': package.product_tax_category,
      'vat_exempt': package.vat_exempt,
      'image_url': package.image,
    };
  }

  static String encode(Package package) {
    return json.encode(Package.toMap(package));
  }

  static String encodeList(List<Package> package) {
    return json.encode(
      package.map((package) => Package.toMap(package)).toList(),
    );
  }

  static Package decode(String package) {
    return Package.fromJson(json.decode(package) as Map<String, dynamic>);
  }

  static List<Package> decodeList(String package) {
    return (json.decode(package) as List<dynamic>)
        .map((package) => Package.fromJson(package as Map<String, dynamic>))
        .toList();
  }
}
