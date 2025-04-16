class Package {
  final int id;
  final String name;
  final double price;
  final String image;
  final int packageID;

  Package({
    required this.id,
    required this.packageID,
    required this.name,
    required this.price,
    required this.image,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'],
      packageID: json['package_id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      image: json['image_url'],
    );
  }
}
