import 'dart:convert';
import 'dart:io';
import 'package:bir_pos/services/lock_service.dart';
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

class PaymentDrawer extends StatefulWidget {
  const PaymentDrawer({super.key});

  @override
  State<PaymentDrawer> createState() => _PaymentDrawerState();
}

class _PaymentDrawerState extends State<PaymentDrawer> {
  static Map<String, dynamic>? data;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController cashController = TextEditingController();
  final TextEditingController feeController = TextEditingController();

  Map<String, dynamic> savedValue = {
    'cash_tendered': 0,
    'transaction_fee': 0,
    'reference_number': null,
  };

  @override
  Widget build(BuildContext context) {
    if (data == null) return const SizedBox();

    final bool isDigital = data!['isDigital'];
    final method = data!['method'];
    final modalFunction = data!['modalFunction'];
    final methodFunction = data!['methodFunction'];
    final double total = data!['total'];

    return Drawer(
      width: 400,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// HEADER
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Transaction Method - ${method.name}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Total: ₱${total.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Divider(height: 24),
                ],
              ),

              /// FORM
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      /// CASH TENDERED
                      TextFormField(
                        controller: cashController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Enter Amount Tendered',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a value';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount < 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          savedValue['cash_tendered'] =
                              double.tryParse(value) ?? 0;
                        },
                      ),

                      const SizedBox(height: 12),

                      /// DIGITAL FIELDS
                      if (isDigital)
                        TextFormField(
                          controller: feeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Enter Transaction Fee',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a value';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null || amount < 0) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            savedValue['transaction_fee'] =
                                double.tryParse(value) ?? 0;
                          },
                        ),

                      if (isDigital) const SizedBox(height: 12),

                      if (isDigital)
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Enter Reference Number',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            savedValue['reference_number'] = value;
                          },
                        ),
                    ],
                  ),
                ),
              ),

              /// ACTIONS
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        methodFunction(method);
                        modalFunction(savedValue);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
