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
            // Handle reset action
            resetTransactionData();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            iconColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            "Clear Transaction",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: Colors.black),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            if (isFirstPrint) {
              processTransactions();
              //Print Transaction Receipt
              toggleIsFirstPrint();
            } else {
              //Print Transaction Receipt
              resetTransactionData();
              toggleIsFirstPrint();
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
            iconColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            isFirstPrint ? "Process Transaction" : "Reprint Receipt",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
