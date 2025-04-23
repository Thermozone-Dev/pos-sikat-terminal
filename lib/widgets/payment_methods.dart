import 'package:flutter/material.dart';

class PaymentMethodButtons extends StatelessWidget {
  const PaymentMethodButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildButton(
            label: 'Cash',
            icon: Icons.money,
            color: Colors.brown[500],
            textColor: Colors.white,
            onTap: () => print('Payment Method: Cash'),
          ),
          const SizedBox(width: 10),
          _buildButton(
            label: 'Debit',
            icon: Icons.credit_card,
            color: Colors.grey[300],
            textColor: Colors.black,
            onTap: () => print('Payment Method: Debit Card'),
          ),
          const SizedBox(width: 10),
          _buildButton(
            label: 'Credit',
            icon: Icons.credit_card,
            color: Colors.amber,
            textColor: Colors.black,
            onTap: () => print('Payment Method: Credit Card'),
          ),
          const SizedBox(width: 10),
          _buildButton(
            label: 'GCash',
            color: Colors.blue[900],
            textColor: Colors.white,
            onTap: () => print('Payment Method: GCash'),
          ),
          const SizedBox(width: 10),
          _buildButton(
            label: 'Maya',
            color: Colors.black,
            textColor: Colors.green[300],
            onTap: () => print('Payment Method: Maya'),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    IconData? icon,
    required Color? color,
    required Color? textColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            iconColor: textColor,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, color: textColor),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
