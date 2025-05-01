import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/package.dart';

class PackageCard extends StatelessWidget {
  final Package package;
  final VoidCallback? onPressed;

  const PackageCard({super.key, required this.package, this.onPressed});

  _selectPackage(Package package) async {
    final secStorage = FlutterSecureStorage();
    final String? data = await secStorage.read(key: 'transaction_data');

    final Map<String, dynamic> dataList = data == null ? {} : json.decode(data);

    Map<String, dynamic> tmpItems = dataList.isEmpty ? {} : dataList['items'];

    if (tmpItems.containsKey(package.id.toString())) {
      tmpItems[package.id.toString()]['quantity'] += 1;
    } else {
      tmpItems[package.id.toString()] = {
        'data': Package.encode(package),
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
            _selectPackage(package);
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
