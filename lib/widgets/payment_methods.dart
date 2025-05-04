import 'package:bir_pos/models/payment_method.dart';
import 'package:bir_pos/services/payment_method_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PaymentMethodButtons extends StatelessWidget {
  final ValueChanged setTransactionMethod;

  const PaymentMethodButtons({Key? key, required this.setTransactionMethod})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final secStorage = FlutterSecureStorage();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: FutureBuilder<List<PaymentMethod>>(
        future: PaymentMethodService.getMethods(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No discounts found'));
          }

          final methods = snapshot.data!;

          return GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 20,
              mainAxisSpacing: 10,
              childAspectRatio: 1.4,
            ),
            itemCount: methods.length,
            itemBuilder: (context, index) {
              final method = methods[index];

              return AspectRatio(
                aspectRatio: 1,
                child: _buildButton(
                  label: method.name,
                  icon: method.isDigital ? Icons.credit_card : Icons.money,
                  color:
                      method.isDigital ? Colors.grey[300] : Colors.brown[500],
                  textColor: method.isDigital ? Colors.black : Colors.white,
                  onTap: () {
                    setTransactionMethod(method.id);
                    print('Payment Method: ${method.name}');
                  },
                ),
              );
            },
          );
        },
      ),
      //     const SizedBox(width: 10),
      //     _buildButton(
      //       label: 'GCash',
      //       color: Colors.blue[900],
      //       textColor: Colors.white,
      //       onTap: () => print('Payment Method: GCash'),
      //     ),
      //     const SizedBox(width: 10),
      //     _buildButton(
      //       label: 'Maya',
      //       color: Colors.black,
      //       textColor: Colors.green[300],
      //       onTap: () => print('Payment Method: Maya'),
      //     ),
      //   ],
      // ),
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
