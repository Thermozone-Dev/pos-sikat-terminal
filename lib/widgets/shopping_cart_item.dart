import 'package:flutter/material.dart';
import 'package:bir_pos/widgets/shopping_cart_item_discount.dart';

class ShoppingCartItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final int index;

  final ValueChanged increaseQuantity;
  final ValueChanged decreaseQuantity;
  final ValueChanged addGovDiscountDetails;
  final ValueChanged addItemDiscount;
  final ValueChanged removeItem;
  final void Function(int index, int newQuantity) updateQuantity;

  const ShoppingCartItem({
    Key? key,
    required this.item,
    required this.index,
    required this.increaseQuantity,
    required this.decreaseQuantity,
    required this.addGovDiscountDetails,
    required this.addItemDiscount,
    required this.removeItem,
    required this.updateQuantity,
  }) : super(key: key);

  @override
  State<ShoppingCartItem> createState() => _ShoppingCartItemState();
}

class _ShoppingCartItemState extends State<ShoppingCartItem> {
  bool _isEditing = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.item['quantity'].toString(),
    );
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _submitQuantity();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitQuantity() {
    final newValue = int.tryParse(_controller.text);

    if (newValue != null && newValue > 0) {
      if (newValue != widget.item['quantity']) {
        widget.updateQuantity(widget.index, newValue);
      }
    } else {
      // Restore original if invalid input
      _controller.text = widget.item['quantity'].toString();
    }

    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Product info
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.item['data']['image_url'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (widget.item['data']['name'] as String).length > 10
                      ? '${widget.item['data']['name'].substring(0, 10)}...'
                      : widget.item['data']['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  widget.item['data']['price'].toString(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D7C66),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Quantity & Actions
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle),
              onPressed: () => widget.decreaseQuantity(widget.index),
            ),

            // Editable quantity
            GestureDetector(
              onTap: () {
                setState(() {
                  _isEditing = true;
                  _focusNode.requestFocus();
                });
              },
              child:
                  _isEditing
                      ? SizedBox(
                        width: 40,
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onSubmitted: (_) => _submitQuantity(),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 6),
                          ),
                        ),
                      )
                      : Text(
                        widget.item['quantity'].toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
            ),

            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: () => widget.increaseQuantity(widget.index),
            ),

            ShoppingCartItemDiscount(
              index: widget.index,
              item: widget.item,
              addGovDiscountDetails: widget.addGovDiscountDetails,
              addItemDiscount: widget.addItemDiscount,
            ),

            IconButton(
              onPressed: () => widget.removeItem(widget.index),
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ],
    );
  }
}
