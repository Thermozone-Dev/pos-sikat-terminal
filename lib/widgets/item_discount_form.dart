import 'package:flutter/material.dart';
import 'package:bir_pos/models/discount.dart';
import 'package:flutter/services.dart';

class ItemDiscountForm extends StatefulWidget {
  final Map<String, dynamic> item;
  final List<Discount> discounts;

  final int selectedDiscount;

  final ValueChanged setSelectedDiscount;
  final ValueChanged setQuantitySelected;

  const ItemDiscountForm({
    Key? key,
    required this.item,
    required this.discounts,
    required this.selectedDiscount,
    required this.setSelectedDiscount,
    required this.setQuantitySelected,
  }) : super(key: key);

  @override
  State<ItemDiscountForm> createState() => _ItemDiscountFormState();
}

class _ItemDiscountFormState extends State<ItemDiscountForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController quantitySelectedController =
      TextEditingController();

  int? selectedDiscount;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField(
            items:
                widget.discounts.map((discount) {
                  return DropdownMenuItem(
                    value: discount,
                    child: Text(discount.name),
                  );
                }).toList(),
            onChanged: (value) {
              widget.setSelectedDiscount(value);
            },
            decoration: InputDecoration(
              labelText: 'Select Discount',
              border: OutlineInputBorder(),
            ),
          ),
          TextFormField(
            controller: quantitySelectedController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Item Amount',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (int.parse(((value.isEmpty) ? '00' : (value))) >
                  widget.item['quantity']) {
                quantitySelectedController.text =
                    widget.item['quantity'].toString();
              }
              quantitySelectedController.value = TextEditingValue(
                text: quantitySelectedController.text,
                selection: TextSelection.fromPosition(
                  TextPosition(offset: quantitySelectedController.text.length),
                ),
              );

              widget.setQuantitySelected(
                int.tryParse(quantitySelectedController.text),
              );
            },
          ),
        ],
      ),
    );
  }
}
