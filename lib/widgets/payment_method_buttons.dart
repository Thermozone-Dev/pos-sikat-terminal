import 'package:bir_pos/models/payment_method.dart';
import 'package:bir_pos/services/payment_method_service.dart';
import 'package:bir_pos/widgets/payment_method_form.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PaymentMethodButtons extends StatefulWidget {
  final ValueChanged setTransactionMethod;
  final ValueChanged setCashTendered;
  final ValueChanged setTransactionFee;
  final double total;

  const PaymentMethodButtons({
    Key? key,
    required this.setTransactionMethod,
    required this.setCashTendered,
    required this.setTransactionFee,
    required this.total,
  }) : super(key: key);

  @override
  State<PaymentMethodButtons> createState() => _PaymentMethodButtonsState();
}

class _PaymentMethodButtonsState extends State<PaymentMethodButtons> {
  late Future<List<PaymentMethod>> _futureMethods;

  @override
  void initState() {
    super.initState();
    _futureMethods = PaymentMethodService.getMethods();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: FutureBuilder<List<PaymentMethod>>(
        future: _futureMethods,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            Future.microtask(() async {
              if (context.mounted) {
                await showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text("Connection Lost"),
                        content: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Divider(),
                            Text(
                              "The application lost connection to the server. The app will now close.",
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                );

                Future.delayed(const Duration(milliseconds: 500), () {
                  exit(0);
                });
              }
            });

            return const SizedBox.shrink();
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
                      total: widget.total,
                      modalFunction:
                          method.isDigital
                              ? widget.setTransactionFee
                              : widget.setCashTendered,
                      methodFunction: widget.setTransactionMethod,
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
