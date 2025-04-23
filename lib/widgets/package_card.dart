import 'package:flutter/material.dart';
import '../models/package.dart';

class PackageCard extends StatelessWidget {
  final Package package;
  final VoidCallback? onPressed;

  const PackageCard({super.key, required this.package, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:
          onPressed ??
          () {
            print("Product pressed: ${package.name}");
          },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              package.image,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            package.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          Text(
            '₱${package.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D7C66),
            ),
          ),
        ],
      ),
    );
  }
}
