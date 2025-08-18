import 'package:flutter/material.dart';

class Discount {
  final int id;
  final String name;
  final double value;
  final bool isPercentage;
  final bool isGov;

  Discount({
    required this.id,
    required this.name,
    required this.value,
    required this.isPercentage,
    required this.isGov,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id'],
      name: json['name'],
      value: (json['value'] as num).toDouble(),
      isPercentage: json['is_percentage'],
      isGov: json['is_government_discount'],
    );
  }
}
