import 'package:bir_pos/widgets/shopping_cart_item.dart';
import 'package:flutter/material.dart';

class ShoppingCart extends StatelessWidget {
  final Map<String, dynamic> transactionData;

  final ValueChanged increaseQuantity;
  final ValueChanged decreaseQuantity;
  final ValueChanged addGovDiscountDetails;
  final ValueChanged addItemDiscount;
  final ValueChanged removeItem;
  final void Function(int index, int newQuantity) updateQuantity;

  const ShoppingCart({
    Key? key,
    required this.transactionData,
    required this.increaseQuantity,
    required this.decreaseQuantity,
    required this.addGovDiscountDetails,
    required this.addItemDiscount,
    required this.removeItem,
    required this.updateQuantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = transactionData['items'] ?? [];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Container(
        padding: const EdgeInsets.all(30),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: const [
                Icon(Icons.shopping_bag),
                SizedBox(width: 5),
                Text(
                  'ITEMS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(color: Colors.grey[300], height: 2),
            const SizedBox(height: 30),

            // Item List
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 0, 20),
                child:
                    items.isEmpty
                        ? const Center(child: Text('No products found'))
                        : ListView.separated(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ShoppingCartItem(
                              index: index,
                              item: item,
                              increaseQuantity: increaseQuantity,
                              decreaseQuantity: decreaseQuantity,
                              addGovDiscountDetails: addGovDiscountDetails,
                              addItemDiscount: addItemDiscount,
                              removeItem: removeItem,
                              updateQuantity: updateQuantity,
                            );
                          },
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 10),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
