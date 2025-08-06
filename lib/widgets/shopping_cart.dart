import 'package:bir_pos/services/cart_service.dart';
import 'package:bir_pos/widgets/shopping_cart_item.dart';
import 'package:flutter/material.dart';

class ShoppingCart extends StatefulWidget {
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
  State<ShoppingCart> createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  List<dynamic> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await CartService.getCartItems(widget.transactionData);
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void updateCartQuantity(int index, int newQty) {
    setState(() {
      _items[index]['quantity'] = newQty;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                        ? Center(child: Text('Error: $_error'))
                        : _items.isEmpty
                        ? const Center(child: Text('No products found'))
                        : ListView.separated(
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return ShoppingCartItem(
                              index: index,
                              item: item,
                              increaseQuantity: widget.increaseQuantity,
                              decreaseQuantity: widget.decreaseQuantity,
                              addGovDiscountDetails:
                                  widget.addGovDiscountDetails,
                              addItemDiscount: widget.addItemDiscount,
                              removeItem: widget.removeItem,
                              updateQuantity: updateCartQuantity,
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
