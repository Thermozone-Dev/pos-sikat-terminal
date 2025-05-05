import 'package:flutter/material.dart';
import 'package:bir_pos/widgets/payment_methods.dart';
import 'package:bir_pos/widgets/discounts.dart';
import '../print_service.dart';

class TransactionActions extends StatelessWidget {
  final ValueChanged setTransactionMethod;
  final VoidCallback processTransactions;

  const TransactionActions({
    Key? key,
    required this.setTransactionMethod,
    required this.processTransactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: DefaultTabController(
        length: 3, // Number of tabs
        child: Column(
          children: [
            // TabBar at the top
            const TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.brown,
              tabs: [
                Tab(text: 'Discounts'),
                Tab(text: 'Payment Method'),
                Tab(text: 'Actions'),
              ],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                children: [
                  // Discounts Tab
                  DiscountSelector(),

                  // Payment Methods Tab
                  PaymentMethodButtons(
                    setTransactionMethod: setTransactionMethod,
                  ),

                  // Actions Tab
                  ElevatedButton(
                    onPressed: () async {
                      processTransactions();
                      // final printerService = PrinterService();

                      // // Sample receipt data
                      // final items = [
                      //   {'name': 'Apple', 'quantity': '2', 'price': '\$1.00'},
                      //   {'name': 'Banana', 'quantity': '5', 'price': '\$2.50'},
                      // ];

                      // await printerService.printReceipt(
                      //   storeName: 'Thermozone Philippines Corp.',
                      //   storeAddress:
                      //       '2280 Marconi St., Brgy. San Isidro, Makati City',
                      //   storePhone: 'TIN: 223 661 818 0000',
                      //   items: items,
                      //   total: 3.50,
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      'Test Print',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),

                  SizedBox(width: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
