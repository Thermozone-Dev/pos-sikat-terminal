import 'dart:ffi';

import 'package:bir_pos/models/xreading.dart';
import 'package:bir_pos/models/zreading.dart';
import 'package:bir_pos/services/report_service.dart';
import 'package:bir_pos/services/shift_service.dart';
import 'package:bir_pos/services/summary_print_service.dart';
import 'package:bir_pos/services/x_print_service.dart';
import 'package:bir_pos/services/z_print_service.dart';
import 'package:bir_pos/services/zreading_service.dart';
import 'package:bir_pos/terminal.dart';
import 'package:bir_pos/void.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'package:bir_pos/services/xreading_service.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  Future<void> showEndingBalanceModal(
    BuildContext context,
    Future<void> Function(String) onSubmit,
  ) async {
    final TextEditingController controller = TextEditingController();
    String userInput = '';

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Enter Ending Balance'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(hintText: 'e.g., 100.00'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  userInput = controller.text;
                  Navigator.pop(context);
                },
                child: Text('Submit'),
              ),
            ],
          ),
    );

    if (userInput.isNotEmpty) {
      await onSubmit(userInput);
    }
  }

  Future<void> showCurrentXCashModal(
    BuildContext context,
    Future<void> Function(String) onSubmit,
  ) async {
    final TextEditingController controller = TextEditingController();
    double currentCash = 0.0;

    Future<void> onSubmit(double currentCash) async {
      final XReading? data = await XReadingService().fetchXReading(currentCash);
      // print('Current Cash: $currentCash');
      final printerService = XReadingPrintService();
      await printerService.printReceipt(xReading: data);
      // print(data);
    }

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Enter Current Cash on Drawer'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(hintText: 'e.g., 1000.00'),
              onChanged: (value) {
                currentCash = double.tryParse(value) ?? 0.0;
              },
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  onSubmit(currentCash);
                  Navigator.pop(context);
                },
                child: Text('Submit'),
              ),
            ],
          ),
    );
  }

  Future<void> showCurrentZCashModal(
    BuildContext context,
    Future<void> Function(String) onSubmit,
  ) async {
    final TextEditingController controller = TextEditingController();
    double currentCash = 0.0;

    Future<void> onSubmit(double currentCash) async {
      final ZReading? data = await ZReadingService().fetchZReading(currentCash);
      // print('Current Cash: $currentCash');
      final printerService = ZReadingPrintService();
      await printerService.printReceipt(zReading: data);
      // print(data);
    }

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Enter Current Cash on Drawer'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(hintText: 'e.g., 1000.00'),
              onChanged: (value) {
                currentCash = double.tryParse(value) ?? 0.0;
              },
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  onSubmit(currentCash);
                  Navigator.pop(context);
                },
                child: Text('Submit'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.brown[500]),
            child: Center(child: Image.asset('assets/img/banner-dark.png')),
          ),
          // Terminal
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.black),
            title: const Text(
              'Terminal',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final token = prefs.getString('token');

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Terminal(token: token)),
              );
            },
          ),
          // Summary Report
          ListTile(
            leading: const Icon(Icons.print, color: Colors.black),
            title: const Text(
              'Summary Report',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              // Close the drawer first
              Navigator.pop(context);

              // Delay the dialog slightly so it opens AFTER the drawer closes
              Future.delayed(const Duration(milliseconds: 200), () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Summary Report'),
                        content: const Text('This is the modal content.'),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              try {
                                final products =
                                    await ReportService.dailyProductSummary();
                                final printerService = SummaryPrintService();
                                await printerService.printReceipt(
                                  products: products,
                                );
                                if (context.mounted) Navigator.pop(context);
                              } catch (error) {
                                print('Error fetching summary report: $error');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $error')),
                                  );
                                }
                              }
                            },
                            child: const Text('Print'),
                          ),
                        ],
                      ),
                );
              });
            },
          ),
          // X Reading
          ListTile(
            leading: const Icon(Icons.print, color: Colors.black),
            title: const Text(
              'X-Reading',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () async {
              await showCurrentXCashModal(
                context,
                (String currentCash) async {},
              );
              // final printerService = XReadingPrintService();
              // await printerService.printReceipt();
              Navigator.pop(context);
            },
          ),
          // Z-Reading
          ListTile(
            leading: const Icon(Icons.print, color: Colors.black),
            title: const Text(
              'Z-Reading',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () async {
              await showCurrentZCashModal(
                context,
                (String currentCash) async {},
              );
              // final printerService = ZReadingPrintService();
              // await printerService.printReceipt();
              Navigator.pop(context);
            },
          ),
          // Voiding
          ListTile(
            leading: const Icon(Icons.cancel, color: Colors.black),
            title: const Text(
              'Voiding',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () async {
              Navigator.pop(context);
              final TextEditingController codeController =
                  TextEditingController();
              const String correctCode = 'idolkim';

              showDialog(
                context: context,
                barrierColor: Colors.black54,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Enter Manager\'s Code'),
                    content: TextField(
                      controller: codeController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Access Code',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final code = codeController.text.trim();
                          Navigator.pop(context);

                          if (code == correctCode) {
                            showDialog(
                              context: context,
                              barrierColor: Colors.black54,
                              builder:
                                  (_) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.all(20),
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2B2B2B),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 40,
                                            vertical: 40,
                                          ),
                                          child:
                                              VoidTransactionForm(), // your form widget
                                        ),
                                      ),
                                    ),
                                  ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Incorrect access code'),
                              ),
                            );
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          // End Shift
          ListTile(
            title: const Text(
              'End Shift',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            leading: Icon(Icons.logout),
            onTap: () async {
              await showEndingBalanceModal(context, (
                String endingBalance,
              ) async {
                await endShift(endingBalance);
              });
            },
          ),
          // Sign Out
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.black),
            title: const Text(
              'Sign Out',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () => AuthService.signOut(context),
          ),
        ],
      ),
    );
  }
}
