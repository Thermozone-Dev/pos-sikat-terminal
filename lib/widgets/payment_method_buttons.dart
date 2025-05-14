import 'package:bir_pos/models/payment_method.dart';
import 'package:bir_pos/services/payment_method_service.dart';
import 'package:bir_pos/widgets/payment_method_form.dart';
import 'package:flutter/material.dart';

class PaymentMethodButtons extends StatelessWidget {
  final ValueChanged setTransactionMethod;
  final ValueChanged setCashTendered;
  final ValueChanged setTransactionFee;

  final Future<List<PaymentMethod>> futureTransactionMethods;

  const PaymentMethodButtons({
    Key? key,
    required this.futureTransactionMethods,
    required this.setTransactionMethod,
    required this.setCashTendered,
    required this.setTransactionFee,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: FutureBuilder<List<PaymentMethod>>(
        future: futureTransactionMethods,
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
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.4,
            ),
            itemCount: methods.length,
            itemBuilder: (context, index) {
              final method = methods[index];

              if (!method.isDigital) {
                return PaymentMethodForm(
                  isDigital: method.isDigital,
                  modalFunction: setCashTendered,
                  methodFunction: setTransactionMethod,
                  method: method,
                  label: method.name,
                  icon: method.isDigital ? Icons.credit_card : Icons.money,
                  color:
                      method.isDigital ? Colors.grey[300] : Colors.brown[500],
                  textColor: method.isDigital ? Colors.black : Colors.white,
                );
              } else {
                return PaymentMethodForm(
                  isDigital: method.isDigital,
                  modalFunction: setTransactionFee,
                  methodFunction: setTransactionMethod,
                  method: method,
                  label: method.name,
                  icon: method.isDigital ? Icons.credit_card : Icons.money,
                  color:
                      method.isDigital ? Colors.grey[300] : Colors.brown[500],
                  textColor: method.isDigital ? Colors.black : Colors.white,
                );
              }
            },
          );
        },
      ),
    );
  }
}
