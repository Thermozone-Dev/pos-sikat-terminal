import 'dart:convert';

import 'package:bir_pos/services/claim_stub_service.dart';
import 'package:bir_pos/services/stub_print_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TerminalActionButtons extends StatelessWidget {
  final ValueChanged setTransactionMethod;
  final VoidCallback processTransactions;
  final VoidCallback resetTransactionData;
  final VoidCallback toggleIsFirstPrint;
  final VoidCallback printReceipt;

  final bool isFirstPrint;
  final bool isTransactionMethodSet;

  TerminalActionButtons({
    Key? key,
    required this.setTransactionMethod,
    required this.processTransactions,
    required this.resetTransactionData,
    required this.toggleIsFirstPrint,
    required this.printReceipt,
    required this.isFirstPrint,
    required this.isTransactionMethodSet,
  }) : super(key: key);

  Future<void> showClaimStubDialog(BuildContext context) async {
    final TextEditingController _stubController = TextEditingController();
    Map<String, dynamic>? stubData;
    String? error;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> handleClaim() async {
              final stubNo = _stubController.text.trim();
              if (stubNo.isEmpty) return;

              final result = await claimStub(stubNo);
              if (result != null) {
                setState(() {
                  error = null;
                  stubData = result;
                });
              } else {
                setState(() {
                  error = 'Stub not found or network error.';
                  stubData = null;
                });
              }
            }

            return AlertDialog(
              title: const Text(
                'Claim Stub',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _stubController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Stub No',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (error != null)
                      Text(error!, style: const TextStyle(color: Colors.red)),
                    if (stubData != null) ...[
                      const Divider(),
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            const TextSpan(text: 'Date: '),
                            TextSpan(
                              text: stubData!['date'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            const TextSpan(text: 'Time: '),
                            TextSpan(
                              text: stubData!['time'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            const TextSpan(text: 'Transaction #: '),
                            TextSpan(
                              text: '${stubData!['transaction_no']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            const TextSpan(text: 'Stub #: '),
                            TextSpan(
                              text: stubData!['stub'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            const TextSpan(text: 'Package: '),
                            TextSpan(
                              text: stubData!['pack_inclusive_name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            const TextSpan(text: 'Quantity: '),
                            TextSpan(
                              text: stubData!['quantity'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: [
                            const TextSpan(text: 'Price: ₱'),
                            TextSpan(
                              text: '${stubData!['price']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Item Inclusions:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      for (var item in stubData!['items'])
                        Text('  - ${item['quantity']} x ${item['name']}'),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed:
                      stubData == null
                          ? handleClaim
                          : () async {
                            await StubPrintService().printStub(stubData!);
                          },
                  child: Text(stubData == null ? 'Verify' : 'Print'),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
            if (!isTransactionMethodSet) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please set a transaction method first.'),
                ),
              );
              return;
            }
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
          onPressed: () => showClaimStubDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          child: const Text('Claim Stub'),
        ),
        // ElevatedButton(
        //   onPressed: () async {
        //     String? stubNumber;

        //     await showDialog(
        //       context: context,
        //       builder: (context) {
        //         final TextEditingController controller =
        //             TextEditingController();

        //         return AlertDialog(
        //           title: const Text('Enter Stub Number'),
        //           content: TextField(
        //             controller: controller,
        //             keyboardType: TextInputType.number,
        //             decoration: const InputDecoration(
        //               hintText: 'Stub Number',
        //               border: OutlineInputBorder(),
        //             ),
        //           ),
        //           actions: [
        //             TextButton(
        //               onPressed: () {
        //                 Navigator.of(context).pop();
        //               },
        //               child: const Text('Cancel'),
        //             ),
        //             ElevatedButton(
        //               onPressed: () async {
        //                 stubNumber = controller.text.trim();

        //                 if (stubNumber == null || stubNumber!.isEmpty) return;

        //                 // Call the API
        //                 final result = await claimStub(stubNumber!);

        //                 Navigator.of(context).pop(); // Close the dialog

        //                 if (result != null) {
        //                   // Optionally call print service with result
        //                   await StubPrintService().printStub(result);

        //                   // Show success message
        //                   ScaffoldMessenger.of(context).showSnackBar(
        //                     SnackBar(
        //                       content: Text('Stub claimed successfully!'),
        //                     ),
        //                   );
        //                 } else {
        //                   ScaffoldMessenger.of(context).showSnackBar(
        //                     SnackBar(
        //                       content: Text(
        //                         'Stub not found or failed to claim.',
        //                       ),
        //                     ),
        //                   );
        //                 }
        //               },
        //               child: const Text('Submit'),
        //             ),
        //           ],
        //         );
        //       },
        //     );
        //   },
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Colors.grey[300],
        //     foregroundColor: Colors.black,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        //   ),
        //   child: const Text("Claim Stub", style: TextStyle(fontSize: 14)),
        // ),
      ],
    );
  }
}
