import 'package:flutter/material.dart';
import 'package:bir_pos/services/transaction_service.dart';

class TerminalActionButtons extends StatelessWidget {
  final ValueChanged setTransactionMethod;
  final VoidCallback processTransactions;
  final VoidCallback resetTransactionData;
  final VoidCallback toggleIsFirstPrint;

  bool isFirstPrint;

  TerminalActionButtons({
    Key? key,
    required this.setTransactionMethod,
    required this.processTransactions,
    required this.resetTransactionData,
    required this.toggleIsFirstPrint,
    required this.isFirstPrint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        ElevatedButton(
          onPressed: () {
            resetTransactionData();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Rounded rectangle
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          child: const Text(
            "Clear Transaction",
            style: TextStyle(fontSize: 14),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            if (isFirstPrint) {
              processTransactions();
              toggleIsFirstPrint();
              // Call the print function after processing the transaction
            } else {
              resetTransactionData();
              toggleIsFirstPrint();
              // Call the print function after resetting the transaction data
            }

            // Second Button is Reprinting the reciept then reset the Counter and Transaction Data

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
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          child: Text(
            isFirstPrint ? "Process Transaction" : "Reprint Receipt",
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
