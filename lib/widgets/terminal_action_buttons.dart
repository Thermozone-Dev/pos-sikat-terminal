import 'dart:convert';

import 'package:bir_pos/models/zreading_summary.dart';
import 'package:bir_pos/services/claim_stub_service.dart';
import 'package:bir_pos/services/receipt_reprint_service.dart';
import 'package:bir_pos/services/transaction_reprint_service.dart';
import 'package:bir_pos/services/stub_print_service.dart';
import 'package:bir_pos/services/void_reprint_receipt_service.dart';
import 'package:bir_pos/services/void_reprint_service.dart';
import 'package:bir_pos/services/x_reprint_service.dart';
import 'package:bir_pos/services/xreading_reprint_service.dart';
import 'package:bir_pos/services/z_reprint_service.dart';
import 'package:bir_pos/services/zreading_reprint_print_service.dart';
import 'package:bir_pos/services/zreading_summary_print_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class TerminalActionButtons extends StatelessWidget {
  final ValueChanged setTransactionMethod;
  final VoidCallback processTransactions;
  final VoidCallback resetTransactionData;
  final VoidCallback toggleIsFirstPrint;

  final bool isFirstPrint;
  final bool isTransactionMethodSet;

  TerminalActionButtons({
    Key? key,
    required this.setTransactionMethod,
    required this.processTransactions,
    required this.resetTransactionData,
    required this.toggleIsFirstPrint,
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
              resetTransactionData();
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
          child: Text(
            isFirstPrint ? "Process Transaction" : "Reprint Receipt",
            style: const TextStyle(fontSize: 14),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final choice = await showDialog<int>(
              context: context,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SizedBox(
                    width: 420,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// HEADER
                          Row(
                            children: const [
                              Icon(Icons.print, size: 28),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Reprint Documents",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Select what you want to reprint",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// OPTIONS
                          _buildOption(
                            context,
                            icon: Icons.receipt_long,
                            title: "Receipt",
                            subtitle: "Reprint by Transaction ID",
                            value: 1,
                          ),

                          _buildOption(
                            context,
                            icon: Icons.cancel,
                            title: "Voided Receipt",
                            subtitle: "Reprint voided transactions",
                            value: 2,
                          ),

                          _buildOption(
                            context,
                            icon: Icons.bar_chart,
                            title: "X-Reading",
                            subtitle: "Daily cashier report",
                            value: 3,
                          ),

                          _buildOption(
                            context,
                            icon: Icons.assessment,
                            title: "Z-Reading",
                            subtitle: "End-of-day report",
                            value: 4,
                          ),

                          _buildOption(
                            context,
                            icon: Icons.summarize,
                            title: "Z-Reading Summary",
                            subtitle: "Date range summary",
                            value: 5,
                          ),

                          const SizedBox(height: 10),

                          /// CLOSE BUTTON
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Close"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );

            /// ================= EXISTING LOGIC =================

            if (choice == 1) {
              final id = await showDialog<int>(
                context: context,
                builder: (context) {
                  final controller = TextEditingController();

                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: const Text("Reprint by Transaction ID"),
                    content: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Enter Transaction ID",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          final enteredId = int.tryParse(controller.text);
                          if (enteredId != null) {
                            Navigator.pop(context, enteredId);
                          }
                        },
                        child: const Text("Fetch"),
                      ),
                    ],
                  );
                },
              );

              if (id != null) {
                try {
                  final transaction =
                      await TransactionReprintService.fetchTransaction(id);

                  await ReprintReceiptService().printReceipt(
                    transaction: transaction,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Transaction $id printed successfully!"),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            } else if (choice == 2) {
              final id = await showDialog<int>(
                context: context,
                builder: (context) {
                  final controller = TextEditingController();

                  return AlertDialog(
                    title: const Text("Reprint by Void ID"),
                    content: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Enter Void No / ID",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final enteredId = int.tryParse(controller.text);
                          if (enteredId != null) {
                            Navigator.pop(context, enteredId);
                          }
                        },
                        child: const Text("Fetch"),
                      ),
                    ],
                  );
                },
              );

              if (id != null) {
                try {
                  final transaction = await VoidReprintService.fetchTransaction(
                    id,
                  );

                  await ReprintVoidReceiptService().printReceipt(
                    transaction: transaction,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Transaction $id printed successfully!"),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            } else if (choice == 3) {
              final service = XReadingReprintService();

              final userIdController = TextEditingController();

              final userId = await showDialog<int>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Enter User ID"),
                    content: TextField(
                      controller: userIdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: "e.g. 2"),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final input = int.tryParse(
                            userIdController.text.trim(),
                          );
                          if (input != null) {
                            Navigator.pop(context, input);
                          }
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  );
                },
              );

              if (userId == null) return;

              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Colors.black87,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                      dialogBackgroundColor: Colors.white,
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate == null) return;

              final formattedDate =
                  "${pickedDate.year.toString().padLeft(4, '0')}-"
                  "${pickedDate.month.toString().padLeft(2, '0')}-"
                  "${pickedDate.day.toString().padLeft(2, '0')}";

              try {
                final report = await service.fetchXReadingReprint(
                  userId: userId,
                  date: formattedDate,
                );

                if (report != null) {
                  final reprintService = XReadingReceiptReprintService();
                  await reprintService.printReceipt(xReading: report);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "X-Reading reprint for $formattedDate printed successfully!",
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("No X-Reading found for $formattedDate"),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            } else if (choice == 4) {
              final service = ZReadingReprintService();
              final printerService = ZReadingReprintPrintService();

              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Colors.black87,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                      dialogBackgroundColor: Colors.white,
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate == null) return;

              final formattedDate =
                  "${pickedDate.year.toString().padLeft(4, '0')}-"
                  "${pickedDate.month.toString().padLeft(2, '0')}-"
                  "${pickedDate.day.toString().padLeft(2, '0')}";

              try {
                final report = await service.fetchReprint(formattedDate);

                if (report != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Reprint for $formattedDate fetched successfully!",
                      ),
                    ),
                  );

                  await printerService.printReceipt(zReading: report);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Z-Reading reprint sent to printer successfully!",
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("No Z-Reading found for $formattedDate"),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            } else if (choice == 5) {
              final pickedDateFrom = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Colors.blue,
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDateFrom == null) return;

              final pickedDateTo = await showDatePicker(
                context: context,
                initialDate: pickedDateFrom,
                firstDate: pickedDateFrom,
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Colors.blue,
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDateTo == null) return;

              final dateFrom = DateFormat('yyyy-MM-dd').format(pickedDateFrom);
              final dateTo = DateFormat('yyyy-MM-dd').format(pickedDateTo);

              try {
                final service = ZReadingReprintService();
                final summary = await service.fetchSummary(dateFrom, dateTo);

                if (summary != null) {
                  final printService = ZReadingSummaryPrintService();
                  await printService.printReceipt(zReading: summary);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Z-Reading Summary printed successfully"),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No Z-Reading Summary found")),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            } else if (choice != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Option $choice is not yet available.")),
              );
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

          child: const Text(
            "Reprint a Document",
            style: TextStyle(fontSize: 14),
          ),
        ),

        // ElevatedButton(
        //   onPressed: () => showClaimStubDialog(context),
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Colors.grey[300],
        //     foregroundColor: Colors.black,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        //   ),
        //   child: const Text('Claim Stub'),
        // ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required int value,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.pop(context, value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
