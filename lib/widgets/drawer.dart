import 'dart:convert';
import 'dart:io';
import 'package:bir_pos/services/void_print_service.dart';
import 'package:http/http.dart' as http;
import 'package:bir_pos/models/void_transaction.dart';
import 'package:bir_pos/models/xreading.dart';
import 'package:bir_pos/models/zreading.dart';
import 'package:bir_pos/services/general_report_service.dart';
import 'package:bir_pos/services/general_summary_print_service.dart';
import 'package:bir_pos/services/report_service.dart';
import 'package:bir_pos/services/shift_service.dart';
import 'package:bir_pos/services/summary_print_service.dart';
import 'package:bir_pos/services/x_print_service.dart';
import 'package:bir_pos/services/z_print_service.dart';
import 'package:bir_pos/services/zreading_service.dart';
import 'package:bir_pos/terminal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
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
          // Summary Report / Cashier
          ListTile(
            leading: const Icon(Icons.print, color: Colors.black),
            title: const Text(
              'Summary Report / Cashier',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () async {
              try {
                final products = await ReportService.dailyProductSummary();
                final now = DateTime.now();
                final formattedDate = DateFormat('MMMM d, y').format(now);
                final formattedTime = DateFormat('hh:mm a').format(now);

                Future.delayed(const Duration(milliseconds: 200), () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Summary Report',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 23,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Generated on $formattedDate at $formattedTime',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          titleTextStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                            color: Colors.black,
                          ),
                          content: SingleChildScrollView(
                            child: Container(
                              width: 600,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: const [
                                        Expanded(
                                          child: Text(
                                            'Product',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Price',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Quantity',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Total',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(),

                                  ...products.map((product) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(child: Text(product.name)),
                                          Expanded(
                                            child: Text(
                                              '₱${(product.price as double).toStringAsFixed(2)}',
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '${(product.quantity).toStringAsFixed(0)}',
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '₱${(product.total as double).toStringAsFixed(2)}',
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  const Divider(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Grand Total:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          '₱${products.fold(0.0, (sum, item) => sum + (item.total as double)).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(),
                                ],
                              ),
                            ),
                          ),
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
                                  if (context.mounted) {
                                    await showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: const Text(
                                              "Connection Lost",
                                            ),
                                            content: const Text(
                                              "The application lost connection to the server.\nThe app will now close.",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  Future.delayed(
                                                    const Duration(
                                                      milliseconds: 500,
                                                    ),
                                                    () => exit(0),
                                                  );
                                                },
                                                child: const Text("OK"),
                                              ),
                                            ],
                                          ),
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
              } catch (error) {
                if (context.mounted) {
                  await showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text("Connection Lost"),
                          content: const Text(
                            "The application lost connection to the server.\nThe app will now close.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Future.delayed(
                                  const Duration(milliseconds: 500),
                                  () => exit(0),
                                );
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                  );
                }
              }
            },
          ),

          // General Summary Report
          ListTile(
            leading: const Icon(Icons.print, color: Colors.black),
            title: const Text(
              'General Summary Report',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () async {
              try {
                final products =
                    await GeneralReportService.generalProductSummary();
                final now = DateTime.now();
                final formattedDate = DateFormat('MMMM d, y').format(now);
                final formattedTime = DateFormat('hh:mm a').format(now);

                Future.delayed(const Duration(milliseconds: 200), () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Summary Report',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 23,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Generated on $formattedDate at $formattedTime',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          content: SingleChildScrollView(
                            child: Container(
                              width: 600,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: const [
                                        Expanded(
                                          child: Text(
                                            'Product',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Price',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Quantity',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Total',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(),

                                  ...products.map((product) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(child: Text(product.name)),
                                          Expanded(
                                            child: Text(
                                              '₱${(product.price as double).toStringAsFixed(2)}',
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '${(product.quantity).toStringAsFixed(0)}',
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '₱${(product.total as double).toStringAsFixed(2)}',
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  Divider(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Grand Total:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          '₱${products.fold(0.0, (sum, item) => sum + (item.total as double)).toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(),
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                try {
                                  final products =
                                      await GeneralReportService.generalProductSummary();
                                  final printerService =
                                      GeneralSummaryPrintService();
                                  await printerService.printReceipt(
                                    products: products,
                                  );
                                  if (context.mounted) Navigator.pop(context);
                                } catch (error) {
                                  if (context.mounted) {
                                    await showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder:
                                          (context) => AlertDialog(
                                            title: const Text(
                                              "Connection Error",
                                            ),
                                            content: const Text(
                                              "Unable to retrieve data from the server. The app will now close.",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  exit(0);
                                                },
                                                child: const Text("OK"),
                                              ),
                                            ],
                                          ),
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
              } catch (error) {
                if (context.mounted) {
                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (context) => AlertDialog(
                          title: const Text("Connection Error"),
                          content: const Text(
                            "Unable to retrieve data from the server. The app will now close.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                exit(0);
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                  );
                }
              }
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
                barrierDismissible: true,
                barrierColor: Colors.black54,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Manager Access Required',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: TextField(
                      controller: codeController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Access Code',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[500],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          final code = codeController.text.trim();
                          Navigator.pop(context);

                          if (code == correctCode) {
                            final _formKey = GlobalKey<FormState>();
                            final transactionIdController =
                                TextEditingController();
                            bool isLoading = false;
                            String? feedback;

                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierColor: Colors.black54,
                              builder: (context) {
                                final size = MediaQuery.of(context).size;

                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    Future<void> voidTransaction() async {
                                      if (!_formKey.currentState!.validate())
                                        return;

                                      setState(() {
                                        isLoading = true;
                                        feedback = null;
                                      });

                                      final id =
                                          transactionIdController.text.trim();
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final token = prefs.getString('token');

                                      final String apiSecret =
                                          dotenv.env['POS_API_SECRET'] ?? "";
                                      final String apiUri =
                                          dotenv.env['POS_API_URL'] ?? "";
                                      final url = Uri.parse(
                                        '$apiUri/api/v1/void/$id',
                                      );

                                      try {
                                        final response = await http.post(
                                          url,
                                          headers: {
                                            'Authorization': 'Bearer $token',
                                            'Accept': 'application/json',
                                            'Pos-Secret-key': apiSecret,
                                          },
                                        );

                                        if (response.statusCode == 200) {
                                          final data = json.decode(
                                            response.body,
                                          );
                                          final transaction =
                                              VoidTransactionResponse.fromJson(
                                                data,
                                              );

                                          setState(() {
                                            feedback =
                                                '✅ ${transaction.message}';
                                          });

                                          // 🔹 Print the void receipt
                                          final printerService =
                                              VoidPrintService();
                                          await printerService.printReceipt(
                                            transaction: transaction,
                                          );
                                        } else {
                                          setState(
                                            () =>
                                                feedback =
                                                    '⚠️ Failed: ${response.body}',
                                          );
                                        }

                                        Future.delayed(
                                          const Duration(seconds: 3),
                                          () {
                                            if (Navigator.of(context).mounted) {
                                              setState(() => feedback = null);
                                            }
                                          },
                                        );
                                      } catch (e) {
                                        setState(
                                          () => feedback = '❌ Error: $e',
                                        );
                                      } finally {
                                        setState(() => isLoading = false);
                                      }
                                    }

                                    Future<void> restoreTransaction() async {
                                      if (!_formKey.currentState!.validate())
                                        return;

                                      setState(() {
                                        isLoading = true;
                                        feedback = null;
                                      });

                                      final id =
                                          transactionIdController.text.trim();
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      final token = prefs.getString('token');

                                      final String apiSecret =
                                          dotenv.env['POS_API_SECRET'] ?? "";
                                      final String apiUri =
                                          dotenv.env['POS_API_URL'] ?? "";
                                      final url = Uri.parse(
                                        '$apiUri/api/v1/restore/$id',
                                      );

                                      try {
                                        final response = await http.post(
                                          url,
                                          headers: {
                                            'Authorization': 'Bearer $token',
                                            'Accept': 'application/json',
                                            'Pos-Secret-key': apiSecret,
                                          },
                                        );

                                        if (response.statusCode == 200) {
                                          setState(
                                            () =>
                                                feedback =
                                                    '✅ Transaction restored successfully!',
                                          );
                                        } else {
                                          setState(
                                            () =>
                                                feedback =
                                                    '⚠️ Failed: ${response.body}',
                                          );
                                        }

                                        Future.delayed(
                                          const Duration(seconds: 3),
                                          () {
                                            if (Navigator.of(context).mounted) {
                                              setState(() => feedback = null);
                                            }
                                          },
                                        );
                                      } catch (e) {
                                        setState(
                                          () => feedback = '❌ Error: $e',
                                        );
                                      } finally {
                                        setState(() => isLoading = false);
                                      }
                                    }

                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      insetPadding: const EdgeInsets.all(24),
                                      child: SizedBox(
                                        width: size.width * 0.5,
                                        height: size.height * 0.4,
                                        child: Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Form(
                                            key: _formKey,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Manage Transaction',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 18,
                                                      ),
                                                ),
                                                const SizedBox(height: 16),
                                                TextFormField(
                                                  controller:
                                                      transactionIdController,
                                                  decoration: const InputDecoration(
                                                    labelText:
                                                        'Transaction Number',
                                                    border:
                                                        OutlineInputBorder(),
                                                    prefixIcon: Icon(
                                                      Icons.confirmation_number,
                                                    ),
                                                    isDense: true,
                                                  ),
                                                  validator:
                                                      (value) =>
                                                          value == null ||
                                                                  value.isEmpty
                                                              ? 'Enter a transaction number'
                                                              : null,
                                                ),
                                                const SizedBox(height: 20),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    ElevatedButton.icon(
                                                      onPressed:
                                                          isLoading
                                                              ? null
                                                              : voidTransaction,
                                                      icon:
                                                          isLoading
                                                              ? const SizedBox(
                                                                width: 16,
                                                                height: 16,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2,
                                                                    ),
                                                              )
                                                              : const Icon(
                                                                Icons.cancel,
                                                              ),
                                                      label: Text(
                                                        isLoading
                                                            ? 'Voiding...'
                                                            : 'Void Transaction',
                                                      ),
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.red[600],
                                                            foregroundColor:
                                                                Colors.white,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    ElevatedButton.icon(
                                                      onPressed:
                                                          isLoading
                                                              ? null
                                                              : restoreTransaction,
                                                      icon:
                                                          isLoading
                                                              ? const SizedBox(
                                                                width: 16,
                                                                height: 16,
                                                                child:
                                                                    CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2,
                                                                    ),
                                                              )
                                                              : const Icon(
                                                                Icons
                                                                    .check_circle,
                                                              ),
                                                      label: Text(
                                                        isLoading
                                                            ? 'Restoring...'
                                                            : 'Restore Transaction',
                                                      ),
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .green[600],
                                                            foregroundColor:
                                                                Colors.white,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                if (feedback != null) ...[
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    feedback!,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          feedback!.startsWith(
                                                                '✅',
                                                              )
                                                              ? Colors.green
                                                              : feedback!
                                                                  .startsWith(
                                                                    '⚠️',
                                                                  )
                                                              ? Colors.orange
                                                              : Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('❌ Incorrect access code'),
                                backgroundColor: Colors.red,
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
                await endShift(context: context, endingBalance: endingBalance);
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
