import 'package:bir_pos/models/discount.dart';
import 'package:bir_pos/services/discount_service.dart';
import 'package:bir_pos/widgets/item_discount_form.dart';
import 'package:bir_pos/widgets/discount_info_form.dart';
import 'package:flutter/material.dart';

class ShoppingCartItemDiscount extends StatefulWidget {
  final int index;
  final Map<String, dynamic> item;

  final ValueChanged addGovDiscountDetails;
  final ValueChanged addItemDiscount;

  const ShoppingCartItemDiscount({
    Key? key,
    required this.index,
    required this.item,
    required this.addGovDiscountDetails,
    required this.addItemDiscount,
  }) : super(key: key);

  @override
  State<ShoppingCartItemDiscount> createState() =>
      _ShoppingCartItemDiscountState();
}

class _ShoppingCartItemDiscountState extends State<ShoppingCartItemDiscount> {
  int selectedDiscount = 0;
  double selectedDisountValue = 0;
  bool selectedDiscountIsPercentage = false;

  int quantitySelected = 0;
  dynamic discounts;

  void setSelectedDiscount(value) {
    setState(() {
      selectedDiscount = value.id;
      selectedDisountValue = value.value;
      selectedDiscountIsPercentage = value.isPercentage;
    });
  }

  void setQuantitySelected(value) {
    setState(() {
      quantitySelected = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.discount),
      onPressed: () => _discountDialogBuilder(context),
      tooltip: 'Add Discount',
    );
  }

  void _discountDialogBuilder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Discount'),
          scrollable: true,
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder<List<Discount>>(
              future: DiscountService.getDiscounts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No discounts found'));
                }

                final discounts = snapshot.data!;

                return ItemDiscountForm(
                  item: widget.item,
                  discounts: discounts,
                  selectedDiscount: selectedDiscount,
                  setSelectedDiscount: setSelectedDiscount,
                  setQuantitySelected: setQuantitySelected,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (selectedDiscount > 0 && selectedDiscount < 4) {
                  showDialog(
                    context: context,
                    builder:
                        (context) => DiscountInfoForm(
                          selectedDiscount: selectedDiscount,
                          addGovDiscountDetails: widget.addGovDiscountDetails,
                        ),
                  );
                  widget.addItemDiscount({
                    'index': widget.index,
                    'quantity': quantitySelected,
                    'discount_id': selectedDiscount,
                    'discount_value': selectedDisountValue,
                    'discount_is_percentage': selectedDiscountIsPercentage,
                    'context': context,
                  });
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
