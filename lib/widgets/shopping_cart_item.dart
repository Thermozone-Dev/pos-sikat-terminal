import 'package:bir_pos/widgets/shopping_cart_item_discount.dart';
import 'package:flutter/material.dart';

class ShoppingCartItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;

  final ValueChanged increaseQuantity;
  final ValueChanged decreaseQuantity;
  final ValueChanged addGovDiscountDetails;
  final ValueChanged addItemDiscount;

  const ShoppingCartItem({
    Key? key,
    required this.item,
    required this.index,
    required this.increaseQuantity,
    required this.decreaseQuantity,
    required this.addGovDiscountDetails,
    required this.addItemDiscount,
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
            ShoppingCartItemDiscount(
              index: index,
              item: item,
              addGovDiscountDetails: addGovDiscountDetails,
              addItemDiscount: addItemDiscount,
            ),
          ],
        ),
      ],
    );
  }
}
