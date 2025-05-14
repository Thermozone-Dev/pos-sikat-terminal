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

  const PaymentMethodForm({
    Key? key,
    required this.modalFunction,
    required this.methodFunction,
    required this.method,
    required this.label,
    required this.color,
    required this.textColor,
    required this.isDigital,
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
) {
  int? savedValue;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(isDigital ? 'Transaction Fee' : "Cash Tendered"),
        scrollable: true,
        content: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      isDigital
                          ? 'Enter Transaction Fee'
                          : 'Enter Amount Tendered',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  savedValue = int.parse(value);
                },
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
            onPressed: () {
              methodFunction(method);
              modalFunction(savedValue);
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}
