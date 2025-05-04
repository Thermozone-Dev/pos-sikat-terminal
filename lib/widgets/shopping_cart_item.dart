import 'package:flutter/material.dart';

class ShoppingCartItem extends StatelessWidget {
  final Map<String, dynamic> item;

  final ValueChanged increaseQuantity;
  final ValueChanged decreaseQuantity;

  const ShoppingCartItem({
    Key? key,
    required this.item,
    required this.increaseQuantity,
    required this.decreaseQuantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item['data']['image_url'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['data']['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  item['data']['price'].toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D7C66),
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle),
              onPressed: () => decreaseQuantity(item),
            ),
            Text(
              item['quantity'].toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle),
              onPressed: () => increaseQuantity(item),
            ),
            IconButton(
              icon: Icon(Icons.discount),
              onPressed: () {
                print("Assign Product Discount");
              },
            ),
          ],
        ),
      ],
    );
  }
}
