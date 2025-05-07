import 'package:flutter/material.dart';

class PaymentMethodForm extends StatefulWidget {
  final ValueChanged setCashTendered;

  const PaymentMethodForm({Key? key, required this.setCashTendered})
    : super(key: key);

  @override
  State<PaymentMethodForm> createState() => _PaymentMethodFormState();
}

class _PaymentMethodFormState extends State<PaymentMethodForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController quantitySelectedController =
      TextEditingController();

  int? selectedDiscount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(
        child: Text('Cash'),
        onPressed:
            () => _paymentMethodDialogBuilder(context, widget.setCashTendered),
      ),
    );
  }
}

void _paymentMethodDialogBuilder(BuildContext context, setCashTendered) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Cash Tendered'),
        scrollable: true,
        content: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Amount Tendered',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setCashTendered(int.parse(value)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}
