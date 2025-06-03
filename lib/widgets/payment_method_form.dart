import 'package:bir_pos/models/payment_method.dart';
import 'package:bir_pos/widgets/terminal_menu_button.dart';
import 'package:flutter/material.dart';

class PaymentMethodForm extends StatefulWidget {
  final ValueChanged modalFunction;
  final ValueChanged methodFunction;

  final PaymentMethod method;
  final String label;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final bool isDigital;
  final double total;

  const PaymentMethodForm({
    Key? key,
    required this.modalFunction,
    required this.methodFunction,
    required this.method,
    required this.label,
    required this.color,
    required this.textColor,
    required this.isDigital,
    required this.total,
    this.icon,
  }) : super(key: key);

  @override
  State<PaymentMethodForm> createState() => _PaymentMethodFormState();
}

class _PaymentMethodFormState extends State<PaymentMethodForm> {
  final TextEditingController quantitySelectedController =
      TextEditingController();

  int? selectedDiscount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TerminalMenuButton(
        label: widget.label,
        icon: widget.icon,
        color: widget.color,
        textColor: widget.textColor,
        onTap:
            () => _paymentMethodDialogBuilder(
              context,
              widget.isDigital,
              widget.modalFunction,
              widget.methodFunction,
              widget.method,
              widget.total,
            ),
      ),
    );
  }
}

void _paymentMethodDialogBuilder(
  BuildContext context,
  isDigital,
  modalFunction,
  methodFunction,
  method,
  total,
) {
  final TextEditingController cashTenderedSelectedController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int? savedValue;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        key: _formKey,
        title: Text(isDigital ? 'Transaction Fee' : "Cash Tendered"),
        scrollable: true,
        content: Padding(
          padding: EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: cashTenderedSelectedController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText:
                        isDigital
                            ? 'Enter Transaction Fee'
                            : 'Enter Amount Tendered',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    final amount = int.tryParse(value);
                    if (amount == null || amount < 0) {
                      return 'Please enter a valid amount';
                    }
                    if (!isDigital && amount < total) {
                      return 'Amount must be greater than or equal to total';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    savedValue = int.parse(value);
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                methodFunction(method);
                modalFunction(savedValue);
                Navigator.of(context).pop();
              }
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}
