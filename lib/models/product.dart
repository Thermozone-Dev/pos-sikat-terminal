class Product {
  final int id;
  final String name;
  final double price;
  final String image;
  final int productID;

  Product({
    required this.id,
    required this.productID,
    required this.name,
    required this.price,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      productID: json['product_id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      image: json['image_url'],
    );
  }
}
