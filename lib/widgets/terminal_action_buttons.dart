import 'package:bir_pos/services/stub_print_service.dart';
import 'package:flutter/material.dart';

class TerminalActionButtons extends StatelessWidget {
  final ValueChanged setTransactionMethod;
  final VoidCallback processTransactions;
  final VoidCallback resetTransactionData;
  final VoidCallback toggleIsFirstPrint;
  final VoidCallback printReceipt;

  final bool isFirstPrint;

  TerminalActionButtons({
    Key? key,
    required this.setTransactionMethod,
    required this.processTransactions,
    required this.resetTransactionData,
    required this.toggleIsFirstPrint,
    required this.printReceipt,
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
            } else {
              printReceipt();
              toggleIsFirstPrint();
              resetTransactionData();
            }

            // Second Button is Reprinting the reciept then reset the Counter and Transaction Data
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
        ElevatedButton(
          onPressed: () async {
            String? stubNumber;

            await showDialog(
              context: context,
              builder: (context) {
                final TextEditingController controller =
                    TextEditingController();

                return AlertDialog(
                  title: const Text('Enter Stub Number'),
                  content: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Stub Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        stubNumber = controller.text.trim();

                        // Optionally validate
                        if (stubNumber == null) return;

                        // Trigger print
                        await StubPrintService().printStub();

                        // Close the dialog after printing
                        Navigator.of(context).pop();
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                );
              },
            );

            if (stubNumber != null && stubNumber!.isNotEmpty) {
              // Do something with the stub number
              print("Stub Number: $stubNumber");
              // You can call a function or set state here
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          child: const Text("Claim Stub", style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}
