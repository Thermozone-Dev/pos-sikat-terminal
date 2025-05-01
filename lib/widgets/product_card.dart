import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onPressed;

  const ProductCard({super.key, required this.product, this.onPressed});

  _selectProduct(Product product) async {
    final secStorage = FlutterSecureStorage();
    final String? data = await secStorage.read(key: 'transaction_data');

    final Map<String, dynamic> dataList = data == null ? {} : json.decode(data);

    Map<String, dynamic> tmpItems = dataList.isEmpty ? {} : dataList['items'];

    if (tmpItems.containsKey(product.id.toString())) {
      tmpItems[product.id.toString()]['quantity'] += 1;
    } else {
      tmpItems[product.id.toString()] = {
        'data': Product.encode(product),
        'quantity': 1,
      };
    }

    dataList['items'] = tmpItems;

    secStorage.write(key: 'transaction_data', value: json.encode(dataList));
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:
          onPressed ??
          () {
            _selectProduct(product);
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
              product.image,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          Text(
            '₱${product.price.toStringAsFixed(2)}',
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
