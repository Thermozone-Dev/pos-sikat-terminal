import 'package:bir_pos/models/payment_method.dart';
import 'package:bir_pos/services/payment_method_service.dart';
import 'package:bir_pos/widgets/payment_method_form.dart';
import 'package:flutter/material.dart';

class PaymentMethodButtons extends StatelessWidget {
  final ValueChanged setTransactionMethod;
  final ValueChanged setCashTendered;
  final ValueChanged setTransactionFee;

  final double total;

  // final Future<List<PaymentMethod>> futureTransactionMethods;

  const PaymentMethodButtons({
    Key? key,
    // required this.futureTransactionMethods,
    required this.setTransactionMethod,
    required this.setCashTendered,
    required this.setTransactionFee,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: FutureBuilder<List<PaymentMethod>>(
        future: PaymentMethodService.getMethods(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No payment methods found'));
          }

          final methods = snapshot.data!;

          return Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: methods.length,
                  itemBuilder: (context, index) {
                    final method = methods[index];

                    return PaymentMethodForm(
                      isDigital: method.isDigital,
                      total: total,
                      modalFunction:
                          method.isDigital
                              ? setTransactionFee
                              : setCashTendered,
                      methodFunction: setTransactionMethod,
                      method: method,
                      label: method.name,
                      icon: method.isDigital ? Icons.credit_card : Icons.money,
                      color:
                          method.isDigital
                              ? Colors.grey[300]
                              : Colors.brown[500],
                      textColor: method.isDigital ? Colors.black : Colors.white,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
