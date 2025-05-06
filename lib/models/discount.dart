class Discount {
  final int id;
  final String name;
  final double value;
  final bool isPercentage;

  Discount({
    required this.id,
    required this.name,
    required this.value,
    required this.isPercentage,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id'],
      name: json['name'],
      value: (json['value'] as num).toDouble(),
      isPercentage: json['is_percentage'] == 1,
    );
  }
}
