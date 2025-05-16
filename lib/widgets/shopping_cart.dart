import 'package:bir_pos/services/cart_service.dart';
import 'package:bir_pos/widgets/shopping_cart_item.dart';
import 'package:flutter/material.dart';

class ShoppingCart extends StatelessWidget {
  final Map<String, dynamic> transactionData;

  final ValueChanged increaseQuantity;
  final ValueChanged decreaseQuantity;
  final ValueChanged addGovDiscountDetails;
  final ValueChanged addItemDiscount;
  final ValueChanged removeItem;

  const ShoppingCart({
    Key? key,
    required this.transactionData,
    required this.increaseQuantity,
    required this.decreaseQuantity,
    required this.addGovDiscountDetails,
    required this.addItemDiscount,
    required this.removeItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Container(
        padding: EdgeInsets.all(30),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 5,
              children: [
                Icon(Icons.shopping_bag),
                Text(
                  'ITEMS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),

            // Spacing & Border
            SizedBox(height: 10),

            Container(color: Colors.grey[300], height: 2),
            SizedBox(height: 30),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 0, 20),
                child: FutureBuilder<List<dynamic>>(
                  future: CartService.getCartItems(transactionData),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No products found'));
                    }

                    final items = snapshot.data!;

                    return ListView.separated(
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
                        );
                      },
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 10),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
