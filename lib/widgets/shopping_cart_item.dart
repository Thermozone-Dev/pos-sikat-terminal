import 'package:bir_pos/services/cart_service.dart';
import 'package:bir_pos/widgets/shopping_cart_item_discount.dart';
import 'package:flutter/material.dart';

class ShoppingCartItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;

  final ValueChanged increaseQuantity;
  final ValueChanged decreaseQuantity;
  final ValueChanged addGovDiscountDetails;
  final ValueChanged addItemDiscount;
  final ValueChanged removeItem;

  const ShoppingCartItem({
    Key? key,
    required this.item,
    required this.index,
    required this.increaseQuantity,
    required this.decreaseQuantity,
    required this.addGovDiscountDetails,
    required this.addItemDiscount,
    required this.removeItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item['data']['image_url'],
                width: 50,
                height: 50,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  item['data']['price'].toString(),
                  style: TextStyle(
                    fontSize: 13,
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
              onPressed: () => decreaseQuantity(index),
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
              onPressed: () => increaseQuantity(index),
            ),
            ShoppingCartItemDiscount(
              index: index,
              item: item,
              addGovDiscountDetails: addGovDiscountDetails,
              addItemDiscount: addItemDiscount,
            ),
            IconButton(
              onPressed: () => removeItem(index),
              icon: Icon(Icons.delete),
            ),
          ],
        ),
      ],
    );
  }
}
